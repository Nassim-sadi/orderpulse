import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/settlement_entity.dart';
import '../bloc/settlement_bloc.dart';
import '../bloc/settlement_event.dart';
import '../bloc/settlement_state.dart';

class SettlementScreen extends StatelessWidget {
  const SettlementScreen({super.key, required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        final summary = state.summary;
        final submittedToday = state.hasSubmittedToday;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF212B3D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TODAY',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Colors.white38)),
                  const SizedBox(height: 10),
                  Text(
                    summary == null
                        ? '—'
                        : Formatters.dzd(summary.totalCashCollected),
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  const Text(
                      'Cash in hand to hand over at the depot',
                      style: TextStyle(fontSize: 12, color: Colors.white54)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _StatChip(
                          label:
                              '${summary?.successfulDeliveriesCount ?? 0} delivered'),
                      const SizedBox(width: 8),
                      _StatChip(
                          label:
                              '${summary?.failedDeliveriesCount ?? 0} failed/returned',
                          danger: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: (state.submitStatus ==
                                  SettlementSubmitStatus.submitting ||
                              !state.settlementsLoadedAndSubmittable)
                          ? null
                          : () => context.read<SettlementBloc>().add(
                                SubmitDailySettlementRequested(driverId),
                              ),
                      icon: state.submitStatus == SettlementSubmitStatus.submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(submittedToday ? Icons.check_circle : Icons.assignment_turned_in),
                      label: Text(
                        submittedToday
                            ? 'Settlement already submitted for today'
                            : 'Submit end-of-day settlement',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: submittedToday
                            ? Colors.green.withValues(alpha: .25)
                            : null,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (state.submitStatus == SettlementSubmitStatus.success &&
                      !submittedToday) ...[
                    const SizedBox(height: 8),
                    const Text(
                        'Submitted — awaiting manager approval.',
                        style: TextStyle(color: Color(0xFF2FD07A), fontSize: 12)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SETTLEMENT HISTORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (!state.isLoading && state.settlements.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No settlements yet.',
                      style: TextStyle(color: Colors.white38)),
                ),
              )
            else
              for (final s in state.settlements) _SettlementCard(s: s),
          ],
        );
      },
    );
  }
}

extension on SettlementState {
  bool get settlementsLoadedAndSubmittable {
    if (summary == null || !summary!.isSubmittable) return false;
    return !hasSubmittedToday;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, this.danger = false});

  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: danger
            ? const Color(0xFFF4553E).withValues(alpha: .15)
            : const Color(0xFF2FD07A).withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: danger ? const Color(0xFFF4553E) : const Color(0xFF2FD07A))),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({required this.s});

  final SettlementEntity s;

  @override
  Widget build(BuildContext context) {
    final pending = s.status == SettlementStatus.pendingApproval;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF212B3D),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: pending
              ? Colors.orange.withValues(alpha: .2)
              : Colors.green.withValues(alpha: .2),
          child: Icon(
            pending ? Icons.hourglass_top : Icons.verified,
            color: pending ? Colors.orange : Colors.green,
            size: 20,
          ),
        ),
        title: Text(Formatters.dzd(s.totalCashCollected),
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          '${s.date} • ${s.successfulDeliveriesCount} deliveries',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          pending ? 'PENDING' : 'APPROVED',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
            color: pending ? Colors.orange : Colors.green,
          ),
        ),
      ),
    );
  }
}
