import 'package:cod_delivery_app/features/orders/presentation/widgets/audit_timer_widget.dart';
import 'package:cod_delivery_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('compact timer shows live countdown', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AuditTimerWidget(
          deadline: DateTime.now().add(const Duration(minutes: 5)),
          compact: true,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final text = tester.widget<Text>(find.byType(Text)).data ?? '';
    expect(text, matches(RegExp(r'^\d{2}:\d{2}$')));
  });

  testWidgets('expired timer shows window-closed label in compact mode',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        AuditTimerWidget(
          deadline: DateTime.now().subtract(const Duration(minutes: 1)),
          compact: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('VERIFICATION WINDOW CLOSED'), findsOneWidget);
  });

  testWidgets('full banner explains merchant verification window',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        AuditTimerWidget(
          deadline: DateTime.now().add(const Duration(minutes: 10)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('MERCHANT VERIFICATION'), findsOneWidget);
    expect(find.textContaining('merchant has been alerted'),
        findsOneWidget);
  });
}
