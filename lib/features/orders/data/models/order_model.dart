import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/order_entity.dart';

class OrderModel {
  const OrderModel._();

  static OrderEntity fromMap(String id, Map<String, dynamic> map) {
    final auditMap =
        map[OrderKeys.attemptAudit] as Map<String, dynamic>?;
    final attemptsList = (map[OrderKeys.attempts] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return OrderEntity(
      id: id,
      trackingNumber:
          map[OrderKeys.trackingNumber] as String? ?? '',
      client: _clientFromMap(
          map[OrderKeys.clientDetails] as Map<String, dynamic>? ?? {}),
      financials: _financialsFromMap(
          map[OrderKeys.financials] as Map<String, dynamic>? ?? {}),
      status: OrderStatus.fromValue(map[OrderKeys.status] as String? ?? ''),
      assignedDriver: _driverFromMap(
          map[OrderKeys.assignedDriver] as Map<String, dynamic>? ?? {}),
      audit: auditMap == null ? null : _auditFromMap(auditMap),
      attempts: attemptsList.map(_auditFromMap).toList(growable: false),
      callAttemptsCount:
          (map[OrderKeys.callAttemptsCount] as num?)?.toInt() ?? 0,
      driverResponseDeadline:
          DateTime.tryParse(map[OrderKeys.driverResponseDeadline] as String? ?? ''),
      driverResponseExpiredAt:
          DateTime.tryParse(map[OrderKeys.driverResponseExpiredAt] as String? ?? ''),
      createdAt: DateTime.tryParse(map[OrderKeys.createdAt] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map[OrderKeys.updatedAt] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static Map<String, dynamic> toMap(OrderEntity o) => {
        OrderKeys.orderId: o.id,
        OrderKeys.trackingNumber: o.trackingNumber,
        OrderKeys.clientDetails: {
          OrderKeys.name: o.client.name,
          OrderKeys.phone: o.client.phone,
          OrderKeys.wilaya: o.client.wilaya,
          OrderKeys.commune: o.client.commune,
          OrderKeys.streetAddress: o.client.streetAddress,
        },
        OrderKeys.financials: {
          OrderKeys.itemSubtotal: o.financials.itemSubtotal,
          OrderKeys.shippingFee: o.financials.shippingFee,
          OrderKeys.totalCodAmount: o.financials.totalCodAmount,
          OrderKeys.amountCollected: o.financials.amountCollected,
        },
        OrderKeys.status: o.status.value,
        OrderKeys.assignedDriver: {
          OrderKeys.driverId: o.assignedDriver.id,
          OrderKeys.driverName: o.assignedDriver.name,
          OrderKeys.driverPhone: o.assignedDriver.phone,
        },
        if (o.audit != null) OrderKeys.attemptAudit: _auditToMap(o.audit!),
        if (o.attempts.isNotEmpty)
          OrderKeys.attempts: o.attempts.map(_auditToMap).toList(),
        OrderKeys.callAttemptsCount: o.callAttemptsCount,
        if (o.driverResponseDeadline != null)
          OrderKeys.driverResponseDeadline:
              o.driverResponseDeadline!.toIso8601String(),
        if (o.driverResponseExpiredAt != null)
          OrderKeys.driverResponseExpiredAt:
              o.driverResponseExpiredAt!.toIso8601String(),
        OrderKeys.createdAt: o.createdAt.toIso8601String(),
        OrderKeys.updatedAt: o.updatedAt.toIso8601String(),
      };

  static ClientDetails _clientFromMap(Map<String, dynamic> m) => ClientDetails(
        name: m[OrderKeys.name] as String? ?? '',
        phone: m[OrderKeys.phone] as String? ?? '',
        wilaya: m[OrderKeys.wilaya] as String? ?? '',
        commune: m[OrderKeys.commune] as String? ?? '',
        streetAddress: m[OrderKeys.streetAddress] as String? ?? '',
      );

  static Financials _financialsFromMap(Map<String, dynamic> m) => Financials(
        itemSubtotal: (m[OrderKeys.itemSubtotal] as num?)?.toDouble() ?? 0,
        shippingFee: (m[OrderKeys.shippingFee] as num?)?.toDouble() ?? 0,
        totalCodAmount: (m[OrderKeys.totalCodAmount] as num?)?.toDouble() ?? 0,
        amountCollected: (m[OrderKeys.amountCollected] as num?)?.toDouble() ?? 0,
      );

  static DriverRef _driverFromMap(Map<String, dynamic> m) => DriverRef(
        id: m[OrderKeys.driverId] as String? ?? '',
        name: m[OrderKeys.driverName] as String? ?? '',
        phone: m[OrderKeys.driverPhone] as String? ?? '',
      );

  static AttemptAudit _auditFromMap(Map<String, dynamic> m) {
    final loc = m[OrderKeys.driverLocation] as Map<String, dynamic>? ?? {};
    return AttemptAudit(
      callInitiatedAt:
          DateTime.tryParse(m[OrderKeys.callInitiatedAt] as String? ?? '') ??
              DateTime.now(),
      callDurationSeconds:
          (m[OrderKeys.callDurationSeconds] as num?)?.toInt() ?? 0,
      location: GpsLocation(
        latitude: (loc[OrderKeys.latitude] as num?)?.toDouble() ?? 0,
        longitude: (loc[OrderKeys.longitude] as num?)?.toDouble() ?? 0,
        accuracyMeters:
            (loc[OrderKeys.accuracyMeters] as num?)?.toDouble() ?? 0,
      ),
      reason: FailureReason.fromValue(
          m[OrderKeys.driverReason] as String? ?? 'UNRESPONSIVE'),
      verificationDeadline:
          DateTime.tryParse(m[OrderKeys.verificationDeadline] as String? ?? '') ??
              DateTime.now(),
      merchantIntervened: m[OrderKeys.merchantIntervened] as bool? ?? false,
      overrideNote: m[OrderKeys.overrideNote] as String?,
      unverifiedReturn: m[OrderKeys.unverifiedReturn] as bool? ?? false,
    );
  }

  static Map<String, dynamic> auditMap(AttemptAudit a) => _auditToMap(a);

  static Map<String, dynamic> _auditToMap(AttemptAudit a) => {
        OrderKeys.callInitiatedAt: a.callInitiatedAt.toIso8601String(),
        OrderKeys.callDurationSeconds: a.callDurationSeconds,
        OrderKeys.driverLocation: {
          OrderKeys.latitude: a.location.latitude,
          OrderKeys.longitude: a.location.longitude,
          OrderKeys.accuracyMeters: a.location.accuracyMeters,
        },
        OrderKeys.driverReason: a.reason.value,
        OrderKeys.verificationDeadline:
            a.verificationDeadline.toIso8601String(),
        OrderKeys.merchantIntervened: a.merchantIntervened,
        OrderKeys.overrideNote: a.overrideNote,
        OrderKeys.unverifiedReturn: a.unverifiedReturn,
      };
}
