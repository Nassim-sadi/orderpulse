import 'package:cod_delivery_app/core/constants/firestore_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cod_delivery_app/features/orders/data/models/order_model.dart';
import 'package:cod_delivery_app/features/orders/data/repositories/order_repository_impl.dart';
import 'package:cod_delivery_app/features/orders/domain/entities/order_entity.dart';
OrderEntity _order({
  String id = 'ORD-1',
  OrderStatus status = OrderStatus.outForDelivery,
  double totalCod = 5100,
  DateTime? deadline,
}) {
  final audit = status == OrderStatus.failedPendingVerification
      ? AttemptAudit(
          callInitiatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          callDurationSeconds: 20,
          location: const GpsLocation(
              latitude: 35.55, longitude: 6.17, accuracyMeters: 3),
          reason: FailureReason.unresponsive,
          verificationDeadline:
              deadline ?? DateTime.now().add(const Duration(minutes: 15)),
        )
      : null;
  return OrderEntity(
    id: id,
    trackingNumber: 'TRK-$id',
    client: const ClientDetails(
      name: 'Yacine Belkacem',
      phone: '0550123456',
      wilaya: 'Batna',
      commune: 'Bouakal',
      streetAddress: 'Route de Biskra',
    ),
    financials: Financials(
      itemSubtotal: totalCod - 600,
      shippingFee: 600,
      totalCodAmount: totalCod,
      amountCollected: status == OrderStatus.deliveredPaid ? totalCod : 0,
    ),
    status: status,
    assignedDriver: const DriverRef(id: 'drv_99', name: 'Sofiane', phone: '066'),
    audit: audit,
    attempts: audit == null ? const [] : [audit],
    createdAt: DateTime(2026, 8, 22, 8),
    updatedAt: DateTime(2026, 8, 22, 9),
  );
}

