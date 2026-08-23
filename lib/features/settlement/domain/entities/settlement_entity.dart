import 'package:equatable/equatable.dart';

enum SettlementStatus {
  pendingApproval('PENDING_APPROVAL'),
  approved('APPROVED');

  const SettlementStatus(this.value);

  final String value;

  static SettlementStatus fromValue(String value) => values.firstWhere(
        (s) => s.value == value,
        orElse: () => SettlementStatus.pendingApproval,
      );
}

class DailyCashSummary extends Equatable {
  const DailyCashSummary({
    required this.totalCashCollected,
    required this.successfulDeliveriesCount,
    required this.failedDeliveriesCount,
  });

  final double totalCashCollected;
  final int successfulDeliveriesCount;
  final int failedDeliveriesCount;

  bool get isSubmittable => successfulDeliveriesCount > 0;

  @override
  List<Object?> get props => [
        totalCashCollected,
        successfulDeliveriesCount,
        failedDeliveriesCount,
      ];
}

class SettlementEntity extends Equatable {
  const SettlementEntity({
    required this.id,
    required this.driverId,
    required this.date,
    required this.totalCashCollected,
    required this.successfulDeliveriesCount,
    required this.failedDeliveriesCount,
    required this.status,
    required this.createdAt,
    this.verifiedByManagerId,
  });

  final String id;
  final String driverId;
  final String date;
  final double totalCashCollected;
  final int successfulDeliveriesCount;
  final int failedDeliveriesCount;
  final SettlementStatus status;
  final DateTime createdAt;
  final String? verifiedByManagerId;

  @override
  List<Object?> get props => [
        id,
        driverId,
        date,
        totalCashCollected,
        status,
        createdAt,
      ];
}
