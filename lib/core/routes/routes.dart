import 'package:flutter/material.dart';

import '../../features/views/others/terms_and_conditions_screen.dart';
class AppRoutes {
  AppRoutes._();

  static const String privacyPolicy = '/privacy-policy';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String profileDetail = '/profile_detail';
  static const String interestedUser = '/interested-user';

  static Map<String, WidgetBuilder> routes = {
    // privacyPolicy: (_) => const PrivacyPolicyScreen(),
    termsAndConditions: (_) => const TermsAndConditionsScreen(),
  };
}
class SettingsRoutes {
  SettingsRoutes._();
  static const String privacyPolicy = '/privacy_policy';
  static const String termsOfUse = '/terms_of_use';
  static const String resetPassword = '/reset_password';
  static const String changeOtp = '/change_otp';

  static const String changeEmailOtp = '/change_email_otp';
}