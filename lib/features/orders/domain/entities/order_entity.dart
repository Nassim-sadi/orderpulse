import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending('PENDING'),
  confirmed('CONFIRMED'),
  dispatched('DISPATCHED'),
  outForDelivery('OUT_FOR_DELIVERY'),
  deliveredPaid('DELIVERED_PAID'),
  failedPendingVerification('FAILED_ATTEMPT_PENDING_VERIFICATION'),
  returned('RETURNED');

  const OrderStatus(this.value);

  final String value;

  static OrderStatus fromValue(String value) => values.firstWhere(
        (s) => s.value == value,
        orElse: () => OrderStatus.pending,
      );
}

enum FailureReason {
  unresponsive('UNRESPONSIVE'),
  refused('REFUSED'),
  wrongAddress('WRONG_ADDRESS');

  const FailureReason(this.value);

  final String value;

  static FailureReason fromValue(String value) =>
      values.firstWhere((r) => r.value == value);
}

class ClientDetails {
  const ClientDetails({
    required this.name,
    required this.phone,
    required this.wilaya,
    required this.commune,
    required this.streetAddress,
  });

  final String name;
  final String phone;
  final String wilaya;
  final String commune;
  final String streetAddress;
}

class Financials {
  const Financials({
    required this.itemSubtotal,
    required this.shippingFee,
    required this.totalCodAmount,
    this.amountCollected = 0,
  });

  final double itemSubtotal;
  final double shippingFee;
  final double totalCodAmount;
  final double amountCollected;

  Financials copyWithAmountCollected(double amount) => Financials(
        itemSubtotal: itemSubtotal,
        shippingFee: shippingFee,
        totalCodAmount: totalCodAmount,
        amountCollected: amount,
      );
}

class DriverRef {
  const DriverRef({
    required this.id,
    required this.name,
    required this.phone,
  });

  final String id;
  final String name;
  final String phone;
}

class GpsLocation {
  const GpsLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
}

class AttemptAudit {
  const AttemptAudit({
    required this.callInitiatedAt,
    required this.callDurationSeconds,
    required this.location,
    required this.reason,
    required this.verificationDeadline,
    this.merchantIntervened = false,
    this.overrideNote,
  });

  final DateTime callInitiatedAt;
  final int callDurationSeconds;
  final GpsLocation location;
  final FailureReason reason;
  final DateTime verificationDeadline;
  final bool merchantIntervened;
  final String? overrideNote;
}

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.trackingNumber,
    required this.client,
    required this.financials,
    required this.status,
    required this.assignedDriver,
    required this.createdAt,
    required this.updatedAt,
    this.audit,
  });

  final String id;
  final String trackingNumber;
  final ClientDetails client;
  final Financials financials;
  final OrderStatus status;
  final DriverRef assignedDriver;
  final AttemptAudit? audit;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAwaitingVerification =>
      status == OrderStatus.failedPendingVerification && audit != null;

  bool get isActionable =>
      status == OrderStatus.outForDelivery ||
      status == OrderStatus.dispatched;

  bool get verificationExpired {
    final deadline = audit?.verificationDeadline;
    return isAwaitingVerification &&
        deadline != null &&
        deadline.isBefore(DateTime.now());
  }

  OrderEntity copyWith({
    OrderStatus? status,
    Financials? financials,
    AttemptAudit? audit,
    DateTime? updatedAt,
  }) =>
      OrderEntity(
        id: id,
        trackingNumber: trackingNumber,
        client: client,
        financials: financials ?? this.financials,
        status: status ?? this.status,
        assignedDriver: assignedDriver,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        audit: audit ?? this.audit,
      );

  @override
  List<Object?> get props => [
        id,
        trackingNumber,
        client.phone,
        financials.totalCodAmount,
        status,
        audit?.verificationDeadline,
        audit?.merchantIntervened,
        updatedAt,
      ];
}
