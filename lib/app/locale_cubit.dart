import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(_resolveInitial(_prefs));

  static const String _prefKey = 'locale_code';
  static const List<String> supportedCodes = ['en', 'ar', 'fr'];

  final SharedPreferences _prefs;

  static Locale _resolveInitial(SharedPreferences prefs) {
    final saved = prefs.getString(_prefKey);
    if (saved != null && supportedCodes.contains(saved)) {
      return Locale(saved);
    }
    final system =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return supportedCodes.contains(system) ? Locale(system) : const Locale('en');
  }

  Future<void> setLanguage(String code) async {
    if (!supportedCodes.contains(code)) return;
    await _prefs.setString(_prefKey, code);
    emit(Locale(code));
  }
}
