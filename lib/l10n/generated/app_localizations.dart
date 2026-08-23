import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OrderPulse'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Field Operations'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @newDriverPrompt.
  ///
  /// In en, this message translates to:
  /// **'New driver? '**
  String get newDriverPrompt;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @minSixCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minSixCharacters;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get langArabic;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get langFrench;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your driver account'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccountPrompt;

  /// No description provided for @signInInstead.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInInstead;

  /// No description provided for @runSheetTab.
  ///
  /// In en, this message translates to:
  /// **'Run-Sheet'**
  String get runSheetTab;

  /// No description provided for @cashTab.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashTab;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @driverRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverRoleLabel;

  /// No description provided for @merchantRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchantRoleLabel;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your run-sheet.'**
  String get logoutConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @welcomeBackToast.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeBackToast(Object name);

  /// No description provided for @signedOutToast.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully.'**
  String get signedOutToast;

  /// No description provided for @remainingStops.
  ///
  /// In en, this message translates to:
  /// **'Remaining stops'**
  String get remainingStops;

  /// No description provided for @cashCollected.
  ///
  /// In en, this message translates to:
  /// **'Cash collected'**
  String get cashCollected;

  /// No description provided for @sectionAwaitingVerification.
  ///
  /// In en, this message translates to:
  /// **'AWAITING VERIFICATION'**
  String get sectionAwaitingVerification;

  /// No description provided for @sectionActiveRun.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE RUN'**
  String get sectionActiveRun;

  /// No description provided for @sectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get sectionUpcoming;

  /// No description provided for @sectionDelivered.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED'**
  String get sectionDelivered;

  /// No description provided for @sectionReturned.
  ///
  /// In en, this message translates to:
  /// **'RETURNED'**
  String get sectionReturned;

  /// No description provided for @noCallYetBadge.
  ///
  /// In en, this message translates to:
  /// **'NO CALL YET'**
  String get noCallYetBadge;

  /// No description provided for @customerSection.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerSection;

  /// No description provided for @financialsSection.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get financialsSection;

  /// No description provided for @itemSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Item subtotal'**
  String get itemSubtotal;

  /// No description provided for @shippingFee.
  ///
  /// In en, this message translates to:
  /// **'Shipping fee'**
  String get shippingFee;

  /// No description provided for @totalCod.
  ///
  /// In en, this message translates to:
  /// **'Total COD'**
  String get totalCod;

  /// No description provided for @collectedByDriver.
  ///
  /// In en, this message translates to:
  /// **'Collected by driver'**
  String get collectedByDriver;

  /// No description provided for @codPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'CASH TO COLLECT ON DELIVERY'**
  String get codPanelTitle;

  /// No description provided for @attemptAuditTrail.
  ///
  /// In en, this message translates to:
  /// **'Attempt audit trail'**
  String get attemptAuditTrail;

  /// No description provided for @reasonRow.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonRow;

  /// No description provided for @callInitiatedRow.
  ///
  /// In en, this message translates to:
  /// **'Call initiated'**
  String get callInitiatedRow;

  /// No description provided for @callDurationRow.
  ///
  /// In en, this message translates to:
  /// **'Call duration'**
  String get callDurationRow;

  /// No description provided for @gpsFixRow.
  ///
  /// In en, this message translates to:
  /// **'GPS fix'**
  String get gpsFixRow;

  /// No description provided for @accuracyRadiusRow.
  ///
  /// In en, this message translates to:
  /// **'Accuracy radius'**
  String get accuracyRadiusRow;

  /// No description provided for @merchantIntervenedRow.
  ///
  /// In en, this message translates to:
  /// **'Merchant intervened'**
  String get merchantIntervenedRow;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get no;

  /// No description provided for @unverifiedFlagRow.
  ///
  /// In en, this message translates to:
  /// **'UNVERIFIED DECLINE'**
  String get unverifiedFlagRow;

  /// No description provided for @attemptedCallsRow.
  ///
  /// In en, this message translates to:
  /// **'Attempted calls'**
  String get attemptedCallsRow;

  /// No description provided for @responseTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'REPORT OUTCOME WITHIN'**
  String get responseTimerTitle;

  /// No description provided for @responseTimerBody.
  ///
  /// In en, this message translates to:
  /// **'The merchant is waiting for your delivery outcome. Report Delivered or Failed before the timer ends.'**
  String get responseTimerBody;

  /// No description provided for @responseTimerExpiredChip.
  ///
  /// In en, this message translates to:
  /// **'NO RESPONSE'**
  String get responseTimerExpiredChip;

  /// No description provided for @verificationWindowClosed.
  ///
  /// In en, this message translates to:
  /// **'VERIFICATION WINDOW CLOSED'**
  String get verificationWindowClosed;

  /// No description provided for @windowClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'No merchant intervention. This order can now be processed as returned.'**
  String get windowClosedMessage;

  /// No description provided for @merchantVerification.
  ///
  /// In en, this message translates to:
  /// **'MERCHANT VERIFICATION'**
  String get merchantVerification;

  /// No description provided for @merchantAlertedText.
  ///
  /// In en, this message translates to:
  /// **'The merchant has been alerted and can override this failure before the timer ends.'**
  String get merchantAlertedText;

  /// No description provided for @actionCallCustomer.
  ///
  /// In en, this message translates to:
  /// **'1. Call Customer'**
  String get actionCallCustomer;

  /// No description provided for @actionDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get actionDelivered;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get actionFailed;

  /// No description provided for @reportFailedAttemptTitle.
  ///
  /// In en, this message translates to:
  /// **'Report failed attempt'**
  String get reportFailedAttemptTitle;

  /// No description provided for @auditNotice.
  ///
  /// In en, this message translates to:
  /// **'Your GPS position and call proof will be attached to the audit log.'**
  String get auditNotice;

  /// No description provided for @reasonUnresponsive.
  ///
  /// In en, this message translates to:
  /// **'Customer unresponsive'**
  String get reasonUnresponsive;

  /// No description provided for @reasonRefused.
  ///
  /// In en, this message translates to:
  /// **'Customer refused delivery'**
  String get reasonRefused;

  /// No description provided for @reasonWrongAddress.
  ///
  /// In en, this message translates to:
  /// **'Wrong / unreachable address'**
  String get reasonWrongAddress;

  /// No description provided for @unverifiedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Return without calling?'**
  String get unverifiedDialogTitle;

  /// No description provided for @unverifiedDialogBody.
  ///
  /// In en, this message translates to:
  /// **'No verified call was found on this device. The decline will be flagged as UNVERIFIED, the merchant will be alerted immediately, and your trust score may be reduced if the customer disputes it.'**
  String get unverifiedDialogBody;

  /// No description provided for @returnAnyway.
  ///
  /// In en, this message translates to:
  /// **'Return anyway'**
  String get returnAnyway;

  /// No description provided for @errorDialerFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone dialer.'**
  String get errorDialerFailed;

  /// No description provided for @errorGpsFailed.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable. Enable GPS permission and try again.'**
  String get errorGpsFailed;

  /// No description provided for @errorGenericAction.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGenericAction;

  /// No description provided for @merchantShellTitle.
  ///
  /// In en, this message translates to:
  /// **'Merchant Console'**
  String get merchantShellTitle;

  /// No description provided for @merchantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pending verifications'**
  String get merchantSubtitle;

  /// No description provided for @noPendingVerifications.
  ///
  /// In en, this message translates to:
  /// **'No orders awaiting verification right now.'**
  String get noPendingVerifications;

  /// No description provided for @confirmFailureButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm failure'**
  String get confirmFailureButton;

  /// No description provided for @overrideButton.
  ///
  /// In en, this message translates to:
  /// **'Override → re-dispatch'**
  String get overrideButton;

  /// No description provided for @overrideNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note (optional): e.g. customer called back, wants product'**
  String get overrideNoteHint;

  /// No description provided for @unverifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'UNVERIFIED'**
  String get unverifiedBadge;

  /// No description provided for @trustScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Trust score'**
  String get trustScoreLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @profileSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileSavedToast;

  /// No description provided for @timersSection.
  ///
  /// In en, this message translates to:
  /// **'Operation timers'**
  String get timersSection;

  /// No description provided for @driverTimerLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver response window (after call)'**
  String get driverTimerLabel;

  /// No description provided for @merchantTimerLabel.
  ///
  /// In en, this message translates to:
  /// **'Merchant verification window (after failure)'**
  String get merchantTimerLabel;

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minutesUnit(Object n);

  /// No description provided for @timerSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Timers updated.'**
  String get timerSavedToast;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get statusConfirmed;

  /// No description provided for @statusDispatched.
  ///
  /// In en, this message translates to:
  /// **'DISPATCHED'**
  String get statusDispatched;

  /// No description provided for @statusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'OUT FOR DELIVERY'**
  String get statusOutForDelivery;

  /// No description provided for @statusDeliveredPaid.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED & PAID'**
  String get statusDeliveredPaid;

  /// No description provided for @statusPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'PENDING VERIFICATION'**
  String get statusPendingVerification;

  /// No description provided for @statusReturned.
  ///
  /// In en, this message translates to:
  /// **'RETURNED'**
  String get statusReturned;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayLabel;

  /// No description provided for @cashInHandNote.
  ///
  /// In en, this message translates to:
  /// **'Cash in hand to hand over at the depot'**
  String get cashInHandNote;

  /// No description provided for @nDelivered.
  ///
  /// In en, this message translates to:
  /// **'{n} delivered'**
  String nDelivered(Object n);

  /// No description provided for @nFailedReturned.
  ///
  /// In en, this message translates to:
  /// **'{n} failed/returned'**
  String nFailedReturned(Object n);

  /// No description provided for @settlementSubmittedToday.
  ///
  /// In en, this message translates to:
  /// **'Settlement already submitted for today'**
  String get settlementSubmittedToday;

  /// No description provided for @submitSettlement.
  ///
  /// In en, this message translates to:
  /// **'Submit end-of-day settlement'**
  String get submitSettlement;

  /// No description provided for @settlementAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Submitted — awaiting manager approval.'**
  String get settlementAwaitingApproval;

  /// No description provided for @settlementHistory.
  ///
  /// In en, this message translates to:
  /// **'SETTLEMENT HISTORY'**
  String get settlementHistory;

  /// No description provided for @noSettlementsYet.
  ///
  /// In en, this message translates to:
  /// **'No settlements yet.'**
  String get noSettlementsYet;

  /// No description provided for @statusPendingShort.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPendingShort;

  /// No description provided for @statusApprovedShort.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get statusApprovedShort;

  /// No description provided for @redispatchToast.
  ///
  /// In en, this message translates to:
  /// **'{tracking} re-dispatched to driver.'**
  String redispatchToast(Object tracking);

  /// No description provided for @confirmedReturnToast.
  ///
  /// In en, this message translates to:
  /// **'{tracking} marked as returned.'**
  String confirmedReturnToast(Object tracking);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
