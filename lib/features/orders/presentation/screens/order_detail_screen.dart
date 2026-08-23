import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/audit_timer_widget.dart';
import '../widgets/call_action_button.dart';
import '../widgets/order_status_chip.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderActionFailureState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ));
        }
      },
      builder: (context, state) {
        final current = _resolveOrder(state) ?? order;
        final busy = state is OrderActionFailureState &&
            state.message.contains('in progress');
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
              if (current.isAwaitingVerification && current.audit != null) ...[
                AuditTimerWidget(deadline: current.audit!.verificationDeadline),
                const SizedBox(height: 16),
              ],
              _CodPanel(order: current),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Customer',
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
                title: 'Financials',
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    _FinanceRow(
                        label: 'Item subtotal',
                        value:
                            Formatters.dzd(current.financials.itemSubtotal)),
                    _FinanceRow(
                        label: 'Shipping fee',
                        value:
                            Formatters.dzd(current.financials.shippingFee)),
                    const Divider(height: 18, color: Colors.white12),
                    _FinanceRow(
                        label: 'Total COD',
                        value: Formatters.dzd(
                            current.financials.totalCodAmount),
                        bold: true),
                    if (current.status == OrderStatus.deliveredPaid)
                      _FinanceRow(
                          label: 'Collected by driver',
                          value: Formatters.dzd(
                              current.financials.amountCollected),
                          highlight: true),
                  ],
                ),
              ),
              if (current.audit != null) ...[
                const SizedBox(height: 12),
                _AuditCard(audit: current.audit!),
              ],
              const SizedBox(height: 24),
            ],
          ),
          bottomNavigationBar:
              current.isActionable ? _ActionBar(orderId: current.id, clientPhone: current.client.phone, busy: busy) : null,
        );
      },
    );
  }

  OrderEntity? _resolveOrder(OrderState state) {
    final orders = switch (state) {
      OrderLoadedState(:final orders) => orders,
      OrderActionFailureState(:final orders) => orders,
      _ => null,
    };
    for (final o in orders ?? const <OrderEntity>[]) {
      if (o.id == order.id) return o;
    }
    return null;
  }
}

class _CodPanel extends StatelessWidget {
  const _CodPanel({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4F7DF9), const Color(0xFF2FD07A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CASH TO COLLECT ON DELIVERY',
              style: TextStyle(
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
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1)),
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
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: highlight ? const Color(0xFF2FD07A) : Colors.white54,
                  fontWeight: bold || highlight ? FontWeight.w700 : null)),
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
    return _SectionCard(
      title: 'Attempt audit trail',
      icon: Icons.fact_check_outlined,
      child: Column(
        children: [
          _FinanceRow(label: 'Reason', value: audit.reason.value, bold: true),
          _FinanceRow(
              label: 'Call initiated',
              value: Formatters.dateTime(audit.callInitiatedAt)),
          _FinanceRow(
              label: 'Call duration',
              value: '${audit.callDurationSeconds}s'),
          _FinanceRow(
              label: 'GPS fix',
              value:
                  '${audit.location.latitude.toStringAsFixed(5)}, ${audit.location.longitude.toStringAsFixed(5)}'),
          _FinanceRow(
              label: 'Accuracy radius',
              value: '±${audit.location.accuracyMeters.toStringAsFixed(1)} m'),
          _FinanceRow(
              label: 'Merchant intervened',
              value: audit.merchantIntervened ? 'YES' : 'NO'),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.orderId,
    required this.clientPhone,
    required this.busy,
  });

  final String orderId;
  final String clientPhone;
  final bool busy;

  void _openFailureSheet(BuildContext context) {
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
              const Text(
                'Report failed attempt',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your GPS position and call proof will be attached to the audit log.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
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
                    title: Text(switch (reason) {
                      FailureReason.unresponsive => 'Customer unresponsive',
                      FailureReason.refused => 'Customer refused delivery',
                      FailureReason.wrongAddress => 'Wrong / unreachable address',
                    }),
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
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
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
              onPressed:
                  busy ? null : () => context.read<OrderBloc>().add(CallInitiatedEvent(orderId: orderId, clientPhone: clientPhone)),
              label: '1. Call Customer',
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
              label: const Text('Delivered', maxLines: 1),
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
              label: const Text('Failed', maxLines: 1),
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
