import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/call_service.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({
    required this.repository,
    required this.locationService,
    required this.callService,
  }) : super(const OrderInitialState()) {
    on<LoadDriverRunsheetEvent>(_onLoadRunsheet);
    on<CallInitiatedEvent>(_onCallInitiated);
    on<AttemptDeliveryFailureEvent>(_onAttemptFailure);
    on<DeliveryConfirmedEvent>(_onDeliveryConfirmed);
  }

  final OrderRepository repository;
  final LocationService locationService;
  final CallService callService;

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

  Future<void> _onCallInitiated(
    CallInitiatedEvent event,
    Emitter<OrderState> emit,
  ) async {
    final launched = await callService.dialCustomer(event.clientPhone);
    if (!launched) {
      emit(OrderActionFailureState(
        'Could not open the phone dialer.',
        _latestOrders,
      ));
      return;
    }
    _callInitiations[event.orderId] = DateTime.now();
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
        emit(OrderActionFailureState(
          'Call Required: You must place a call to the customer '
          '(duration > 0s) before flagging a failed attempt.',
          _latestOrders,
        ));
        return;
      }

      final gps = await locationService.getCurrentPosition();

      await repository.reportDeliveryFailure(
        orderId: event.orderId,
        reason: event.reason,
        callInitiatedAt: initiatedAt,
        callDurationSeconds: DateTime.now()
                .difference(initiatedAt)
                .inSeconds
                .clamp(1, 7200),
        latitude: gps.latitude,
        longitude: gps.longitude,
        accuracyMeters: gps.accuracyMeters,
        verificationWindow: AppConstants.verificationWindow,
      );

      _latestOrders = _replaceOrder(order.copyWith(
        status: OrderStatus.failedPendingVerification,
        audit: AttemptAudit(
          callInitiatedAt: initiatedAt,
          callDurationSeconds: DateTime.now()
              .difference(initiatedAt)
              .inSeconds
              .clamp(1, 7200),
          location: GpsLocation(
            latitude: gps.latitude,
            longitude: gps.longitude,
            accuracyMeters: gps.accuracyMeters,
          ),
          reason: event.reason,
          verificationDeadline:
              DateTime.now().add(AppConstants.verificationWindow),
        ),
        updatedAt: DateTime.now(),
      ));
      emit(OrderLoadedState(_latestOrders));
    } catch (e) {
      emit(OrderActionFailureState(e.toString(), _latestOrders));
    } finally {
      _callInitiations.remove(event.orderId);
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
        updatedAt: DateTime.now(),
      ));
      emit(OrderLoadedState(_latestOrders));
    } catch (e) {
      emit(OrderActionFailureState(e.toString(), _latestOrders));
    }
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
