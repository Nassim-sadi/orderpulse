import '../entities/order_entity.dart';

abstract interface class OrderRepository {
  Stream<List<OrderEntity>> watchDriverOrders(String driverId);

  Future<List<OrderEntity>> fetchDriverOrders(String driverId);

  Future<void> ensureDemoData({
    required String driverId,
    required String driverName,
    required String driverPhone,
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
  });

  Future<void> markDelivered({required String orderId});
}
