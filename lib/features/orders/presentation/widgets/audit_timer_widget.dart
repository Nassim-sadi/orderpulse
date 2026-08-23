import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/formatters.dart';

class AuditTimerWidget extends StatefulWidget {
  const AuditTimerWidget({
    super.key,
    required this.deadline,
    this.compact = false,
    this.totalWindow,
  });

  final DateTime deadline;
  final bool compact;
  final Duration? totalWindow;

  @override
  State<AuditTimerWidget> createState() => _AuditTimerWidgetState();
}

class _AuditTimerWidgetState extends State<AuditTimerWidget> {
  late Duration _remaining;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _remaining = widget.deadline.difference(DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.deadline.difference(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expired = _remaining.isNegative;
    final window =
        widget.totalWindow ?? const Duration(minutes: 15);
    final progress = expired
        ? 0.0
        : (_remaining.inSeconds / window.inSeconds).clamp(0.0, 1.0);

    if (widget.compact) {
      return Chip(
        avatar: Icon(
          expired ? Icons.timer_off : Icons.timer,
          size: 16,
          color: expired ? Colors.redAccent : Colors.orange,
        ),
        label: Text(
          expired
              ? l10n.verificationWindowClosed
              : Formatters.countdown(_remaining),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        visualDensity: VisualDensity.compact,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: expired ? Colors.red.withValues(alpha: .12) : Colors.orange.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expired ? Colors.redAccent : Colors.orange,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  expired
                      ? l10n.verificationWindowClosed
                      : l10n.merchantVerification,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                    color: expired ? Colors.redAccent : Colors.orange,
                  ),
                ),
              ),
              Text(
                expired ? '--:--' : Formatters.countdown(_remaining),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: expired ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            backgroundColor: Colors.white24,
            color: expired ? Colors.redAccent : Colors.orange,
          ),
          const SizedBox(height: 10),
          Text(
            expired
                ? l10n.windowClosedMessage
                : l10n.merchantAlertedText,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
