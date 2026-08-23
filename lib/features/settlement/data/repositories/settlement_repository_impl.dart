import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../models/settlement_model.dart';

class FirestoreSettlementRepository implements SettlementRepository {
  FirestoreSettlementRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _settlements =>
      _firestore.collection(FirestoreCollections.settlements);

  @override
  Stream<List<SettlementEntity>> watchDriverSettlements(String driverId) {
    return _settlements
        .where(SettlementKeys.driverId, isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
      final settlements = snapshot.docs
          .map((doc) => SettlementModel.fromMap(doc.id, doc.data()))
          .toList();
      settlements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return settlements;
    });
  }

  @override
  Future<void> submitDailySettlement({
    required String driverId,
    required DailyCashSummary summary,
  }) async {
    final now = DateTime.now();
    final docRef = _settlements.doc(
        'SETTL-${Formatters.isoDate(now).replaceAll('-', '')}-${now.millisecondsSinceEpoch % 1000}');
    await docRef.set(SettlementModel.toMap(
      SettlementEntity(
        id: docRef.id,
        driverId: driverId,
        date: Formatters.isoDate(now),
        totalCashCollected: summary.totalCashCollected,
        successfulDeliveriesCount: summary.successfulDeliveriesCount,
        failedDeliveriesCount: summary.failedDeliveriesCount,
        status: SettlementStatus.pendingApproval,
        createdAt: now,
      ),
      docId: docRef.id,
    ));
  }
}
