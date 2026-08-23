import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/call_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({
    required this.repository,
    required this.locationService,
    required this.callService,
    required this.settings,
  }) : super(const OrderInitialState()) {
    on<LoadDriverRunsheetEvent>(_onLoadRunsheet);
    on<LoadPendingVerificationsEvent>(_onLoadPendingVerifications);
    on<CallInitiatedEvent>(_onCallInitiated);
    on<AttemptDeliveryFailureEvent>(_onAttemptFailure);
    on<ConfirmUnverifiedDeclineEvent>(_onConfirmUnverifiedDecline);
    on<DismissUnverifiedPromptEvent>(_onDismissUnverifiedPrompt);
    on<DeliveryConfirmedEvent>(_onDeliveryConfirmed);
  }

  final OrderRepository repository;
  final LocationService locationService;
  final CallService callService;
  final AppSettings settings;

  final Map<String, DateTime> _callInitiations = {};
  List<OrderEntity> _latestOrders = const [];

  Future<void> _onLoadRunsheet(
    LoadDriverRunsheetEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoadingState());
    try {
      await emit.forEach(
        repository.watchDriverOrders(event.driverId),
        onData: (List<OrderEntity> orders) {
          _latestOrders = orders;
          return OrderLoadedState(orders);
        },
        onError: (Object err, StackTrace _) =>
            OrderFailureState(err.toString()),
      );
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }

  Future<void> _onLoadPendingVerifications(
    LoadPendingVerificationsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoadingState());
    try {
      await emit.forEach(
        repository.watchPendingVerifications(),
        onData: (List<OrderEntity> orders) {
          _latestOrders = orders;
          return OrderLoadedState(orders);
        },
        onError: (Object err, StackTrace _) =>
            OrderFailureState(err.toString()),
      );
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }

  Future<void> _onCallInitiated(
    CallInitiatedEvent event,
    Emitter<OrderState> emit,
  ) async {
    final launched = await callService.dialCustomer(event.clientPhone);
    if (!launched) {
      emit(const OrderActionFailureState(
        OrderActionError.dialerFailed,
        [],
      ));
      return;
    }
    _callInitiations[event.orderId] = DateTime.now();
    try {
      await repository.logCallAttempt(
        orderId: event.orderId,
        driverId: event.driverId,
        clientPhone: event.clientPhone,
        responseWindow: settings.driverStatusWindow,
      );
    } catch (_) {}
  }

  Future<void> _onAttemptFailure(
    AttemptDeliveryFailureEvent event,
    Emitter<OrderState> emit,
  ) async {
    final order = _findOrder(event.orderId);
    if (order == null) return;

    final initiatedAt =
        _callInitiations[event.orderId] ??
            DateTime.now().subtract(AppConstants.callLogLookbackWindow);

    try {
      final hasCalled = await callService.verifyOutboundCall(
        event.clientPhone,
        since: initiatedAt,
      );
      if (!hasCalled) {
        emit(UnverifiedDeclinePromptState(
          orderId: event.orderId,
          reason: event.reason,
          clientPhone: event.clientPhone,
          orders: _latestOrders,
        ));
        return;
      }
      await _reportFailure(
        orderId: event.orderId,
        reason: event.reason,
        clientPhone: event.clientPhone,
        initiatedAt: initiatedAt,
        verifiedCall: true,
        emit: emit,
      );
    } catch (e) {
      emit(_failureFrom(e));
    }
  }

  Future<void> _onConfirmUnverifiedDecline(
    ConfirmUnverifiedDeclineEvent event,
    Emitter<OrderState> emit,
  ) async {
    final initiatedAt =
        _callInitiations[event.orderId] ??
            DateTime.now().subtract(AppConstants.callLogLookbackWindow);
    try {
      await _reportFailure(
        orderId: event.orderId,
        reason: event.reason,
        clientPhone: event.clientPhone,
        initiatedAt: initiatedAt,
        verifiedCall: false,
        emit: emit,
      );
    } catch (e) {
      emit(_failureFrom(e));
    }
  }

  Future<void> _onDismissUnverifiedPrompt(
    DismissUnverifiedPromptEvent event,
    Emitter<OrderState> emit,
  ) async {
    _callInitiations.clear();
    emit(OrderLoadedState(event.orders));
  }

  Future<void> _reportFailure({
    required String orderId,
    required FailureReason reason,
    required String clientPhone,
    required DateTime initiatedAt,
    required bool verifiedCall,
    required Emitter<OrderState> emit,
  }) async {
    final order = _findOrder(orderId);
    if (order == null) return;

    try {
      final gps = await locationService.getCurrentPosition();
      final now = DateTime.now();
      final callDuration =
          now.difference(initiatedAt).inSeconds.clamp(1, 7200);

      await repository.reportDeliveryFailure(
        orderId: orderId,
        reason: reason,
        callInitiatedAt: initiatedAt,
        callDurationSeconds: callDuration,
        latitude: gps.latitude,
        longitude: gps.longitude,
        accuracyMeters: gps.accuracyMeters,
        verificationWindow: settings.merchantVerificationWindow,
        verifiedCall: verifiedCall,
      );

      final audit = AttemptAudit(
        callInitiatedAt: initiatedAt,
        callDurationSeconds: callDuration,
        location: GpsLocation(
          latitude: gps.latitude,
          longitude: gps.longitude,
          accuracyMeters: gps.accuracyMeters,
        ),
        reason: reason,
        verificationDeadline:
            now.add(settings.merchantVerificationWindow),
        unverifiedReturn: !verifiedCall,
      );

      _latestOrders = _replaceOrder(order.copyWith(
        status: OrderStatus.failedPendingVerification,
        audit: audit,
        attempts: [...order.attempts, audit],
        clearDriverTimer: true,
        updatedAt: now,
      ));
      emit(OrderLoadedState(_latestOrders));
    } finally {
      _callInitiations.remove(orderId);
    }
  }

  Future<void> _onDeliveryConfirmed(
    DeliveryConfirmedEvent event,
    Emitter<OrderState> emit,
  ) async {
    final order = _findOrder(event.orderId);
    if (order == null) return;
    try {
      await repository.markDelivered(orderId: event.orderId);
      _latestOrders = _replaceOrder(order.copyWith(
        status: OrderStatus.deliveredPaid,
        financials: order.financials
            .copyWithAmountCollected(order.financials.totalCodAmount),
        clearDriverTimer: true,
        updatedAt: DateTime.now(),
      ));
      emit(OrderLoadedState(_latestOrders));
    } catch (e) {
      emit(_failureFrom(e));
    }
  }

  OrderActionFailureState _failureFrom(Object e) {
    if (e is GpsPermissionException || e is GpsServiceDisabledException) {
      return OrderActionFailureState(OrderActionError.gpsFailed, _latestOrders);
    }
    return OrderActionFailureState(
        OrderActionError.generic, _latestOrders, e.toString());
  }

  OrderEntity? _findOrder(String orderId) {
    for (final order in _latestOrders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  List<OrderEntity> _replaceOrder(OrderEntity updated) => _latestOrders
      .map((o) => o.id == updated.id ? updated : o)
      .toList(growable: false);
}

