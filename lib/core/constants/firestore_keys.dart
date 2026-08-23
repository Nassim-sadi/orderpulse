abstract final class FirestoreCollections {
  static const orders = 'orders';
  static const settlements = 'cash_settlements';
  static const drivers = 'drivers';
  static const notifications = 'notifications';
  static const callAttempts = 'call_attempts';
  static const config = 'config';
}

abstract final class OrderKeys {
  static const orderId = 'order_id';
  static const trackingNumber = 'tracking_number';
  static const clientDetails = 'client_details';
  static const name = 'name';
  static const phone = 'phone';
  static const wilaya = 'wilaya';
  static const commune = 'commune';
  static const streetAddress = 'street_address';
  static const financials = 'financials';
  static const itemSubtotal = 'item_subtotal';
  static const shippingFee = 'shipping_fee';
  static const totalCodAmount = 'total_cod_amount';
  static const amountCollected = 'amount_collected';
  static const status = 'status';
  static const assignedDriver = 'assigned_driver';
  static const driverId = 'driver_id';
  static const driverName = 'driver_name';
  static const driverPhone = 'driver_phone';
  static const attemptAudit = 'attempt_audit';
  static const attempts = 'attempts';
  static const callInitiatedAt = 'call_initiated_at';
  static const callDurationSeconds = 'call_duration_seconds';
  static const unverifiedReturn = 'unverified_return';
  static const callAttemptsCount = 'call_attempts_count';
  static const driverResponseDeadline = 'driver_response_deadline';
  static const driverResponseExpiredAt = 'driver_response_expired_at';
  static const driverLocation = 'driver_location';
  static const latitude = 'latitude';
  static const longitude = 'longitude';
  static const accuracyMeters = 'accuracy_meters';
  static const driverReason = 'driver_reason';
  static const verificationDeadline = 'verification_deadline';
  static const merchantIntervened = 'merchant_intervened';
  static const overrideNote = 'override_note';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

abstract final class SettlementKeys {
  static const settlementId = 'settlement_id';
  static const driverId = 'driver_id';
  static const date = 'date';
  static const totalCashCollected = 'total_cash_collected';
  static const successfulDeliveriesCount = 'successful_deliveries_count';
  static const failedDeliveriesCount = 'failed_deliveries_count';
  static const settlementStatus = 'status';
  static const verifiedByManagerId = 'verified_by_manager_id';
  static const createdAt = 'created_at';
}

abstract final class DriverKeys {
  static const name = 'name';
  static const phone = 'phone';
  static const email = 'email';
  static const role = 'role';
  static const trustScore = 'trust_score';
  static const createdAt = 'created_at';
}

abstract final class NotificationKeys {
  static const type = 'type';
  static const orderId = 'order_id';
  static const severity = 'severity';
  static const message = 'message';
  static const driverId = 'driver_id';
  static const createdAt = 'created_at';
}

abstract final class CallAttemptKeys {
  static const orderId = 'order_id';
  static const driverId = 'driver_id';
  static const clientPhone = 'client_phone';
  static const createdAt = 'created_at';
}

abstract final class ConfigDoc {
  static const id = 'app_settings';
  static const driverStatusWindowMinutes = 'driver_status_window_minutes';
  static const verificationWindowMinutes = 'verification_window_minutes';
}
