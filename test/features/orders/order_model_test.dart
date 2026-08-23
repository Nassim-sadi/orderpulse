import 'package:cod_delivery_app/core/constants/firestore_keys.dart';
import 'package:cod_delivery_app/features/orders/data/models/order_model.dart';
import 'package:cod_delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_test/flutter_test.dart';

OrderEntity _sample() => OrderEntity(
      id: 'ORD-2026-9901',
      trackingNumber: 'TRK-884192',
      client: const ClientDetails(
        name: 'Yacine Belkacem',
        phone: '0550123456',
        wilaya: 'Batna',
        commune: 'Bouakal',
        streetAddress: 'Route de Biskra, Cité 102 Logements',
      ),
      financials: const Financials(
        itemSubtotal: 4500,
        shippingFee: 600,
        totalCodAmount: 5100,
      ),
      status: OrderStatus.failedPendingVerification,
      assignedDriver: const DriverRef(
        id: 'drv_user_99',
        name: 'Sofiane Benzine',
        phone: '0661987654',
      ),
      audit: AttemptAudit(
        callInitiatedAt: DateTime.utc(2026, 8, 22, 18, 30),
        callDurationSeconds: 24,
        location: const GpsLocation(
          latitude: 35.5558,
          longitude: 6.1741,
          accuracyMeters: 4.2,
        ),
        reason: FailureReason.unresponsive,
        verificationDeadline: DateTime.utc(2026, 8, 22, 18, 45),
      ),
      createdAt: DateTime.utc(2026, 8, 22, 8, 0),
      updatedAt: DateTime.utc(2026, 8, 22, 18, 30),
    );

void main() {
  group('OrderModel', () {
    test('round-trips through a map without loss', () {
      final original = _sample();
      final map = OrderModel.toMap(original);
      final restored = OrderModel.fromMap('doc-1', map);

      expect(restored.id, 'doc-1');
      expect(restored.trackingNumber, original.trackingNumber);
      expect(restored.client.name, original.client.name);
      expect(restored.client.phone, original.client.phone);
      expect(restored.financials.totalCodAmount, 5100);
      expect(restored.status, OrderStatus.failedPendingVerification);
      expect(restored.assignedDriver.id, 'drv_user_99');
      expect(restored.audit!.reason, FailureReason.unresponsive);
      expect(restored.audit!.callDurationSeconds, 24);
      expect(restored.audit!.location.latitude, 35.5558);
      expect(restored.audit!.location.accuracyMeters, 4.2);
    });

    test('map matches the spec schema field names', () {
      final map = OrderModel.toMap(_sample());

      expect(map[OrderKeys.orderId], 'ORD-2026-9901');
      expect(map[OrderKeys.status], 'FAILED_ATTEMPT_PENDING_VERIFICATION');
      final audit = map[OrderKeys.attemptAudit] as Map<String, dynamic>;
      expect(audit[OrderKeys.driverReason], 'UNRESPONSIVE');
      final loc = audit[OrderKeys.driverLocation] as Map<String, dynamic>;
      expect(loc[OrderKeys.accuracyMeters], 4.2);
    });

    test('tolerates missing optional fields', () {
      final order = OrderModel.fromMap('doc-2', {});
      expect(order.id, 'doc-2');
      expect(order.status, OrderStatus.pending);
      expect(order.audit, isNull);
    });

    test('verificationExpired flips after the deadline', () {
      final expired = OrderEntity(
        id: 'X',
        trackingNumber: 'T',
        client: const ClientDetails(
            name: 'a', phone: '1', wilaya: 'w', commune: 'c', streetAddress: 's'),
        financials:
            const Financials(itemSubtotal: 1, shippingFee: 1, totalCodAmount: 2),
        status: OrderStatus.failedPendingVerification,
        assignedDriver: const DriverRef(id: 'd', name: 'n', phone: 'p'),
        audit: AttemptAudit(
          callInitiatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          callDurationSeconds: 10,
          location: const GpsLocation(latitude: 0, longitude: 0, accuracyMeters: 1),
          reason: FailureReason.refused,
          verificationDeadline: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(expired.verificationExpired, isTrue);
      expect(expired.isAwaitingVerification, isTrue);
    });
  });
}
