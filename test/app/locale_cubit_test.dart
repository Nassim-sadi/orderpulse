import 'package:cod_delivery_app/app/locale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleCubit', () {
    test('defaults to system locale when supported', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final cubit = LocaleCubit(prefs);
      expect(
        ['en', 'ar', 'fr'],
        contains(cubit.state.languageCode),
      );
    });

    test('falls back to English for unsupported system locales', () async {
      SharedPreferences.setMockInitialValues({'locale_code': 'xx'});
      final prefs = await SharedPreferences.getInstance();

      final cubit = LocaleCubit(prefs);
      expect(cubit.state, const Locale('en'));
    });

    test('restores persisted language choice', () async {
      SharedPreferences.setMockInitialValues({'locale_code': 'ar'});
      final prefs = await SharedPreferences.getInstance();

      final cubit = LocaleCubit(prefs);
      expect(cubit.state, const Locale('ar'));
    });

    test('setLanguage persists and emits the new locale', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs);

      await cubit.setLanguage('fr');

      expect(cubit.state, const Locale('fr'));
      expect(prefs.getString('locale_code'), 'fr');
    });

    test('ignores unsupported language codes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs);
      final before = cubit.state;

      await cubit.setLanguage('de');

      expect(cubit.state, before);
    });
  });
}
