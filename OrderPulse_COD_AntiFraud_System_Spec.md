# OrderPulse COD Delivery & Anti-Fraud Operations System
**Complete System Specification, Architectural Blueprint & Implementation Guide**

---

## 1. Executive Summary & Business Domain

In Cash on Delivery (COD) dominant markets (such as North Africa and the Levant), e-commerce merchants face critical operational bottlenecks during the last-mile delivery phase:

1. **Driver Slacking & Fraudulent Returns:** Delivery agents frequently flag packages as *"Customer Unresponsive"* or *"Customer Refused"* without attempting contact, often due to route inefficiencies, distance, or time constraints.
2. **High Return Rates (RTO):** Excessive fake returns incur double shipping fees (outbound + return), tie up inventory, and decrease overall profitability.
3. **Cash Reconciliation Gaps:** Merchants lack real-time visibility into cash held by delivery drivers, creating financial liability and delays in store cash flow.

**OrderPulse** solves these challenges by providing an internal operations mobile application for delivery drivers and field agents, backed by a real-time **15-Minute Re-Engagement & Anti-Fraud Engine**. This system forces driver accountability through native phone call verification and GPS tagging, while instantly notifying merchants to intervene before an order is permanently marked as returned.

---

## 2. Complete System Architecture

```
                                    +-----------------------------------+
                                    |   Store Frontends / CMS           |
                                    |   (WooCommerce, Laravel, Shopify) |
                                    +-----------------+-----------------+
                                                      |
                                                      | (REST / Webhooks)
                                                      v
                                    +-----------------------------------+
                                    |    Firebase Cloud Infrastructure   |
                                    |  - Firestore NoSQL Database       |
                                    |  - Firebase Cloud Messaging (FCM) |
                                    |  - Firebase Authentication        |
                                    +--------+-----------------+--------+
                                             |                 ^
                        Real-Time WebSockets |                 | Write Audit Logs & State
                                             v                 |
+--------------------------------------------------+     +-----+------------------------------------+
|  Flutter Delivery Agent App (Field Operations)   |     |  Merchant Web Dashboard / Intervention   |
|  - Driver Run-Sheet & Route Navigation           |     |  - Real-Time FCM Alerts                  |
|  - Native Telephony & Call Duration Validation   |     |  - 15-Min Customer Re-dial Module        |
|  - GPS Proof of Presence Capture                 |     |  - State Override & Dispatch Management |
|  - COD Cash Handover Ledger                      |     |  - Driver Performance Analytics          |
+--------------------------------------------------+     +------------------------------------------+
```

---

## 3. Core Operational Workflows & State Machine

### 3.1 Order Lifecycle State Machine

An order moves through strict, non-reversible states unless explicitly overridden by an authenticated store manager or merchant:

```
[ PENDING ] ---> [ CONFIRMED ] ---> [ DISPATCHED ] ---> [ OUT_FOR_DELIVERY ]
                                                                |
                                        +-----------------------+-----------------------+
                                        |                                               |
                                        v                                               v
                             [ DELIVERED & PAID ]                    [ FAILED_ATTEMPT_PENDING_VERIFICATION ]
                                        |                                               |
                                        v                               (Starts 15-Min Timer & FCM Alert)
                              (Cash Logged to Driver)                                   |
                                                                        +---------------+---------------+
                                                                        |                               |
                                                                (Merchant Recalls)             (Timer Expires / Confirmed)
                                                                        v                               v
                                                             [ OUT_FOR_DELIVERY ]                  [ RETURNED ]
                                                               (Re-scheduled)                 (Stock Restocked)
```

### 3.2 Anti-Fraud Delivery Workflow (Step-by-Step)

