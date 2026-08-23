import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/audit_timer_widget.dart';
import '../widgets/call_action_button.dart';
import '../widgets/order_status_chip.dart';

String _localizedReason(AppLocalizations l10n, FailureReason reason) =>
    switch (reason) {
      FailureReason.unresponsive => l10n.reasonUnresponsive,
      FailureReason.refused => l10n.reasonRefused,
      FailureReason.wrongAddress => l10n.reasonWrongAddress,
    };

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderActionFailureState) {
          final l10n = AppLocalizations.of(context);
          final message = switch (state.code) {
            OrderActionError.dialerFailed => l10n.errorDialerFailed,
            OrderActionError.gpsFailed => l10n.errorGpsFailed,
            OrderActionError.generic =>
              state.detail ?? l10n.errorGenericAction,
          };
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ));
        }
        if (state is UnverifiedDeclinePromptState) {
          _showUnverifiedDialog(context, state);
        }
      },
      builder: (context, state) {
        final current = _resolveOrder(state) ?? order;
        final busy = false;
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(current.trackingNumber),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(child: OrderStatusChip(status: current.status)),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (current.hasActiveResponseTimer &&
                  current.driverResponseDeadline != null) ...[
                _ResponseTimerBanner(
                    deadline: current.driverResponseDeadline!),
                const SizedBox(height: 16),
              ] else if (current.responseTimerExpired) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notification_important,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l10n.responseTimerExpiredChip,
                            style: const TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (current.isAwaitingVerification && current.audit != null) ...[
                AuditTimerWidget(deadline: current.audit!.verificationDeadline),
                const SizedBox(height: 16),
              ],
              _CodPanel(order: current),
              const SizedBox(height: 12),
              _SectionCard(
                title: l10n.customerSection,
                icon: Icons.person_outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(current.client.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.phone,
                        text: current.client.phone),
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        text:
                            '${current.client.streetAddress}, ${current.client.commune}'),
                    _InfoRow(
                        icon: Icons.map_outlined,
                        text:
                            '${current.client.wilaya} • ${current.id}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: l10n.financialsSection,
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    _FinanceRow(
                        label: l10n.itemSubtotal,
                        value:
                            Formatters.dzd(current.financials.itemSubtotal)),
                    _FinanceRow(
                        label: l10n.shippingFee,
                        value:
                            Formatters.dzd(current.financials.shippingFee)),
                    const Divider(height: 18, color: Colors.white12),
                    _FinanceRow(
                        label: l10n.totalCod,
                        value: Formatters.dzd(
                            current.financials.totalCodAmount),
                        bold: true),
                    if (current.status == OrderStatus.deliveredPaid)
                      _FinanceRow(
                          label: l10n.collectedByDriver,
                          value: Formatters.dzd(
                              current.financials.amountCollected),
                          highlight: true),
                  ],
                ),
              ),
              if (current.isActionable || current.callAttemptsCount > 0) ...[
                const SizedBox(height: 12),
                _SectionCard(
                  title: l10n.attemptedCallsRow,
                  icon: Icons.phone_in_talk_outlined,
                  child: Row(
                    children: [
                      for (var i = 0; i < current.callAttemptsCount; i++)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.call, size: 16, color: Color(0xFF2FD07A)),
                        ),
                      if (current.callAttemptsCount == 0)
                        Text(
                          '0',
                          style: TextStyle(
                              fontSize: 14, color: Colors.orange.shade300),
                        )
                      else
                        Text(
                          '${current.callAttemptsCount}',
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ],
              if (current.audit != null) ...[
                const SizedBox(height: 12),
                _AuditCard(audit: current.audit!),
              ],
              const SizedBox(height: 24),
            ],
          ),
          bottomNavigationBar: current.isActionable
              ? _ActionBar(
                  orderId: current.id,
                  driverId: current.assignedDriver.id,
                  clientPhone: current.client.phone,
                  busy: busy,
                )
              : null,
        );
      },
    );
  }

  void _showUnverifiedDialog(
    BuildContext context,
    UnverifiedDeclinePromptState state,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.unverifiedDialogTitle),
        content: Text(l10n.unverifiedDialogBody),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<OrderBloc>()
                  .add(DismissUnverifiedPromptEvent(state.orders));
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrderBloc>().add(ConfirmUnverifiedDeclineEvent(
                    orderId: state.orderId,
                    reason: state.reason,
                    clientPhone: state.clientPhone,
                  ));
            },
            child: Text(l10n.returnAnyway),
          ),
        ],
      ),
    );
  }

  OrderEntity? _resolveOrder(OrderState state) {
    final orders = switch (state) {
      OrderLoadedState(:final orders) => orders,
      OrderActionFailureState(:final orders) => orders,
      UnverifiedDeclinePromptState(:final orders) => orders,
      _ => null,
    };
    for (final o in orders ?? const <OrderEntity>[]) {
      if (o.id == order.id) return o;
    }
    return null;
  }
}

