import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

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
  const OrderActionFailureState(this.message, this.orders);

  final String message;
  final List<OrderEntity> orders;

  @override
  List<Object?> get props => [message, orders];
}

class OrderFailureState extends OrderState {
  const OrderFailureState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
