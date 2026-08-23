import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../orders/domain/entities/order_entity.dart';
import '../../orders/domain/repositories/order_repository.dart';
import '../../orders/presentation/bloc/order_bloc.dart';
import '../../orders/presentation/bloc/order_event.dart';
import '../../orders/presentation/bloc/order_state.dart';
import '../../orders/presentation/widgets/audit_timer_widget.dart';

class MerchantShell extends StatefulWidget {
  const MerchantShell({super.key});

  @override
  State<MerchantShell> createState() => _MerchantShellState();
}

class _MerchantShellState extends State<MerchantShell> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const LoadPendingVerificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text(l10n.merchantSubtitle,
                style:
                    const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) => switch (state) {
          OrderLoadingState() =>
            const Center(child: CircularProgressIndicator()),
          OrderFailureState(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(message, textAlign: TextAlign.center),
              ),
            ),
          OrderLoadedState(:final orders) => orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_outlined,
                          size: 48, color: Colors.greenAccent),
                      const SizedBox(height: 12),
                      Text(l10n.noPendingVerifications),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final order in orders)
                      _PendingCard(order: order),
                  ],
                ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.order});

  final OrderEntity order;

  Future<void> _act(
    BuildContext context, {
    required bool override,
  }) async {
    final l10n = AppLocalizations.of(context);
    final repository = context.read<OrderRepository>();
    final messenger = ScaffoldMessenger.of(context);
    String? note;
    if (override) {
      note = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text(l10n.overrideButton),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.overrideNoteHint,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, controller.text.trim()),
                child: Text(l10n.overrideButton),
              ),
            ],
          );
        },
      );
      if (!context.mounted) return;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.confirmFailureButton),
          content:
              Text('${order.trackingNumber}: ${l10n.statusReturned}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.confirmFailureButton),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      if (override) {
        await repository.overrideToRedelivery(
            orderId: order.id, note: note);
      } else {
        await repository.confirmFailure(orderId: order.id, note: null);
      }
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(override
            ? l10n.redispatchToast(order.trackingNumber)
            : l10n.confirmedReturnToast(order.trackingNumber)),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final audit = order.audit;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF212B3D),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: (audit?.unverifiedReturn ?? false)
              ? Colors.redAccent
              : Colors.white10,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.client.name} • ${order.trackingNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (audit?.unverifiedReturn ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Text(
                      AppLocalizations.of(context).unverifiedBadge,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${order.client.commune}, ${order.client.wilaya}',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 6),
            Text(
              Formatters.dzd(order.financials.totalCodAmount),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFF2FD07A),
              ),
            ),
            if (audit != null) ...[
              const SizedBox(height: 8),
              AuditTimerWidget(deadline: audit.verificationDeadline),
              const SizedBox(height: 8),
              Text(
                'Reason: ${audit.reason.value} • '
                'Call: ${audit.callDurationSeconds}s • '
                'GPS ±${audit.location.accuracyMeters.toStringAsFixed(0)}m',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _act(context, override: false),
                    icon: const Icon(Icons.gavel),
                    label: Text(AppLocalizations.of(context).confirmFailureButton,
                        maxLines: 1),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: .6)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => _act(context, override: true),
                    icon: const Icon(Icons.undo),
                    label: Text(AppLocalizations.of(context).overrideButton,
                        maxLines: 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
