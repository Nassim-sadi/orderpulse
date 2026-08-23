// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OrderPulse';

  @override
  String get loginSubtitle => 'Driver Field Operations';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get newDriverPrompt => 'New driver? ';

  @override
  String get createAccount => 'Create an account';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get minSixCharacters => 'Minimum 6 characters';

  @override
  String get languageLabel => 'Language';

  @override
  String get langEnglish => 'English';

  @override
  String get langArabic => 'العربية';

  @override
  String get langFrench => 'Français';

  @override
  String get nameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get registerTitle => 'Create your driver account';

  @override
  String get registerButton => 'Register';

  @override
  String get haveAccountPrompt => 'Already have an account? ';

  @override
  String get signInInstead => 'Sign in';

  @override
  String get runSheetTab => 'Run-Sheet';

  @override
  String get cashTab => 'Cash';

  @override
  String get signOut => 'Sign out';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get driverRoleLabel => 'Driver';

  @override
  String get merchantRoleLabel => 'Merchant';

  @override
  String get logoutConfirmTitle => 'Sign out?';

  @override
  String get logoutConfirmBody =>
      'You will need to sign in again to access your run-sheet.';

  @override
  String get cancel => 'Cancel';

  @override
  String welcomeBackToast(Object name) {
    return 'Welcome back, $name';
  }

  @override
  String get signedOutToast => 'Signed out successfully.';

  @override
  String get remainingStops => 'Remaining stops';

  @override
  String get cashCollected => 'Cash collected';

  @override
  String get sectionAwaitingVerification => 'AWAITING VERIFICATION';

  @override
  String get sectionActiveRun => 'ACTIVE RUN';

  @override
  String get sectionUpcoming => 'UPCOMING';

  @override
  String get sectionDelivered => 'DELIVERED';

  @override
  String get sectionReturned => 'RETURNED';

  @override
  String get noCallYetBadge => 'NO CALL YET';

  @override
  String get customerSection => 'Customer';

  @override
  String get financialsSection => 'Financials';

  @override
  String get itemSubtotal => 'Item subtotal';

  @override
  String get shippingFee => 'Shipping fee';

  @override
  String get totalCod => 'Total COD';

  @override
  String get collectedByDriver => 'Collected by driver';

  @override
  String get codPanelTitle => 'CASH TO COLLECT ON DELIVERY';

  @override
  String get attemptAuditTrail => 'Attempt audit trail';

  @override
  String get reasonRow => 'Reason';

  @override
  String get callInitiatedRow => 'Call initiated';

  @override
  String get callDurationRow => 'Call duration';

  @override
  String get gpsFixRow => 'GPS fix';

  @override
  String get accuracyRadiusRow => 'Accuracy radius';

  @override
  String get merchantIntervenedRow => 'Merchant intervened';

  @override
  String get yes => 'YES';

  @override
  String get no => 'NO';

  @override
  String get unverifiedFlagRow => 'UNVERIFIED DECLINE';

  @override
  String get attemptedCallsRow => 'Attempted calls';

  @override
  String get responseTimerTitle => 'REPORT OUTCOME WITHIN';

  @override
  String get responseTimerBody =>
      'The merchant is waiting for your delivery outcome. Report Delivered or Failed before the timer ends.';

  @override
  String get responseTimerExpiredChip => 'NO RESPONSE';

  @override
  String get verificationWindowClosed => 'VERIFICATION WINDOW CLOSED';

  @override
  String get windowClosedMessage =>
      'No merchant intervention. This order can now be processed as returned.';

  @override
  String get merchantVerification => 'MERCHANT VERIFICATION';

  @override
  String get merchantAlertedText =>
      'The merchant has been alerted and can override this failure before the timer ends.';

  @override
  String get actionCallCustomer => '1. Call Customer';

  @override
  String get actionDelivered => 'Delivered';

  @override
  String get actionFailed => 'Failed';

  @override
  String get reportFailedAttemptTitle => 'Report failed attempt';

  @override
  String get auditNotice =>
      'Your GPS position and call proof will be attached to the audit log.';

  @override
  String get reasonUnresponsive => 'Customer unresponsive';

  @override
  String get reasonRefused => 'Customer refused delivery';

  @override
  String get reasonWrongAddress => 'Wrong / unreachable address';

  @override
  String get unverifiedDialogTitle => 'Return without calling?';

  @override
  String get unverifiedDialogBody =>
      'No verified call was found on this device. The decline will be flagged as UNVERIFIED, the merchant will be alerted immediately, and your trust score may be reduced if the customer disputes it.';

  @override
  String get returnAnyway => 'Return anyway';

  @override
  String get errorDialerFailed => 'Could not open the phone dialer.';

  @override
  String get errorGpsFailed =>
      'Location unavailable. Enable GPS permission and try again.';

  @override
  String get errorGenericAction => 'Something went wrong. Please try again.';

  @override
  String get merchantShellTitle => 'Merchant Console';

  @override
  String get merchantSubtitle => 'Pending verifications';

  @override
  String get noPendingVerifications =>
      'No orders awaiting verification right now.';

  @override
  String get confirmFailureButton => 'Confirm failure';

  @override
  String get overrideButton => 'Override → re-dispatch';

  @override
  String get overrideNoteHint =>
      'Note (optional): e.g. customer called back, wants product';

  @override
  String get unverifiedBadge => 'UNVERIFIED';

  @override
  String get trustScoreLabel => 'Trust score';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get accountSection => 'Account';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get profileSavedToast => 'Profile updated.';

  @override
  String get timersSection => 'Operation timers';

  @override
  String get driverTimerLabel => 'Driver response window (after call)';

  @override
  String get merchantTimerLabel =>
      'Merchant verification window (after failure)';

  @override
  String minutesUnit(Object n) {
    return '$n min';
  }

  @override
  String get timerSavedToast => 'Timers updated.';

  @override
  String get statusPending => 'PENDING';

  @override
  String get statusConfirmed => 'CONFIRMED';

  @override
  String get statusDispatched => 'DISPATCHED';

  @override
  String get statusOutForDelivery => 'OUT FOR DELIVERY';

  @override
  String get statusDeliveredPaid => 'DELIVERED & PAID';

  @override
  String get statusPendingVerification => 'PENDING VERIFICATION';

  @override
  String get statusReturned => 'RETURNED';

  @override
  String get todayLabel => 'TODAY';

  @override
  String get cashInHandNote => 'Cash in hand to hand over at the depot';

  @override
  String nDelivered(Object n) {
    return '$n delivered';
  }

  @override
  String nFailedReturned(Object n) {
    return '$n failed/returned';
  }

  @override
  String get settlementSubmittedToday =>
      'Settlement already submitted for today';

  @override
  String get submitSettlement => 'Submit end-of-day settlement';

  @override
  String get settlementAwaitingApproval =>
      'Submitted — awaiting manager approval.';

  @override
  String get settlementHistory => 'SETTLEMENT HISTORY';

  @override
  String get noSettlementsYet => 'No settlements yet.';

  @override
  String get statusPendingShort => 'PENDING';

  @override
  String get statusApprovedShort => 'APPROVED';

  @override
  String redispatchToast(Object tracking) {
    return '$tracking re-dispatched to driver.';
  }

  @override
  String confirmedReturnToast(Object tracking) {
    return '$tracking marked as returned.';
  }
}
