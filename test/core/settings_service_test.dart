import 'package:cod_delivery_app/core/constants/app_constants.dart';
import 'package:cod_delivery_app/core/constants/firestore_keys.dart';
import 'package:cod_delivery_app/core/services/settings_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SettingsService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = SettingsService(firestore);
  });

  group('SettingsService fallbacks', () {
    test('uses AppConstants defaults when the config doc does not exist',
        () async {
      await service.warmUp();

      expect(service.driverStatusWindow,
          AppConstants.driverStatusWindow);
      expect(service.merchantVerificationWindow,
          AppConstants.verificationWindow);
    });

    test('creates the config doc with defaults on first warm-up', () async {
      await service.warmUp();

      final doc = await firestore
          .collection(FirestoreCollections.config)
          .doc(ConfigDoc.id)
          .get();
      expect(doc.exists, isTrue);
      expect(
        doc.data()![ConfigDoc.driverStatusWindowMinutes],
        AppConstants.driverStatusWindow.inMinutes,
      );
    });

    test('adopts remote values and reacts to live updates', () async {
      await firestore
          .collection(FirestoreCollections.config)
          .doc(ConfigDoc.id)
          .set({
        ConfigDoc.driverStatusWindowMinutes: 5,
        ConfigDoc.verificationWindowMinutes: 30,
      });

      await service.warmUp();
      expect(service.driverStatusWindow, const Duration(minutes: 5));
      expect(service.merchantVerificationWindow, const Duration(minutes: 30));

      await service.updateWindows(
          driverStatusMinutes: 20, verificationMinutes: 10);
      expect(service.driverStatusWindow, const Duration(minutes: 20));
      expect(service.merchantVerificationWindow, const Duration(minutes: 10));
    });

    test('ignores out-of-range values from the remote document', () async {
      await firestore
          .collection(FirestoreCollections.config)
          .doc(ConfigDoc.id)
          .set({
        ConfigDoc.driverStatusWindowMinutes: -5,
        ConfigDoc.verificationWindowMinutes: 99999,
      });

      await service.warmUp();
      expect(service.driverStatusWindow, AppConstants.driverStatusWindow);
      expect(service.merchantVerificationWindow,
          AppConstants.verificationWindow);
    });
  });
}
