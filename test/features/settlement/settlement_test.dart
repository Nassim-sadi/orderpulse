import 'package:cod_delivery_app/core/utils/formatters.dart';
import 'package:cod_delivery_app/features/settlement/data/models/settlement_model.dart';
import 'package:cod_delivery_app/features/settlement/domain/entities/settlement_entity.dart';
import 'package:cod_delivery_app/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:flutter_test/flutter_test.dart';

SettlementEntity _sample() => SettlementEntity(
      id: 'SETTL-20260822-99',
      driverId: 'drv_99',
      date: '2026-08-22',
      totalCashCollected: 48500,
      successfulDeliveriesCount: 11,
      failedDeliveriesCount: 2,
      status: SettlementStatus.pendingApproval,
      createdAt: DateTime.utc(2026, 8, 22, 19),
    );

void main() {
  group('SettlementModel', () {
    test('round-trips through a map', () {
      final restored =
          SettlementModel.fromMap('doc-1', SettlementModel.toMap(_sample()));

      expect(restored.id, 'doc-1');
      expect(restored.driverId, 'drv_99');
      expect(restored.totalCashCollected, 48500);
      expect(restored.successfulDeliveriesCount, 11);
      expect(restored.status, SettlementStatus.pendingApproval);
    });

    test('map matches spec schema keys', () {
      final map = SettlementModel.toMap(_sample());
      expect(map['settlement_id'], isNull);
      expect(map['driver_id'], 'drv_99');
      expect(map['status'], 'PENDING_APPROVAL');

      final mapWithId = SettlementModel.toMap(_sample(), docId: 'S1');
      expect(mapWithId['settlement_id'], 'S1');
    });

    test('tolerates missing fields', () {
      final s = SettlementModel.fromMap('doc-x', {});
      expect(s.driverId, '');
      expect(s.status, SettlementStatus.pendingApproval);
    });
  });

  group('DailyCashSummary', () {
    test('is submittable only with at least one delivery', () {
      const empty = DailyCashSummary(
          totalCashCollected: 0,
          successfulDeliveriesCount: 0,
          failedDeliveriesCount: 3);
      const good = DailyCashSummary(
          totalCashCollected: 12000,
          successfulDeliveriesCount: 4,
          failedDeliveriesCount: 1);

      expect(empty.isSubmittable, isFalse);
      expect(good.isSubmittable, isTrue);
    });
  });

  group('SettlementState.hasSubmittedToday', () {
    test('is true when a settlement dated today exists', () {
      final today = Formatters.isoDate(DateTime.now());
      final state = SettlementState(settlements: [
        SettlementEntity(
          id: 'S',
          driverId: 'drv_99',
          date: today,
          totalCashCollected: 100,
          successfulDeliveriesCount: 1,
          failedDeliveriesCount: 0,
          status: SettlementStatus.pendingApproval,
          createdAt: DateTime.now(),
        ),
      ]);

      expect(state.hasSubmittedToday, isTrue);
    });

    test('is false when only older settlements exist', () {
      final state = SettlementState(settlements: [
        SettlementEntity(
          id: 'S',
          driverId: 'drv_99',
          date: '2020-01-01',
          totalCashCollected: 100,
          successfulDeliveriesCount: 1,
          failedDeliveriesCount: 0,
          status: SettlementStatus.approved,
          createdAt: DateTime(2020),
        ),
      ]);

      expect(state.hasSubmittedToday, isFalse);
      expect(const SettlementState().hasSubmittedToday, isFalse);
    });
  });
}
