import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirestoreCollections.orders);

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection(FirestoreCollections.notifications);

  CollectionReference<Map<String, dynamic>> get _drivers =>
      _firestore.collection(FirestoreCollections.drivers);

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

  @override
  Stream<List<OrderEntity>> watchPendingVerifications() {
    return _orders
        .where(OrderKeys.status,
            isEqualTo: OrderStatus.failedPendingVerification.value)
        .snapshots()
        .map((snap) {
      final orders =
          snap.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList();
      orders.sort((a, b) => (a.audit?.verificationDeadline ??
              a.createdAt)
          .compareTo(b.audit?.verificationDeadline ?? b.createdAt));
      return orders;
    });
  }

  List<OrderEntity> _expireAndMap(QuerySnapshot<Map<String, dynamic>> snap) {
    final orders = <OrderEntity>[];
    final writes = <String, Map<String, dynamic>>{};
    for (final doc in snap.docs) {
      final order = OrderModel.fromMap(doc.id, doc.data());
      final now = DateTime.now();

      if (order.verificationExpired) {
        writes[doc.id] = {
          OrderKeys.status: OrderStatus.returned.value,
          OrderKeys.updatedAt: now.toIso8601String(),
        };
        unawaited(_pushNotification(
          type: NotificationType.returnedAuto,
          orderId: order.id,
          severity: 'normal',
          message:
              'Verification window expired without merchant intervention. '
              'Order ${order.trackingNumber} returned.',
          driverId: order.assignedDriver.id,
        ));
        orders.add(order.copyWith(status: OrderStatus.returned));
        continue;
      }

      if (order.responseTimerExpired) {
        writes[doc.id] = {
          OrderKeys.driverResponseExpiredAt: now.toIso8601String(),
          OrderKeys.updatedAt: now.toIso8601String(),
        };
        unawaited(_pushNotification(
          type: NotificationType.driverNoResponse,
          orderId: order.id,
          severity: 'high',
          message:
              'Driver did not report an outcome for ${order.trackingNumber} '
              'within the response window.',
          driverId: order.assignedDriver.id,
        ));
        unawaited(
            _penalizeDriver(order.assignedDriver.id, AppConstants.noResponsePenalty));
        orders.add(order.copyWith(driverResponseExpiredAt: now));
        continue;
      }

      orders.add(order);
    }
    if (writes.isNotEmpty) {
      final batch = _firestore.batch();
      writes.forEach((docId, data) {
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
          attempts: audit == null ? const [] : [audit],
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
  Future<void> logCallAttempt({
    required String orderId,
    required String driverId,
    required String clientPhone,
    required Duration responseWindow,
  }) async {
    final query = await _orders
        .where(OrderKeys.orderId, isEqualTo: orderId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw StateError('Order $orderId not found');
    }
    final doc = query.docs.first;
    final now = DateTime.now();
    await doc.reference.collection(FirestoreCollections.callAttempts).add({
      CallAttemptKeys.orderId: orderId,
      CallAttemptKeys.driverId: driverId,
      CallAttemptKeys.clientPhone: clientPhone,
      CallAttemptKeys.createdAt: now.toIso8601String(),
    });
    await doc.reference.update({
      OrderKeys.callAttemptsCount: FieldValue.increment(1),
      OrderKeys.driverResponseDeadline:
          now.add(responseWindow).toIso8601String(),
      OrderKeys.driverResponseExpiredAt: null,
      OrderKeys.updatedAt: now.toIso8601String(),
    });
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
    required bool verifiedCall,
  }) async {
    final query = await _orders
        .where(OrderKeys.orderId, isEqualTo: orderId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw StateError('Order $orderId not found');
    }
    final doc = query.docs.first;
    final order = OrderModel.fromMap(doc.id, doc.data());
    final now = DateTime.now();
    final audit = AttemptAudit(
      callInitiatedAt: callInitiatedAt,
      callDurationSeconds: callDurationSeconds,
      location: GpsLocation(
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
      ),
      reason: reason,
      verificationDeadline: now.add(verificationWindow),
      unverifiedReturn: !verifiedCall,
    );
    await doc.reference.update({
      OrderKeys.status: OrderStatus.failedPendingVerification.value,
      OrderKeys.attemptAudit: OrderModel.auditMap(audit),
      OrderKeys.attempts: FieldValue.arrayUnion([OrderModel.auditMap(audit)]),
      OrderKeys.driverResponseDeadline: null,
      OrderKeys.updatedAt: now.toIso8601String(),
    });
    unawaited(_pushNotification(
      type: verifiedCall
          ? NotificationType.failureVerified
          : NotificationType.failureUnverified,
      orderId: orderId,
      severity: verifiedCall ? 'normal' : 'high',
      message: verifiedCall
          ? 'Verified failed attempt on ${order.trackingNumber}. '
              'You can override or confirm within the window.'
          : 'UNVERIFIED return declared for ${order.trackingNumber} '
              '(no valid call proof). Immediate review recommended.',
      driverId: order.assignedDriver.id,
    ));
    if (!verifiedCall) {
      await _penalizeDriver(order.assignedDriver.id,
          AppConstants.unverifiedDeclinePenalty);
    }
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
    final doc = query.docs.first;
    final order = OrderModel.fromMap(doc.id, doc.data());
    await doc.reference.update({
      OrderKeys.status: OrderStatus.deliveredPaid.value,
      '${OrderKeys.financials}.${OrderKeys.amountCollected}':
          order.financials.totalCodAmount,
      OrderKeys.driverResponseDeadline: null,
      OrderKeys.updatedAt: DateTime.now().toIso8601String(),
    });
    unawaited(_pushNotification(
      type: NotificationType.delivered,
      orderId: orderId,
      severity: 'normal',
      message:
          'Order ${order.trackingNumber} delivered and COD collected '
          '(${order.financials.totalCodAmount.toStringAsFixed(0)} DZD).',
      driverId: order.assignedDriver.id,
    ));
  }

  @override
  Future<void> overrideToRedelivery({
    required String orderId,
    String? note,
  }) async {
    final query = await _orders
        .where(OrderKeys.orderId, isEqualTo: orderId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw StateError('Order $orderId not found');
    }
    final doc = query.docs.first;
    final order = OrderModel.fromMap(doc.id, doc.data());
    final latest = order.audit?.withMerchantIntervention(note: note);
    final now = DateTime.now();
    await doc.reference.update({
      OrderKeys.status: OrderStatus.outForDelivery.value,
      if (latest != null)
        OrderKeys.attemptAudit: OrderModel.auditMap(latest),
      if (latest != null)
        OrderKeys.attempts: FieldValue.arrayUnion([OrderModel.auditMap(latest)]),
      OrderKeys.updatedAt: now.toIso8601String(),
    });
    unawaited(_pushNotification(
      type: NotificationType.redispatched,
      orderId: orderId,
      severity: 'high',
      message:
          'Merchant overrode the failure claim for ${order.trackingNumber}. '
          'Customer wants the product. Order re-dispatched to '
          '${order.assignedDriver.name}.',
      driverId: order.assignedDriver.id,
    ));
    await _penalizeDriver(
        order.assignedDriver.id, AppConstants.provenLiePenalty);
  }

  @override
  Future<void> confirmFailure({
    required String orderId,
    String? note,
  }) async {
    final query = await _orders
        .where(OrderKeys.orderId, isEqualTo: orderId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw StateError('Order $orderId not found');
    }
    final doc = query.docs.first;
    final order = OrderModel.fromMap(doc.id, doc.data());
    final latest = order.audit?.withMerchantIntervention(note: note);
    final now = DateTime.now();
    await doc.reference.update({
      OrderKeys.status: OrderStatus.returned.value,
      if (latest != null)
        OrderKeys.attemptAudit: OrderModel.auditMap(latest),
      if (latest != null)
        OrderKeys.attempts: FieldValue.arrayUnion([OrderModel.auditMap(latest)]),
      OrderKeys.updatedAt: now.toIso8601String(),
    });
    unawaited(_pushNotification(
      type: NotificationType.returnedConfirmed,
      orderId: orderId,
      severity: 'normal',
      message:
          'Merchant confirmed the failure of ${order.trackingNumber}. '
          'Order marked as returned.',
      driverId: order.assignedDriver.id,
    ));
  }

  Future<void> _pushNotification({
    required NotificationType type,
    required String orderId,
    required String severity,
    required String message,
    required String driverId,
  }) async {
    try {
      await _notifications.add({
        NotificationKeys.type: type.value,
        NotificationKeys.orderId: orderId,
        NotificationKeys.severity: severity,
        NotificationKeys.message: message,
        NotificationKeys.driverId: driverId,
        NotificationKeys.createdAt: DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> _penalizeDriver(String driverId, int points) async {
    try {
      await _drivers.doc(driverId).update({
        DriverKeys.trustScore: FieldValue.increment(-points),
      });
    } catch (_) {}
  }
}
