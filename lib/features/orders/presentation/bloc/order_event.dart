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

class CallInitiatedEvent extends OrderEvent {
  const CallInitiatedEvent({required this.orderId, required this.clientPhone});

  final String orderId;
  final String clientPhone;

  @override
  List<Object?> get props => [orderId, clientPhone];
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

class DeliveryConfirmedEvent extends OrderEvent {
  const DeliveryConfirmedEvent(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