Future<void> _seed(FirebaseFirestore firestore, OrderEntity order,
    {String docId = 'doc'}) {
  return firestore
      .collection(FirestoreCollections.orders)
      .doc(docId)
      .set(OrderModel.toMap(order));
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreOrderRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreOrderRepository(firestore);
  });

  group('ensureDemoData', () {
    test('seeds demo orders for a new driver', () async {
      await repository.ensureDemoData(
          driverId: 'drv_99', driverName: 'Sofiane', driverPhone: '066');

      final orders = await repository.fetchDriverOrders('drv_99');
      expect(orders.length, 6);
      expect(
        orders.map((o) => o.status).toSet(),
        containsAll([
          OrderStatus.outForDelivery,
          OrderStatus.dispatched,
          OrderStatus.deliveredPaid,
          OrderStatus.failedPendingVerification,
        ]),
      );
    });

    test('is idempotent — no duplicates on repeated calls', () async {
      await repository.ensureDemoData(
          driverId: 'drv_99', driverName: 'Sofiane', driverPhone: '066');
      await repository.ensureDemoData(
          driverId: 'drv_99', driverName: 'Sofiane', driverPhone: '066');

      final orders = await repository.fetchDriverOrders('drv_99');
      expect(orders.length, 6);
    });
  });

  group('reportDeliveryFailure', () {
    test('writes spec-shaped audit document with ~15min deadline', () async {
      await _seed(firestore, _order());

      final initiatedAt = DateTime.now().subtract(const Duration(minutes: 2));
      await repository.reportDeliveryFailure(
        orderId: 'ORD-1',
        reason: FailureReason.refused,
        callInitiatedAt: initiatedAt,
        callDurationSeconds: 42,
        latitude: 35.5558,
        longitude: 6.1741,
        accuracyMeters: 4.2,
        verificationWindow: const Duration(minutes: 15),
        verifiedCall: true,
      );

      final doc = await firestore
          .collection(FirestoreCollections.orders)
          .doc('doc')
          .get();
      final data = doc.data()!;

      expect(data[OrderKeys.status],
          OrderStatus.failedPendingVerification.value);

      final audit =
          data[OrderKeys.attemptAudit] as Map<String, dynamic>;
      expect(audit[OrderKeys.driverReason], FailureReason.refused.value);
      expect(audit[OrderKeys.callDurationSeconds], greaterThanOrEqualTo(42));

      final location = audit[OrderKeys.driverLocation] as Map<String, dynamic>;
      expect(location[OrderKeys.latitude], 35.5558);
      expect(location[OrderKeys.accuracyMeters], 4.2);

      final deadline =
          DateTime.parse(audit[OrderKeys.verificationDeadline] as String);
      final expectedLow = DateTime.now()
          .add(const Duration(minutes: 15))
          .subtract(const Duration(seconds: 30));
      final expectedHigh = DateTime.now()
          .add(const Duration(minutes: 15))
          .add(const Duration(seconds: 30));
      expect(deadline.isAfter(expectedLow), isTrue);
      expect(deadline.isBefore(expectedHigh), isTrue);

      expect(audit[OrderKeys.merchantIntervened], false);
    });

    test('throws when the order does not exist', () async {
      expect(
        () => repository.reportDeliveryFailure(
          orderId: 'MISSING',
          reason: FailureReason.refused,
          callInitiatedAt: DateTime.now(),
          callDurationSeconds: 10,
          latitude: 0,
          longitude: 0,
          accuracyMeters: 1,
          verificationWindow: const Duration(minutes: 15),
          verifiedCall: true,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('markDelivered', () {
    test('sets collected cash equal to total COD', () async {
      await _seed(firestore, _order());

      await repository.markDelivered(orderId: 'ORD-1');

      final doc = await firestore
          .collection(FirestoreCollections.orders)
          .doc('doc')
          .get();
      final data = doc.data()!;
      expect(data[OrderKeys.status], OrderStatus.deliveredPaid.value);
      final financials = data[OrderKeys.financials] as Map<String, dynamic>;
      expect(financials[OrderKeys.amountCollected], 5100);
    });
  });

  group('watchDriverOrders lazy expiry', () {
    test('transitions expired verifications to RETURNED', () async {
      await _seed(
        firestore,
        _order(
          status: OrderStatus.failedPendingVerification,
          deadline: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      );

      final emissions = <List<OrderEntity>>[];
      final sub = repository.watchDriverOrders('drv_99').listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sub.cancel();

      final statuses = emissions.expand((l) => l.map((o) => o.status));
      expect(statuses, contains(OrderStatus.returned));
    });

    test('does not touch verifications still inside the window', () async {
      await _seed(
        firestore,
        _order(
          status: OrderStatus.failedPendingVerification,
          deadline: DateTime.now().add(const Duration(minutes: 15)),
        ),
      );

      final emissions = <List<OrderEntity>>[];
      final sub = repository.watchDriverOrders('drv_99').listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sub.cancel();

      final statuses = emissions.expand((l) => l.map((o) => o.status));
      expect(statuses, everyElement(OrderStatus.failedPendingVerification));
      expect(statuses, isNot(contains(OrderStatus.returned)));
    });
  });

  group('logCallAttempt', () {
    test('writes attempt doc, increments count, starts response window',
        () async {
      await _seed(firestore, _order());

      await repository.logCallAttempt(
        orderId: 'ORD-1',
        driverId: 'drv_99',
        clientPhone: '0550123456',
        responseWindow: const Duration(minutes: 10),
      );

      final attempts = await firestore
          .collection(FirestoreCollections.orders)
          .doc('doc')
          .collection(FirestoreCollections.callAttempts)
          .get();
      expect(attempts.docs.length, 1);

      final doc = await firestore
          .collection(FirestoreCollections.orders)
          .doc('doc')
          .get();
      final data = doc.data()!;
      expect(data[OrderKeys.callAttemptsCount], 1);
      final deadline = DateTime.parse(
          data[OrderKeys.driverResponseDeadline] as String);
      expect(
        deadline.isAfter(
            DateTime.now().add(const Duration(minutes: 9))),
        isTrue,
      );
    });
  });

  group('unverified decline flow', () {
    test('flags unverified return and writes a high-severity notification',
        () async {
      await _seed(firestore, _order());
      await firestore
          .collection(FirestoreCollections.drivers)
          .doc('drv_99')
          .set({'name': 'Sofiane', 'trust_score': 100});

      await repository.reportDeliveryFailure(
        orderId: 'ORD-1',
        reason: FailureReason.unresponsive,
        callInitiatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        callDurationSeconds: 0,
        latitude: 35.5,
        longitude: 6.1,
        accuracyMeters: 5,
        verificationWindow: const Duration(minutes: 15),
        verifiedCall: false,
      );

      final doc = await firestore
          .collection(FirestoreCollections.orders)
          .doc('doc')
          .get();
      final audit =
          doc.data()![OrderKeys.attemptAudit] as Map<String, dynamic>;
      expect(audit[OrderKeys.unverifiedReturn], isTrue);

      final notifications = await firestore
          .collection(FirestoreCollections.notifications)
          .get();
      final types = notifications.docs
          .map((d) => d.data()[NotificationKeys.type])
          .toList();
      expect(types, contains(NotificationType.failureUnverified.value));
      final unverifiedNotif = notifications.docs.firstWhere((d) =>
          d.data()[NotificationKeys.type] ==
          NotificationType.failureUnverified.value);
      expect(unverifiedNotif.data()[NotificationKeys.severity], 'high');

      final driver = await firestore
          .collection(FirestoreCollections.drivers)
          .doc('drv_99')
          .get();
      expect(driver.data()![DriverKeys.trustScore], 95);
    });

    test('verified decline does not penalize the driver', () async {
      await _seed(firestore, _order());
      await firestore
          .collection(FirestoreCollections.drivers)
          .doc('drv_99')
          .set({'name': 'Sofiane', 'trust_score': 100});

      await repository.reportDeliveryFailure(
        orderId: 'ORD-1',
        reason: FailureReason.unresponsive,
        callInitiatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        callDurationSeconds: 30,
        latitude: 35.5,
        longitude: 6.1,
        accuracyMeters: 5,
        verificationWindow: const Duration(minutes: 15),
        verifiedCall: true,
      );

      final driver = await firestore
          .collection(FirestoreCollections.drivers)
          .doc('drv_99')
          .get();
      expect(driver.data()![DriverKeys.trustScore], 100);
    });
  });

  group('merchant interventions', () {
    Future<void> seedPending() async {
      await _seed(
        firestore,
        _order(status: OrderStatus.failedPendingVerification),
      );
      await firestore
          .collection(FirestoreCollections.drivers)
          .doc('drv_99')
          .set({'name': 'Sofiane', 'trust_score': 100});
    }

    test('overrideToRedelivery re-dispatches, marks intervention, penalizes',
        () async {
      await seedPending();

      await repository.overrideToRedelivery(
          orderId: 'ORD-1', note: 'Customer called back');

      final orders = await repository.fetchDriverOrders('drv_99');
      expect(orders.length, 1);
      final order = orders.first;
      expect(order.status, OrderStatus.outForDelivery);
      expect(order.audit!.merchantIntervened, isTrue);
      expect(order.audit!.overrideNote, 'Customer called back');
      expect(order.attempts.length, 2);

      final driver = await firestore
          .collection(FirestoreCollections.drivers)
          .doc('drv_99')
          .get();
      expect(driver.data()![DriverKeys.trustScore], 90);

      final notifications = await firestore
          .collection(FirestoreCollections.notifications)
          .get();
      expect(
        notifications.docs
            .map((d) => d.data()[NotificationKeys.type]),
        contains(NotificationType.redispatched.value),
      );
    });

    test('confirmFailure returns the order and notifies', () async {
      await seedPending();

      await repository.confirmFailure(orderId: 'ORD-1');

      final orders = await repository.fetchDriverOrders('drv_99');
      expect(orders.first.status, OrderStatus.returned);

      final notifications = await firestore
          .collection(FirestoreCollections.notifications)
          .get();
      expect(
        notifications.docs
            .map((d) => d.data()[NotificationKeys.type]),
        contains(NotificationType.returnedConfirmed.value),
      );
    });

    test('watchPendingVerifications streams only pending-verification docs',
        () async {
      await _seed(firestore, _order(), docId: 'pending');
      await _seed(
          firestore,
          _order(
            id: 'ORD-2',
            status: OrderStatus.deliveredPaid,
          ),
          docId: 'delivered');

      final emissions = <List<OrderEntity>>[];
      final sub =
          repository.watchPendingVerifications().listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sub.cancel();

      expect(emissions, isNotEmpty);
      for (final order in emissions.expand((l) => l)) {
        expect(order.status, OrderStatus.failedPendingVerification);
      }
    });
  });

  group('driver response timer expiry', () {
    test('flags no-response on actionable orders past their deadline',
        () async {
      final map = OrderModel.toMap(_order());
      map[OrderKeys.driverResponseDeadline] = DateTime.now()
          .subtract(const Duration(minutes: 11))
          .toIso8601String();
      await firestore
          .collection(FirestoreCollections.orders)
          .doc('doc')
          .set(map);
      await firestore
          .collection(FirestoreCollections.drivers)
          .doc('drv_99')
          .set({'name': 'Sofiane', 'trust_score': 100});

      final emissions = <List<OrderEntity>>[];
      final sub = repository.watchDriverOrders('drv_99').listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sub.cancel();

      final order = emissions.expand((l) => l).first;
      expect(order.driverResponseExpiredAt, isNotNull);

      final notifications = await firestore
          .collection(FirestoreCollections.notifications)
          .get();
      expect(
        notifications.docs
            .map((d) => d.data()[NotificationKeys.type]),
        contains(NotificationType.driverNoResponse.value),
      );

      final driver = await firestore
          .collection(FirestoreCollections.drivers)
          .doc('drv_99')
          .get();
      expect(driver.data()![DriverKeys.trustScore], 95);
    });
  });
}
