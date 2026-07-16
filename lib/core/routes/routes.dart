// lib/core/settings_routes.dart
//
// Route-name constants for the destinations SettingsScreen navigates to.
// Mirrors RN's `Navigator/utils.js` -> `NAVIGATION_SCREENS.LOGIN_MODULE` /
// `NAVIGATION_SCREENS.USER_MODULE` entries this screen actually uses:
//
//   RN screen key                RN route name            Flutter route
//   ------------------------------------------------------------------
//   PrivacyScreen                 'Privacy Policy'         privacyPolicy
//   TermsScreen                   'Terms and Conditions'   termsOfUse
//   ResetPasswordScreen           'Reset Password'         resetPassword
//   ChangeOtpScreen               'Change Otp Screen'      changeOtp
//   ChangeEmailOtpScreen          'ChangeEmailOtpScreen'   changeEmailOtp
//
// These destination screens aren't part of this task (the Flutter app
// doesn't have them yet), so they aren't registered in MaterialApp's
// `routes` map. SettingsScreen guards every navigation call and falls
// back to a "Coming soon" toast (same affordance already used elsewhere
// in this app, e.g. ProfileScreen's unbuilt menu items) if a route isn't
// registered yet, so nothing crashes in the meantime.
//
// Once each destination screen is built, just add it to MaterialApp's
// `routes` map in main.dart using the constant below as the key, e.g.:
//   routes: {
//     ...
//     SettingsRoutes.resetPassword: (context) => const ResetPasswordScreen(),
//   }

import 'package:flutter/material.dart';

import '../../ui/views/terms_and_conditions_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String privacyPolicy = '/privacy-policy';
  static const String termsAndConditions = '/terms-and-conditions';

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

  /// Arguments expected (a Map<String, dynamic>), matching RN's navigation
  /// params for ChangeOtpScreen:
  ///   { verificationId, phone, isCurrent: true, endTime }
  static const String changeOtp = '/change_otp';

  /// Arguments expected (a Map<String, dynamic>), matching RN's navigation
  /// params for ChangeEmailOtpScreen:
  ///   { email, isCurrent: true, endTime }
  static const String changeEmailOtp = '/change_email_otp';
}