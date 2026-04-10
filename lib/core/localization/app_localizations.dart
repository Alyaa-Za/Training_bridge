import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Onboarding
      'skip': 'Skip',
      'next': 'Next',
      'get_started': 'Get Started',
      'find_opportunities': 'Find Opportunities',
      'find_opportunities_desc': 'Discover the best training opportunities from top institutions',
      'apply_easily': 'Apply Easily',
      'apply_easily_desc': 'Submit your applications with just a few taps',
      'track_progress': 'Track Your Progress',
      'track_progress_desc': 'Monitor your internship journey from start to finish',

      // Auth
      'welcome': 'Welcome Back',
      'login_subtitle': 'Login to continue your journey',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'email_required': 'Email is required',
      'email_invalid': 'Please enter a valid email',
      'password_required': 'Password is required',
      'password_short': 'Password must be at least 8 characters',

      // Errors
      'no_internet': 'No internet connection',
      'server_error': 'Server error, please try again',
      'unknown_error': 'Something went wrong',
      'invalid_credentials': 'Invalid email or password',
      'login_failed': 'Login failed',

      // Success
      'login_success': 'Login successful',
    },
    'ar': {
      // Onboarding
      'skip': 'تخطي',
      'next': 'التالي',
      'get_started': 'ابدأ الآن',
      'find_opportunities': 'اكتشف الفرص',
      'find_opportunities_desc': 'اكتشف أفضل فرص التدريب من أفضل المؤسسات',
      'apply_easily': 'تقدم بسهولة',
      'apply_easily_desc': 'قدم طلباتك ببضع نقرات فقط',
      'track_progress': 'تابع تقدمك',
      'track_progress_desc': 'راقب رحلة التدريب الخاصة بك من البداية للنهاية',

      // Auth
      'welcome': 'مرحباً بعودتك',
      'login_subtitle': 'سجل الدخول للمتابعة',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'login': 'تسجيل الدخول',
      'email_required': 'البريد الإلكتروني مطلوب',
      'email_invalid': 'الرجاء إدخال بريد إلكتروني صحيح',
      'password_required': 'كلمة المرور مطلوبة',
      'password_short': 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',

      // Errors
      'no_internet': 'لا يوجد اتصال بالإنترنت',
      'server_error': 'خطأ في الخادم، حاول مرة أخرى',
      'unknown_error': 'حدث خطأ ما',
      'invalid_credentials': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      'login_failed': 'فشل تسجيل الدخول',

      // Success
      'login_success': 'تم تسجيل الدخول بنجاح',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}