import '../entities/order_entity.dart';

abstract interface class OrderRepository {
  Stream<List<OrderEntity>> watchDriverOrders(String driverId);

  Future<List<OrderEntity>> fetchDriverOrders(String driverId);

  Stream<List<OrderEntity>> watchPendingVerifications();

  Future<void> ensureDemoData({
    required String driverId,
    required String driverName,
    required String driverPhone,
  });

  Future<void> logCallAttempt({
    required String orderId,
    required String driverId,
    required String clientPhone,
    required Duration responseWindow,
  });

  Future<void> reportDeliveryFailure({
    required String orderId,
    required FailureReason reason,
    required DateTime callInitiatedAt,
    required int callDurationSeconds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required Duration verificationWindow,
    required bool verifiedCall,
  });

  Future<void> markDelivered({required String orderId});

  Future<void> overrideToRedelivery({
    required String orderId,
    String? note,
  });

  Future<void> confirmFailure({
    required String orderId,
    String? note,
  });
}
