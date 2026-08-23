import '../entities/settlement_entity.dart';

abstract interface class SettlementRepository {
  Stream<List<SettlementEntity>> watchDriverSettlements(String driverId);

  Future<void> submitDailySettlement({
    required String driverId,
    required DailyCashSummary summary,
  });
}
