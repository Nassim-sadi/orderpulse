import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../constants/firestore_keys.dart';

abstract interface class AppSettings {
  Duration get driverStatusWindow;

  Duration get merchantVerificationWindow;
}

class SettingsService implements AppSettings {
  SettingsService(this._firestore);

  final FirebaseFirestore _firestore;

  Duration _driverWindow = AppConstants.driverStatusWindow;
  Duration _merchantWindow = AppConstants.verificationWindow;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection(FirestoreCollections.config).doc(ConfigDoc.id);

  @override
  Duration get driverStatusWindow => _driverWindow;

  @override
  Duration get merchantVerificationWindow => _merchantWindow;

  Future<void> warmUp() async {
    try {
      final snap = await _doc.get();
      if (!snap.exists || snap.data() == null) {
        await _doc.set(_defaults());
      } else {
        _apply(snap.data()!);
      }
    } catch (_) {}
    _subscription = _doc.snapshots().listen(
          (snap) {
            final data = snap.data();
            if (data != null) _apply(data);
          },
          onError: (_) {},
        );
  }

  Future<void> updateWindows({
    required int driverStatusMinutes,
    required int verificationMinutes,
  }) async {
    await _doc.set({
      ConfigDoc.driverStatusWindowMinutes: driverStatusMinutes,
      ConfigDoc.verificationWindowMinutes: verificationMinutes,
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _defaults() => {
        ConfigDoc.driverStatusWindowMinutes:
            AppConstants.driverStatusWindow.inMinutes,
        ConfigDoc.verificationWindowMinutes:
            AppConstants.verificationWindow.inMinutes,
      };

  void _apply(Map<String, dynamic> data) {
    final driver =
        (data[ConfigDoc.driverStatusWindowMinutes] as num?)?.toInt();
    final merchant =
        (data[ConfigDoc.verificationWindowMinutes] as num?)?.toInt();
    if (driver != null && driver >= 1 && driver <= 120) {
      _driverWindow = Duration(minutes: driver);
    }
    if (merchant != null && merchant >= 1 && merchant <= 240) {
      _merchantWindow = Duration(minutes: merchant);
    }
  }

  void dispose() {
    unawaited(_subscription?.cancel());
  }
}
