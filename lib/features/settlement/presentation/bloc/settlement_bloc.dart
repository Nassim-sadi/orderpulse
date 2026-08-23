import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import 'settlement_event.dart';
import 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  SettlementBloc({
    required this.settlementRepository,
    required this.orderRepository,
  }) : super(const SettlementState()) {
    on<LoadSettlementsRequested>(_onLoad);
    on<RefreshSummaryRequested>(_onRefreshSummary);
    on<SubmitDailySettlementRequested>(_onSubmit);

    _ordersRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        final driverId = _activeDriverId;
        if (driverId != null && !isClosed) {
          add(RefreshSummaryRequested(driverId));
        }
      },
    );
  }

  final SettlementRepository settlementRepository;
  final OrderRepository orderRepository;

  StreamSubscription<dynamic>? _settlementsSub;
  String? _activeDriverId;
  Timer? _ordersRefreshTimer;

  Future<void> _onLoad(
    LoadSettlementsRequested event,
    Emitter<SettlementState> emit,
  ) async {
    _activeDriverId = event.driverId;
    emit(state.copyWith(isLoading: true, clearError: true));
    await _settlementsSub?.cancel();
    try {
      await emit.forEach(
        settlementRepository.watchDriverSettlements(event.driverId),
        onData: (List<SettlementEntity> settlements) =>
            state.copyWith(isLoading: false, settlements: settlements),
        onError: (Object e, StackTrace _) => state.copyWith(
            isLoading: false,
            submitStatus: SettlementSubmitStatus.failure,
            errorMessage: e.toString()),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
    add(RefreshSummaryRequested(event.driverId));
  }

  Future<void> _onRefreshSummary(
    RefreshSummaryRequested event,
    Emitter<SettlementState> emit,
  ) async {
    try {
      final orders = await orderRepository.fetchDriverOrders(event.driverId);
      final today = DateTime.now();
      bool isToday(DateTime dt) =>
          dt.year == today.year &&
          dt.month == today.month &&
          dt.day == today.day;
      final delivered = orders
          .where((o) =>
              o.status == OrderStatus.deliveredPaid &&
              isToday(o.updatedAt))
          .toList();
      final failed = orders
          .where((o) =>
              o.status == OrderStatus.failedPendingVerification ||
              o.status == OrderStatus.returned)
          .length;
      emit(state.copyWith(
        summary: DailyCashSummary(
          totalCashCollected:
              delivered.fold<double>(0, (s, o) => s + o.financials.amountCollected),
          successfulDeliveriesCount: delivered.length,
          failedDeliveriesCount: failed,
        ),
      ));
    } catch (_) {}
  }

  Future<void> _onSubmit(
    SubmitDailySettlementRequested event,
    Emitter<SettlementState> emit,
  ) async {
    final summary = state.summary;
    if (summary == null || !summary.isSubmittable) return;
    emit(state.copyWith(submitStatus: SettlementSubmitStatus.submitting));
    try {
      await settlementRepository.submitDailySettlement(
        driverId: event.driverId,
        summary: summary,
      );
      emit(state.copyWith(submitStatus: SettlementSubmitStatus.success));
      add(RefreshSummaryRequested(event.driverId));
    } catch (e) {
      emit(state.copyWith(
        submitStatus: SettlementSubmitStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    unawaited(_settlementsSub?.cancel());
    _ordersRefreshTimer?.cancel();
    return super.close();
  }
}
