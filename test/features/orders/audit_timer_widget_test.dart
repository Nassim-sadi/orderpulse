import 'package:cod_delivery_app/features/orders/presentation/widgets/audit_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('compact timer shows live countdown', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuditTimerWidget(
            deadline: DateTime.now().add(const Duration(minutes: 5)),
            compact: true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final text = tester.widget<Text>(find.byType(Text)).data ?? '';
    expect(text, matches(RegExp(r'^\d{2}:\d{2}$')));
  });

  testWidgets('expired timer shows CLOSED in compact mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuditTimerWidget(
            deadline: DateTime.now().subtract(const Duration(minutes: 1)),
            compact: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('CLOSED'), findsOneWidget);
  });

  testWidgets('full banner explains merchant verification window',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuditTimerWidget(
            deadline: DateTime.now().add(const Duration(minutes: 10)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('MERCHANT VERIFICATION'), findsOneWidget);
    expect(find.textContaining('merchant has been alerted'),
        findsOneWidget);
  });
}
