import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

enum OrderActionError { dialerFailed, gpsFailed, generic }

sealed class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitialState extends OrderState {
  const OrderInitialState();
}

class OrderLoadingState extends OrderState {
  const OrderLoadingState();
}

class OrderLoadedState extends OrderState {
  const OrderLoadedState(this.orders);

  final List<OrderEntity> orders;

  @override
  List<Object?> get props => [orders];
}

class OrderActionFailureState extends OrderState {
  const OrderActionFailureState(this.code, this.orders, [this.detail]);

  final OrderActionError code;
  final List<OrderEntity> orders;
  final String? detail;

  @override
  List<Object?> get props => [code, orders, detail];
}

class UnverifiedDeclinePromptState extends OrderState {
  const UnverifiedDeclinePromptState({
    required this.orderId,
    required this.reason,
    required this.clientPhone,
    required this.orders,
  });

  final String orderId;
  final FailureReason reason;
  final String clientPhone;
  final List<OrderEntity> orders;

  @override
  List<Object?> get props => [orderId, reason, clientPhone, orders];
}

class OrderFailureState extends OrderState {
  const OrderFailureState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
