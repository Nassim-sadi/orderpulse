import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirestoreCollections.orders);

  @override
  Stream<List<OrderEntity>> watchDriverOrders(String driverId) {
    return _orders
        .where('${OrderKeys.assignedDriver}.${OrderKeys.driverId}',
            isEqualTo: driverId)
        .snapshots()
        .map(_expireAndMap);
  }

  @override
  Future<List<OrderEntity>> fetchDriverOrders(String driverId) async {
    final snapshot = await _orders
        .where('${OrderKeys.assignedDriver}.${OrderKeys.driverId}',
            isEqualTo: driverId)
        .get();
    return _expireAndMap(snapshot);
  }

  List<OrderEntity> _expireAndMap(QuerySnapshot<Map<String, dynamic>> snap) {
    final orders = <OrderEntity>[];
    final expiredWrites = <String, Map<String, dynamic>>{};
    for (final doc in snap.docs) {
      final order = OrderModel.fromMap(doc.id, doc.data());
      if (order.verificationExpired) {
        expiredWrites[doc.id] = {
          OrderKeys.status: OrderStatus.returned.value,
          OrderKeys.updatedAt: DateTime.now().toIso8601String(),
        };
      }
      orders.add(order);
    }
    if (expiredWrites.isNotEmpty) {
      final batch = _firestore.batch();
      expiredWrites.forEach((docId, data) {
        batch.update(_orders.doc(docId), data);
      });
      unawaited(batch.commit());
    }
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<void> ensureDemoData({
    required String driverId,
    required String driverName,
    required String driverPhone,
  }) async {
    final existing = await _orders
        .where('${OrderKeys.assignedDriver}.${OrderKeys.driverId}',
            isEqualTo: driverId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final batch = _firestore.batch();

    OrderEntity build({
      required String id,
      required String tracking,
      required ClientDetails client,
      required double subtotal,
      double shipping = 600,
      required OrderStatus status,
      AttemptAudit? audit,
      int hoursAgo = 2,
    }) =>
        OrderEntity(
          id: id,
          trackingNumber: tracking,
          client: client,
          financials: Financials(
            itemSubtotal: subtotal,
            shippingFee: shipping,
            totalCodAmount: subtotal + shipping,
            amountCollected:
                status == OrderStatus.deliveredPaid ? subtotal + shipping : 0,
          ),
          status: status,
          assignedDriver:
              DriverRef(id: driverId, name: driverName, phone: driverPhone),
          audit: audit,
          createdAt: now.subtract(Duration(hours: hoursAgo)),
          updatedAt: now.subtract(Duration(hours: hoursAgo)),
        );

    final samples = <OrderEntity>[
      build(
        id: 'ORD-2026-9901',
        tracking: 'TRK-884192',
        client: const ClientDetails(
          name: 'Yacine Belkacem',
          phone: '0550123456',
          wilaya: 'Batna',
          commune: 'Bouakal',
          streetAddress: 'Route de Biskra, Cité 102 Logements',
        ),
        subtotal: 4500,
        status: OrderStatus.outForDelivery,
        hoursAgo: 5,
      ),
      build(
        id: 'ORD-2026-9902',
        tracking: 'TRK-884193',
        client: const ClientDetails(
          name: 'Amina Cherifi',
          phone: '0661447788',
          wilaya: 'Batna',
          commune: 'Kchida',
          streetAddress: 'Cité Zmala, Bt 7, Appartement 12',
        ),
        subtotal: 8900,
        shipping: 750,
        status: OrderStatus.outForDelivery,
        hoursAgo: 5,
      ),
      build(
        id: 'ORD-2026-9903',
        tracking: 'TRK-884194',
        client: const ClientDetails(
          name: 'Karim Haddad',
          phone: '0770998811',
          wilaya: 'Batna',
          commune: 'Centre Ville',
          streetAddress: 'Rue Larbi Ben Mhidi N° 34',
        ),
        subtotal: 2300,
        status: OrderStatus.outForDelivery,
        hoursAgo: 4,
      ),
      build(
        id: 'ORD-2026-9904',
        tracking: 'TRK-884195',
        client: const ClientDetails(
          name: 'Nadia Bouzid',
          phone: '0555674321',
          wilaya: 'Batna',
          commune: 'Tazoult',
          streetAddress: 'Village centre, proche mosquée',
        ),
        subtotal: 12000,
        shipping: 900,
        status: OrderStatus.dispatched,
        hoursAgo: 3,
      ),
      build(
        id: 'ORD-2026-9905',
        tracking: 'TRK-884190',
        client: const ClientDetails(
          name: 'Sofiane Meziane',
          phone: '0699223344',
          wilaya: 'Batna',
          commune: 'Fesdis',
          streetAddress: 'Route de Timgad, lotissement 45',
        ),
        subtotal: 3100,
        status: OrderStatus.deliveredPaid,
        hoursAgo: 8,
      ),
      build(
        id: 'ORD-2026-9906',
        tracking: 'TRK-884189',
        client: const ClientDetails(
          name: 'Lila Ould Ali',
          phone: '0557889900',
          wilaya: 'Batna',
          commune: 'Seriana',
          streetAddress: 'Cité des Oliviers N° 3',
        ),
        subtotal: 1500,
        status: OrderStatus.failedPendingVerification,
        audit: AttemptAudit(
          callInitiatedAt: now.subtract(const Duration(minutes: 40)),
          callDurationSeconds: 18,
          location: const GpsLocation(
            latitude: 35.5558,
            longitude: 6.1741,
            accuracyMeters: 4.2,
          ),
          reason: FailureReason.unresponsive,
          verificationDeadline: now.add(const Duration(minutes: 15)),
        ),
        hoursAgo: 6,
      ),
    ];

    for (var i = 0; i < samples.length; i++) {
      final order = samples[i];
      batch.set(
        _orders.doc('demo_${driverId}_$i'),
        OrderModel.toMap(order),
      );
    }
    await batch.commit();
  }

  @override
  Future<void> reportDeliveryFailure({
    required String orderId,
    required FailureReason reason,
    required DateTime callInitiatedAt,
    required int callDurationSeconds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required Duration verificationWindow,
  }) async {
    final query = await _orders
        .where(OrderKeys.orderId, isEqualTo: orderId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw StateError('Order $orderId not found');
    }
    final now = DateTime.now();
    await query.docs.first.reference.update({
      OrderKeys.status: OrderStatus.failedPendingVerification.value,
      OrderKeys.attemptAudit: {
        OrderKeys.callInitiatedAt: callInitiatedAt.toIso8601String(),
        OrderKeys.callDurationSeconds: callDurationSeconds,
        OrderKeys.driverLocation: {
          OrderKeys.latitude: latitude,
          OrderKeys.longitude: longitude,
          OrderKeys.accuracyMeters: accuracyMeters,
        },
        OrderKeys.driverReason: reason.value,
        OrderKeys.verificationDeadline:
            now.add(verificationWindow).toIso8601String(),
        OrderKeys.merchantIntervened: false,
        OrderKeys.overrideNote: null,
      },
      OrderKeys.updatedAt: now.toIso8601String(),
    });
  }

  @override
  Future<void> markDelivered({required String orderId}) async {
    final query = await _orders
        .where(OrderKeys.orderId, isEqualTo: orderId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw StateError('Order $orderId not found');
    }
    final order =
        OrderModel.fromMap(query.docs.first.id, query.docs.first.data());
    await query.docs.first.reference.update({
      OrderKeys.status: OrderStatus.deliveredPaid.value,
      '${OrderKeys.financials}.${OrderKeys.amountCollected}':
          order.financials.totalCodAmount,
      OrderKeys.updatedAt: DateTime.now().toIso8601String(),
    });
  }
}
