# OrderPulse

[![CI](https://github.com/Nassim-sadi/orderpulse/actions/workflows/ci.yml/badge.svg)](https://github.com/Nassim-sadi/orderpulse/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/flutter-3.47-blue)
![Firebase](https://img.shields.io/badge/backend-firebase-orange)
![Tests](https://img.shields.io/badge/tests-39%20passing-green)

A driver-facing delivery app for cash-on-delivery e-commerce in markets like Algeria,
where most orders are paid in cash at the door and the biggest profit leak is drivers
marking orders as "customer unresponsive" without ever trying to reach them.

Every failed attempt has to be justified: the driver must have actually called the
customer (verified against the phone's call log), and their GPS position is recorded
at the moment they declare the failure. The order then sits in a 15-minute
pending-verification window before it is allowed to become a return.

## Why this exists

In COD-dominant markets, a fake return costs the store twice: outbound shipping and
return shipping, plus inventory locked in transit for weeks. Drivers have rational
incentives to skip hard addresses late in the day. OrderPulse makes skipping expensive:

- No failure report without an outbound call of non-zero duration to the exact customer number
- GPS coordinates and accuracy radius captured automatically with every failure declaration
- A 15-minute window in which a merchant can override the failure back to active delivery

## The state machine

```
PENDING -> CONFIRMED -> DISPATCHED -> OUT_FOR_DELIVERY
                                          |
                     +--------------------+---------------------+
                     v                                          v
             DELIVERED & PAID                FAILED_ATTEMPT_PENDING_VERIFICATION
                                             (15-min timer starts)
                                                  |                 |
                                     merchant overrides         timer expires
                                                  v                 v
                                          OUT_FOR_DELIVERY        RETURNED
```

The 15-minute expiry currently runs lazily on the device: whenever a run-sheet snapshot
loads an order whose deadline has passed, the repository writes `RETURNED` to Firestore.
Good enough for a demo; see limitations.

## Tech

| Layer      | Choice                                            |
|------------|---------------------------------------------------|
| App        | Flutter (Android-first), Material 3 dark theme    |
| State      | flutter_bloc, sealed events/states                |
| Backend    | Firebase Auth (email/password + Google), Cloud Firestore live snapshots |
| Native     | geolocator (GPS proof), call_log (call verification), url_launcher (dialer) |
| Testing    | flutter_test, bloc_test, mocktail, fake_cloud_firestore |

Feature-first layout under `lib/` (`app/`, `core/`, `features/auth|orders|settlement`),
with each feature split into `data / domain / presentation`. Repository interfaces are
the seam; everything above them does not know Firestore exists.

## Running it

Requirements: Flutter 3.x, an Android device or emulator (minSdk 23). The Firebase
config is already in place (`android/app/google-services.json`,
`lib/firebase_options.dart`), so there is nothing to generate.

```bash
flutter pub get
flutter run
```

Register a driver account through email/password or sign in with Google. On first login
the app seeds six demo orders around Batna (one of them deliberately sitting in a
verification window) so the run-sheet is never empty.

### Testing the anti-fraud gate on an emulator

1. Open an order and tap "Call Customer" - the native dialer opens
2. Use the emulator's extended controls (Phone) to call the customer's number and let it ring a few seconds
3. Now "Report Failed Attempt" will pass verification. Skip step 2 and you get blocked

Runtime permissions requested: fine location, phone (call log).

## Tests

```bash
flutter test
```

39 tests cover the fraud gate (blocked without a verified call, GPS attached, deadline
math), repository behavior against a fake Firestore (seeding idempotency, audit document
shape, automatic RETURNED transitions), phone-number normalization (including Algerian
+213 vs local 0-prefix forms - this was a real bug once), serialization round-trips, and
the settlement math.

## Distributing builds

Releases go out through Firebase App Distribution to the `drivers` tester group:

```bash
./scripts/distribute.sh                    # release APK
./scripts/distribute.sh debug "notes"      # debug APK with release notes
```

Add testers with:

```bash
firebase appdistribution:testers:add "email" --group-alias drivers --project=deliverymanager-ffaf1
```

## Known limitations

Written down on purpose, because this is a demo and pretending otherwise would be worse:

- **Expiry enforcement is client-side.** A driver could keep the app closed past the
  deadline. Real fix: a scheduled Cloud Function that sweeps expired deadlines.
- **Call-log and GPS checks are device-trust checks**, not truth. Rooted devices can fake
  both. Mitigations worth exploring: comparing reported location against route polyline,
  requiring the call to overlap geographically plausible timing, server-side re-verification.
- **Merchant side is not built here.** The intervention flow assumes someone watching a
  dashboard that does not exist yet; FCM alerts are stubbed behind `NotificationService`.
- **Release builds are signed with the debug keystore** - fine for tester installs, not
  for any store.
