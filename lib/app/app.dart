import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/app_colors.dart';
import '../l10n/generated/app_localizations.dart';
import 'auth_gate.dart';
import 'locale_cubit.dart';
import 'routes.dart';

class OrderPulseApp extends StatelessWidget {
  const OrderPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) => MaterialApp(
        title: 'OrderPulse',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: const CardThemeData(color: AppColors.card),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.primary),
            ),
            labelStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        ),
        onGenerateRoute: onGenerateRoute,
        home: const AuthGate(),
      ),
    );
  }
}
