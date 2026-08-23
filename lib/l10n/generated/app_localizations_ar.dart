// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'OrderPulse';

  @override
  String get loginSubtitle => 'عمليات التوصيل الميدانية';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get newDriverPrompt => 'سائق جديد؟ ';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get enterValidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get minSixCharacters => '6 أحرف على الأقل';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get langEnglish => 'English';

  @override
  String get langArabic => 'العربية';

  @override
  String get langFrench => 'Français';

  @override
  String get nameLabel => 'الاسم الكامل';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get registerTitle => 'أنشئ حساب السائق';

  @override
  String get registerButton => 'إنشاء الحساب';

  @override
  String get haveAccountPrompt => 'لديك حساب بالفعل؟ ';

  @override
  String get signInInstead => 'تسجيل الدخول';

  @override
  String get runSheetTab => 'قائمة التوصيل';

  @override
  String get cashTab => 'المبالغ';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get settingsTooltip => 'الإعدادات';

  @override
  String get driverRoleLabel => 'السائق';

  @override
  String get merchantRoleLabel => 'التاجر';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmBody =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى قائمة التوصيل.';

  @override
  String get cancel => 'إلغاء';

  @override
  String welcomeBackToast(Object name) {
    return 'مرحبًا بعودتك، $name';
  }

  @override
  String get signedOutToast => 'تم تسجيل الخروج بنجاح.';

  @override
  String get remainingStops => 'محطات متبقية';

  @override
  String get cashCollected => 'المبالغ المحصّلة';

  @override
  String get sectionAwaitingVerification => 'بانتظار التحقق';

  @override
  String get sectionActiveRun => 'رحلة نشطة';

  @override
  String get sectionUpcoming => 'قادمة';

  @override
  String get sectionDelivered => 'تم التوصيل';

  @override
  String get sectionReturned => 'مُرجَعة';

  @override
  String get noCallYetBadge => 'بدون مكالمة';

  @override
  String get customerSection => 'العميل';

  @override
  String get financialsSection => 'المالية';

  @override
  String get itemSubtotal => 'سعر المنتج';

  @override
  String get shippingFee => 'رسوم التوصيل';

  @override
  String get totalCod => 'المبلغ الإجمالي (الدفع عند الاستلام)';

  @override
  String get collectedByDriver => 'حصّلها السائق';

  @override
  String get codPanelTitle => 'المبلغ المطلوب تحصيله عند التوصيل';

  @override
  String get attemptAuditTrail => 'سجل محاولة التوصيل';

  @override
  String get reasonRow => 'السبب';

  @override
  String get callInitiatedRow => 'بداية المكالمة';

  @override
  String get callDurationRow => 'مدة المكالمة';

  @override
  String get gpsFixRow => 'موقع GPS';

  @override
  String get accuracyRadiusRow => 'دقة الموقع';

  @override
  String get merchantIntervenedRow => 'تدخّل التاجر';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get unverifiedFlagRow => 'إرجاع غير موثّق';

  @override
  String get attemptedCallsRow => 'المكالمات التي أجريتها';

  @override
  String get responseTimerTitle => 'أبلغ عن النتيجة خلال';

  @override
  String get responseTimerBody =>
      'التاجر ينتظر نتيجة توصيلك. أخبرنا بأن الطلب وُصل أو فشل قبل انتهاء المؤقت.';

  @override
  String get responseTimerExpiredChip => 'لا استجابة';

  @override
  String get verificationWindowClosed => 'انتهت مهلة التحقق';

  @override
  String get windowClosedMessage =>
      'لم يتدخل التاجر. يمكن الآن اعتبار هذا الطلب مُرجَعًا.';

  @override
  String get merchantVerification => 'تحقق التاجر';

  @override
  String get merchantAlertedText =>
      'تم تنبيه التاجر ويمكنه تجاهل الإخفاق قبل انتهاء المؤقت.';

  @override
  String get actionCallCustomer => '1. اتصل بالعميل';

  @override
  String get actionDelivered => 'تم التوصيل';

  @override
  String get actionFailed => 'فشل';

  @override
  String get reportFailedAttemptTitle => 'الإبلاغ عن فشل المحاولة';

  @override
  String get auditNotice =>
      'سيتم إرفاق موقعك (GPS) وإثبات المكالمة بسجل التدقيق.';

  @override
  String get reasonUnresponsive => 'العميل لا يستجيب';

  @override
  String get reasonRefused => 'العميل رفض الاستلام';

  @override
  String get reasonWrongAddress => 'عنوان خاطئ أو يتعذر الوصول إليه';

  @override
  String get unverifiedDialogTitle => 'إرجاع بدون اتصال؟';

  @override
  String get unverifiedDialogBody =>
      'لم يتم العثور على مكالمة موثقة على هذا الجهاز. سيُعلَّم الإرجاع كغير موثّق، وسيُنبَّه التاجر فورًا، وقد ينخفض تصنيف الثقة الخاص بك إذا اعترض العميل.';

  @override
  String get returnAnyway => 'أعد الطلب رغم ذلك';

  @override
  String get errorDialerFailed => 'تعذر فتح تطبيق الاتصال.';

  @override
  String get errorGpsFailed => 'الموقع غير متاح. فعّل إذن GPS وحاول مجددًا.';

  @override
  String get errorGenericAction => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get merchantShellTitle => 'لوحة التاجر';

  @override
  String get merchantSubtitle => 'طلبات بانتظار التحقق';

  @override
  String get noPendingVerifications => 'لا توجد طلبات بانتظار التحقق حاليًا.';

  @override
  String get confirmFailureButton => 'تأكيد الإخفاق';

  @override
  String get overrideButton => 'تجاوز → إعادة الإرسال';

  @override
  String get overrideNoteHint =>
      'ملاحظة (اختياري): مثلاً اتصل العميل ويريد المنتج';

  @override
  String get unverifiedBadge => 'غير موثّق';

  @override
  String get trustScoreLabel => 'تصنيف الثقة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get accountSection => 'الحساب';

  @override
  String get saveProfile => 'حفظ البيانات';

  @override
  String get profileSavedToast => 'تم تحديث الملف الشخصي.';

  @override
  String get timersSection => 'مؤقتات العمليات';

  @override
  String get driverTimerLabel => 'مهلة استجابة السائق (بعد الاتصال)';

  @override
  String get merchantTimerLabel => 'مهلة تحقق التاجر (بعد الإخفاق)';

  @override
  String minutesUnit(Object n) {
    return '$n دقيقة';
  }

  @override
  String get timerSavedToast => 'تم تحديث المؤقتات.';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusDispatched => 'تم الإرسال';

  @override
  String get statusOutForDelivery => 'قيد التوصيل';

  @override
  String get statusDeliveredPaid => 'وُصل ودُفع';

  @override
  String get statusPendingVerification => 'بانتظار التحقق';

  @override
  String get statusReturned => 'مُرجَع';

  @override
  String get todayLabel => 'اليوم';

  @override
  String get cashInHandNote => 'المبلغ النقدي لتسليمه في المستودع';

  @override
  String nDelivered(Object n) {
    return '$n تم توصيلها';
  }

  @override
  String nFailedReturned(Object n) {
    return '$n فشلت/أُرجعت';
  }

  @override
  String get settlementSubmittedToday => 'تم إرسال تسوية اليوم بالفعل';

  @override
  String get submitSettlement => 'إرسال تسوية نهاية اليوم';

  @override
  String get settlementAwaitingApproval =>
      'تم الإرسال — بانتظار موافقة المسؤول.';

  @override
  String get settlementHistory => 'سجل التسويات';

  @override
  String get noSettlementsYet => 'لا توجد تسويات بعد.';

  @override
  String get statusPendingShort => 'قيد المراجعة';

  @override
  String get statusApprovedShort => 'معتمدة';

  @override
  String redispatchToast(Object tracking) {
    return 'تمت إعادة إرسال $tracking إلى السائق.';
  }

  @override
  String confirmedReturnToast(Object tracking) {
    return 'تم اعتبار $tracking مُرجَعًا.';
  }
}