1. **Initiate Contact:** The driver taps the **"Call Customer"** button inside the Order Detail view. The app opens the native phone dialer with the customer's phone number pre-filled.
2. **Call Duration Validation:** The system queries native telephony APIs (`call_log` plugin) upon returning to the app. If `duration == 0 seconds`, the driver is blocked from selecting failure states.
3. **GPS Proof Capture:** If the call fails, the driver selects the failure reason (*Unresponsive*, *Refused*, *Wrong Address*). The app automatically fetches high-accuracy GPS coordinates (`geolocator` plugin).
4. **Transition to Pending Verification:** The order state changes to `FAILED_ATTEMPT_PENDING_VERIFICATION`. A 15-minute countdown is attached to the document.
5. **Real-time Merchant Alert:** Firebase Cloud Messaging (FCM) triggers an urgent push notification to the merchant dashboard.
6. **Merchant Intervention:** 
   * **Scenario A (Driver Slacked):** Merchant calls customer. Customer answers and states driver never arrived. Merchant overrides state back to `OUT_FOR_DELIVERY` and flags driver.
   * **Scenario B (Genuine Refusal):** Merchant confirms customer refusal or 15-minute timer expires without intervention. Order transitions to `RETURNED`.

---

## 4. Firestore Database Schema Design

### Collection: `orders`

```json
{
  "order_id": "ORD-2026-9901",
  "tracking_number": "TRK-884192",
  "client_details": {
    "name": "Yacine Belkacem",
    "phone": "0550123456",
    "wilaya": "Batna",
    "commune": "Bouakal",
    "street_address": "Route de Biskra, Cité 102 Logements"
  },
  "financials": {
    "item_subtotal": 4500.00,
    "shipping_fee": 600.00,
    "total_cod_amount": 5100.00,
    "amount_collected": 5100.00
  },
  "status": "FAILED_ATTEMPT_PENDING_VERIFICATION",
  "assigned_driver": {
    "driver_id": "drv_user_99",
    "driver_name": "Sofiane Benzine",
    "phone": "0661987654"
  },
  "attempt_audit": {
    "call_initiated_at": "2026-08-22T18:30:00Z",
    "call_duration_seconds": 24,
    "driver_location": {
      "latitude": 35.5558,
      "longitude": 6.1741,
      "accuracy_meters": 4.2
    },
    "driver_reason": "UNRESPONSIVE",
    "verification_deadline": "2026-08-22T18:45:00Z",
    "merchant_intervened": false,
    "override_note": null
  },
  "created_at": "2026-08-22T08:00:00Z",
  "updated_at": "2026-08-22T18:30:00Z"
}
```

### Collection: `cash_settlements`

```json
{
  "settlement_id": "SETTL-20260822-99",
  "driver_id": "drv_user_99",
  "date": "2026-08-22",
  "total_cash_collected": 48500.00,
  "successful_deliveries_count": 11,
  "failed_deliveries_count": 2,
  "status": "PENDING_APPROVAL",
  "verified_by_manager_id": null,
  "created_at": "2026-08-22T19:00:00Z"
}
```

---

## 5. Feature-First Flutter Project Architecture

```
lib/
├── app/
│   ├── app.dart                  # MaterialApp config, themes, global providers
│   └── routes.dart               # Navigation routes
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── firestore_keys.dart
│   ├── services/
│   │   ├── location_service.dart # Geolocator wrapper
│   │   ├── call_service.dart     # CallLog & UrlLauncher wrapper
│   │   └── notification_service.dart # FCM setup
│   └── utils/
│       └── formatters.dart       # Currency (DZD) & Timestamp formatters
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── orders/
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── order_model.dart
    │   │   └── repositories/
    │   │       └── order_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── order_entity.dart
    │   │   └── repositories/
    │   │       └── order_repository.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── order_bloc.dart
    │       │   ├── order_event.dart
    │       │   └── order_state.dart
    │       ├── screens/
    │       │   ├── driver_runsheet_screen.dart
    │       │   └── order_detail_screen.dart
    │       └── widgets/
    │           ├── audit_timer_widget.dart
    │           └── call_action_button.dart
    └── settlement/
        ├── data/
        ├── domain/
        └── presentation/
```

---

## 6. Implementation Specifications & Code Snippets

### 6.1 Order BLoC Implementation (`order_bloc.dart`)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/order_entity.dart';
import '../domain/repositories/order_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/call_service.dart';

// EVENTS
abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDriverRunsheetEvent extends OrderEvent {
  final String driverId;
  LoadDriverRunsheetEvent(this.driverId);
}

class AttemptDeliveryFailureEvent extends OrderEvent {
  final String orderId;
  final String reason;
  final String clientPhone;

