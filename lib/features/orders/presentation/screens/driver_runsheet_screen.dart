import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_state.dart';
import '../widgets/audit_timer_widget.dart';
import '../widgets/order_status_chip.dart';

class DriverRunsheetScreen extends StatelessWidget {
  const DriverRunsheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        return switch (state) {
          OrderLoadingState() => const Center(
              child: CircularProgressIndicator(),
            ),
          OrderFailureState(:final message) => _ErrorView(message: message),
          OrderLoadedState(:final orders) => _RunsheetList(orders: orders),
          OrderActionFailureState(:final orders) => _RunsheetList(
              orders: orders,
              bannerMessage: state.message,
            ),
          OrderInitialState() => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RunsheetList extends StatelessWidget {
  const _RunsheetList({required this.orders, this.bannerMessage});

  final List<OrderEntity> orders;
  final String? bannerMessage;

  @override
  Widget build(BuildContext context) {
    final deliveredToday = orders
        .where((o) => o.status == OrderStatus.deliveredPaid)
        .toList(growable: false);
    final cashCollected =
        deliveredToday.fold<double>(0, (sum, o) => sum + o.financials.amountCollected);
    final activeStops = orders.where((o) => o.isActionable).length;
    final awaiting = orders
        .where((o) => o.status == OrderStatus.failedPendingVerification)
        .toList(growable: false);

    final sections = <String, List<OrderEntity>>{
      'AWAITING VERIFICATION': awaiting,
      'ACTIVE RUN': orders
          .where((o) => o.isActionable)
          .toList(growable: false),
      'UPCOMING': orders
          .where((o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.confirmed)
          .toList(growable: false),
      'DELIVERED': deliveredToday,
      'RETURNED': orders
          .where((o) => o.status == OrderStatus.returned)
          .toList(growable: false),
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (bannerMessage != null) ...[
          Material(
            color: Colors.red.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bannerMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.local_shipping,
                label: 'Remaining stops',
                value: '$activeStops',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.payments,
                label: 'Cash collected',
                value: Formatters.dzd(cashCollected),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final entry in sections.entries)
          if (entry.value.isNotEmpty) ...[
            _SectionHeader(title: entry.key, count: entry.value.length),
            for (final order in entry.value)
              _OrderCard(order: order),
            const SizedBox(height: 6),
          ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
          Icon(icon, size: 18, color: Color(0xFF4F7DF9)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final cod = order.financials.totalCodAmount;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF212B3D),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            Navigator.pushNamed(context, '/order-detail', arguments: order),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OrderStatusChip(status: order.status),
                  Text(
                    Formatters.dzd(cod),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF2FD07A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.client.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                '${order.client.commune}, ${order.client.wilaya} • ${order.trackingNumber}',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              if (order.isAwaitingVerification &&
                  order.audit != null) ...[
                const SizedBox(height: 8),
                AuditTimerWidget(
                  deadline: order.audit!.verificationDeadline,
                  compact: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