class _ResponseTimerBanner extends StatefulWidget {
  const _ResponseTimerBanner({required this.deadline});

  final DateTime deadline;

  @override
  State<_ResponseTimerBanner> createState() => _ResponseTimerBannerState();
}

class _ResponseTimerBannerState extends State<_ResponseTimerBanner> {
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
  void didUpdateWidget(covariant _ResponseTimerBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _remaining = widget.deadline.difference(DateTime.now());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4F7DF9).withValues(alpha: .14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4F7DF9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom,
              color: Color(0xFF4F7DF9), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.responseTimerTitle,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8)),
                Text(l10n.responseTimerBody,
                    style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatters.countdown(_remaining),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              fontFeatures: [FontFeature.tabularFigures()],
              color: Color(0xFF4F7DF9),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodPanel extends StatelessWidget {
  const _CodPanel({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4F7DF9), const Color(0xFF2FD07A)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.codPanelTitle,
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text(
            Formatters.dzd(order.financials.totalCodAmount),
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w900, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF212B3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  const _FinanceRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: highlight ? const Color(0xFF2FD07A) : Colors.white54,
                    fontWeight: bold || highlight ? FontWeight.w700 : null)),
          ),
          const SizedBox(width: 12),
          Text(value,
              style: TextStyle(
                  fontSize: bold || highlight ? 15 : 13,
                  color: highlight ? const Color(0xFF2FD07A) : Colors.white,
                  fontWeight: bold || highlight ? FontWeight.w800 : null)),
        ],
      ),
    );
  }
}

class _AuditCard extends StatelessWidget {
  const _AuditCard({required this.audit});

  final AttemptAudit audit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SectionCard(
      title: l10n.attemptAuditTrail,
      icon: Icons.fact_check_outlined,
      child: Column(
        children: [
          _FinanceRow(
              label: l10n.reasonRow,
              value: _localizedReason(l10n, audit.reason),
              bold: true),
          _FinanceRow(
              label: l10n.unverifiedFlagRow,
              value: audit.unverifiedReturn ? l10n.yes : l10n.no,
              highlight: audit.unverifiedReturn),
          _FinanceRow(
              label: l10n.callInitiatedRow,
              value: Formatters.dateTime(audit.callInitiatedAt)),
          _FinanceRow(
              label: l10n.callDurationRow,
              value: '${audit.callDurationSeconds}s'),
          _FinanceRow(
              label: l10n.gpsFixRow,
              value:
                  '${audit.location.latitude.toStringAsFixed(5)}, ${audit.location.longitude.toStringAsFixed(5)}'),
          _FinanceRow(
              label: l10n.accuracyRadiusRow,
              value: '±${audit.location.accuracyMeters.toStringAsFixed(1)} m'),
          _FinanceRow(
              label: l10n.merchantIntervenedRow,
              value: audit.merchantIntervened ? l10n.yes : l10n.no),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.orderId,
    required this.driverId,
    required this.clientPhone,
    required this.busy,
  });

  final String orderId;
  final String driverId;
  final String clientPhone;
  final bool busy;

  void _openFailureSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A2130),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.reportFailedAttemptTitle,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.auditNotice,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              for (final reason in FailureReason.values)
                Card(
                  color: const Color(0xFF212B3D),
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(switch (reason) {
                      FailureReason.unresponsive => Icons.phonelink_erase,
                      FailureReason.refused => Icons.block,
                      FailureReason.wrongAddress => Icons.wrong_location,
                    }),
                    title: Text(_localizedReason(l10n, reason)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.read<OrderBloc>().add(
                            AttemptDeliveryFailureEvent(
                              orderId: orderId,
                              reason: reason,
                              clientPhone: clientPhone,
                            ),
                          );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2130),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CallActionButton(
              onPressed: busy
                  ? null
                  : () => context.read<OrderBloc>().add(CallInitiatedEvent(
                        orderId: orderId,
                        driverId: driverId,
                        clientPhone: clientPhone,
                      )),
              label: l10n.actionCallCustomer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => context.read<OrderBloc>().add(
                        DeliveryConfirmedEvent(orderId),
                      ),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l10n.actionDelivered, maxLines: 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2FD07A),
                side: const BorderSide(color: Color(0xFF2FD07A)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed:
                  busy ? null : () => _openFailureSheet(context),
              icon: const Icon(Icons.report_problem_outlined),
              label: Text(l10n.actionFailed, maxLines: 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF4553E),
                side: BorderSide(color: const Color(0xFFF4553E).withValues(alpha: .6)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