  AttemptDeliveryFailureEvent({
    required this.orderId,
    required this.reason,
    required this.clientPhone,
  });
}

// STATES
abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitialState extends OrderState {}
class OrderLoadingState extends OrderState {}
class OrderLoadedState extends OrderState {
  final List<OrderEntity> orders;
  OrderLoadedState(this.orders);
}
class OrderFailureState extends OrderState {
  final String message;
  OrderFailureState(this.message);
}

// BLOC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository repository;
  final LocationService locationService;
  final CallService callService;

  OrderBloc({
    required this.repository,
    required this.locationService,
    required this.callService,
  }) : super(OrderInitialState()) {
    on<LoadDriverRunsheetEvent>(_onLoadRunsheet);
    on<AttemptDeliveryFailureEvent>(_onAttemptFailure);
  }

  Future<void> _onLoadRunsheet(
    LoadDriverRunsheetEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final stream = repository.getDriverOrdersStream(event.driverId);
      await emit.forEach(
        stream,
        onData: (orders) => OrderLoadedState(orders),
        onError: (err, stack) => OrderFailureState(err.toString()),
      );
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }

  Future<void> _onAttemptFailure(
    AttemptDeliveryFailureEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      // 1. Verify Outbound Call Log
      final hasCalled = await callService.verifyOutboundCall(event.clientPhone);
      if (!hasCalled) {
        emit(OrderFailureState("Call Required: You must call the customer before flagging a failure."));
        return;
      }

      // 2. Capture GPS Location
      final position = await locationService.getCurrentPosition();

      // 3. Commit Audit Record to Repository
      await repository.reportDeliveryFailure(
        orderId: event.orderId,
        reason: event.reason,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }
}
```

---

## 7. Technical Interview Preparation & Defense

When presenting this project in a technical interview, use these engineered answers to explain trade-offs and decisions:

### Q1: Why use BLoC over Riverpod or Provider for this app?
> **Answer:** *"I selected `flutter_bloc` because this application involves strict state transitions (e.g., verifying phone calls, checking GPS coordinates, and initiating a 15-minute verification window). BLoC enforces unidirectional data flow and clear separation of concerns, making state transitions predictable and easy to unit-test. Sealed classes and explicit events prevent invalid states like marking a package as failed without a location audit."*

### Q2: How does the app handle lost internet connectivity while the driver is in the field?
> **Answer:** *"Firestore's native offline persistence handles data caching out of the box. When a driver updates an order status offline, Firestore updates the local SQLite cache instantly, allowing the UI to react optimistically. Writes are queued locally and automatically pushed to the server once network connectivity is re-established."*

### Q3: What prevents a driver from spoofing their GPS or call logs?
> **Answer:** *"The app queries the OS telephony layer via platform channels (`call_log` plugin) to verify that an outbound call to the exact client phone number exists in the native call history with a duration greater than zero. For location, we sample the hardware GPS provider with high accuracy settings (`LocationAccuracy.high`) and store the accuracy confidence radius in meters alongside the timestamp."*

---

## 8. Development Roadmap & Execution Checklist

- [ ] **Step 1: Environment Setup**
  - Run `flutter config --jdk-dir "/opt/android-studio/jbr"`
  - Verify Gradle build with `flutter run` on Android Emulator.
- [ ] **Step 2: Firebase Integration**
  - Create project in Firebase Console.
  - Add Android app (`google-services.json`).
  - Enable Firestore Database & Authentication.
- [ ] **Step 3: Data Layer & Entities**
  - Create `OrderEntity` and `OrderModel` with `fromJson()` and `toMap()`.
  - Create `OrderRepository` interface and Firestore implementation.
- [ ] **Step 4: BLoC & Services**
  - Implement `LocationService` (Geolocator) and `CallService` (CallLog).
  - Implement `OrderBloc` with call validation logic.
- [ ] **Step 5: Presentation UI**
  - Build `DriverRunsheetScreen` with order status cards.
  - Build `OrderDetailScreen` with native call button and failure dialog.
- [ ] **Step 6: Real-Time Verification Test**
  - Trigger failure from driver emulator.
  - Verify state change and audit log in Firebase Console.
