import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadDriverRunsheetEvent extends OrderEvent {
  const LoadDriverRunsheetEvent(this.driverId);

  final String driverId;

  @override
  List<Object?> get props => [driverId];
}

class LoadPendingVerificationsEvent extends OrderEvent {
  const LoadPendingVerificationsEvent();
}

class CallInitiatedEvent extends OrderEvent {
  const CallInitiatedEvent({
    required this.orderId,
    required this.driverId,
    required this.clientPhone,
  });

  final String orderId;
  final String driverId;
  final String clientPhone;

  @override
  List<Object?> get props => [orderId, driverId, clientPhone];
}

class AttemptDeliveryFailureEvent extends OrderEvent {
  const AttemptDeliveryFailureEvent({
    required this.orderId,
    required this.reason,
    required this.clientPhone,
  });

  final String orderId;
  final FailureReason reason;
  final String clientPhone;

  @override
  List<Object?> get props => [orderId, reason, clientPhone];
}

class ConfirmUnverifiedDeclineEvent extends OrderEvent {
  const ConfirmUnverifiedDeclineEvent({
    required this.orderId,
    required this.reason,
    required this.clientPhone,
  });

  final String orderId;
  final FailureReason reason;
  final String clientPhone;

  @override
  List<Object?> get props => [orderId, reason, clientPhone];
}

class DismissUnverifiedPromptEvent extends OrderEvent {
  const DismissUnverifiedPromptEvent(this.orders);

  final List<OrderEntity> orders;

  @override
  List<Object?> get props => [orders];
}

class DeliveryConfirmedEvent extends OrderEvent {
  const DeliveryConfirmedEvent(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
