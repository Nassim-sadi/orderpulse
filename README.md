# OrderPulse

[![CI](https://github.com/Nassim-sadi/orderpulse/actions/workflows/ci.yml/badge.svg)](https://github.com/Nassim-sadi/orderpulse/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/flutter-3.47-blue)
![Firebase](https://img.shields.io/badge/backend-firebase-orange)
![Tests](https://img.shields.io/badge/tests-61%20passing-green)
![Languages](https://img.shields.io/badge/i18n-en%20%7C%20ar%20%7C%20fr-purple)

A driver-facing delivery app for cash-on-delivery e-commerce in markets like Algeria,
where most orders are paid in cash at the door and the biggest profit leak is drivers
marking orders as "customer unresponsive" without ever trying to reach them.

Every failed attempt has to be justified: the driver must have actually called the
customer (verified against the phone's call log), their GPS position is recorded at the
moment they declare the failure, and a merchant gets a live window to veto the return.
Skipping is now expensive in three ways - verification friction, merchant oversight,
and a trust score that drops with every suspicious report.

## Why this exists

In COD-dominant markets, a fake return costs the store twice: outbound shipping and
return shipping, plus inventory locked in transit for weeks. Drivers have rational
incentives to skip hard addresses late in the day. OrderPulse makes skipping expensive:

- No failure report without an outbound call of non-zero duration to the exact customer number
- GPS coordinates and accuracy radius captured automatically with every failure declaration
- A merchant verification window (default 15 min) in which the failure can be confirmed or overridden
- An unverified decline path for honest edge cases (phone dead, wrong number) - allowed, but flagged, alerted and penalized
- A driver response timer after every call so silence is also visible
- A trust score per driver: -5 unverified decline, -5 missed response window, -10 proven lie

## The state machine

```
PENDING -> CONFIRMED -> DISPATCHED -> OUT_FOR_DELIVERY
                                          |
              "Call customer" tapped ---->  response timer (default 10 min)
              "Report failure" --------->  FAILED_ATTEMPT_PENDING_VERIFICATION
                                           + notification to merchant
                                                |                    |
                                   merchant confirms          merchant overrides
                                   failure                    (or window expires)
                                                v                    v
                                            RETURNED           OUT_FOR_DELIVERY (-10 if lie proven)

Unverified decline (no call / zero-second call):
  confirmation dialog -> flagged attempt -> high-severity alert -> auto-RETURNED
  after the merchant window unless overridden (-5 trust either way)
```

Every outcome writes a document to the `notifications` collection - delivered included -
so a merchant console can show a single live feed of everything happening in the field.

Each failure appends to an immutable `attempts[]` history array on the order. When a
merchant overrides and re-dispatches, the evidence from round one survives into round two.

## Two timers, one config doc

| Timer | Default | Starts | Expires to |
|-------|---------|--------|------------|
| Driver response | 10 min | Driver taps "Call customer" | `driver_no_response` alert + `-5` trust |
| Merchant verification | 15 min | Any failure report | Auto `RETURNED` + `returned_auto` alert |

Both windows are read from the Firestore document `config/app_settings`
(`driver_status_window_minutes`, `verification_window_minutes`) with sane defaults baked
into `AppConstants`. Merchants can change them from the in-app Settings page without a
release; changes apply to orders reported afterwards. Bounds are enforced client-side
(1-120 min response, 1-240 min verification) and out-of-range remote values are ignored.

## Merchant simulator

The same APK doubles as the merchant console. Sign in with:

```
email:    merchant@orderpulse.app
password: merchant123
```

You land on the Merchant Console instead of the run-sheet: a live list of orders in
their verification window, each with the audit trail (call duration, GPS fix, reason),
a countdown chip, and two actions - **Confirm failure** (immediate return) or
**Override -> re-dispatch** with an optional note (order goes back to
`OUT_FOR_DELIVERY`, driver loses 10 trust points).

## Languages

English, Arabic (full RTL) and French. Switchable from the login screen or Settings;
the choice persists locally. All user-facing strings live in ARB files under `lib/l10n/`.

## Tech

| Layer      | Choice                                            |
|------------|---------------------------------------------------|
| App        | Flutter (Android-first), Material 3 dark theme    |
| State      | flutter_bloc, sealed events/states                |
| Backend    | Firebase Auth (email/password + Google), Cloud Firestore live snapshots |
| Native     | geolocator (GPS proof), call_log (call verification), url_launcher (dialer) |
| i18n       | flutter_localizations + generated ARB catalogs    |
| Testing    | flutter_test, bloc_test, mocktail, fake_cloud_firestore |

Feature-first layout under `lib/` (`app/`, `core/`, `features/auth|orders|settlement|settings`),
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

1. Add a Google account on the emulator first (Settings > Accounts) or Google sign-in will explain itself
2. Open an order and tap "Call Customer" - the native dialer opens
3. Use the emulator's extended controls (Phone) to call the customer's number and let it ring a few seconds
4. Now "Report Failed Attempt" will pass verification. Skip step 3 and you get a confirmation dialog offering the flagged unverified-decline path instead

Runtime permissions requested: fine location, phone (call log).

## Tests

```bash
flutter test
```

61 tests cover the fraud gate (blocked without a verified call, GPS attached, deadline
math), repository behavior against a fake Firestore (call-attempt logging and response
windows, verified vs unverified declines with notifications and penalties, merchant
override/confirm flows, both lazy expiry paths), settings fallbacks and range clamps,
locale persistence, auth error mapping (including Google-account diagnostics), phone-number
normalization (including Algerian +213 vs local 0-prefix forms - this was a real bug once),
serialization round-trips, widget behavior of the countdown timer, and the settlement math.

## Security rules

Firestore is not open: `firestore.rules` requires authentication for everything, scopes
driver profile writes to the owner, and gates order/settlement/notification/config access
behind signed-in users. Deployed with:

```bash
firebase deploy --only firestore:rules --project=deliverymanager-ffaf1
```

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
  both. Same for the trust score: penalties are applied by the client, so a modified APK
  could skip them. Real fix: Cloud Functions applying penalties server-side on write.
- **Merchant alerts are polled**, not pushed - the console listens to live Firestore
  snapshots but there are no FCM push notifications yet.
- **The notifications feed is unbounded** and has no read-state tracking yet.
- **Release builds are signed with the debug keystore** - fine for tester installs, not
  for any store.
