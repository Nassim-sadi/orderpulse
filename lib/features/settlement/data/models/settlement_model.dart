import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/settlement_entity.dart';

class SettlementModel {
  const SettlementModel._();

  static SettlementEntity fromMap(String id, Map<String, dynamic> map) =>
      SettlementEntity(
        id: id,
        driverId: map[SettlementKeys.driverId] as String? ?? '',
        date: map[SettlementKeys.date] as String? ?? '',
        totalCashCollected:
            (map[SettlementKeys.totalCashCollected] as num?)?.toDouble() ?? 0,
        successfulDeliveriesCount:
            (map[SettlementKeys.successfulDeliveriesCount] as num?)?.toInt() ?? 0,
        failedDeliveriesCount:
            (map[SettlementKeys.failedDeliveriesCount] as num?)?.toInt() ?? 0,
        status: SettlementStatus.fromValue(
            map[SettlementKeys.settlementStatus] as String? ?? ''),
        verifiedByManagerId:
            map[SettlementKeys.verifiedByManagerId] as String?,
        createdAt:
            DateTime.tryParse(map[SettlementKeys.createdAt] as String? ?? '') ??
                DateTime.now(),
      );

  static Map<String, dynamic> toMap(SettlementEntity s, {String? docId}) => {
        SettlementKeys.settlementId: ?docId,
        SettlementKeys.driverId: s.driverId,
        SettlementKeys.date: s.date,
        SettlementKeys.totalCashCollected: s.totalCashCollected,
        SettlementKeys.successfulDeliveriesCount:
            s.successfulDeliveriesCount,
        SettlementKeys.failedDeliveriesCount: s.failedDeliveriesCount,
        SettlementKeys.settlementStatus: s.status.value,
        SettlementKeys.verifiedByManagerId: s.verifiedByManagerId,
        SettlementKeys.createdAt: s.createdAt.toIso8601String(),
      };
}
