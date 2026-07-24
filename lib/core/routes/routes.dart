import 'package:flutter/material.dart';

import '../../features/views/others/terms_and_conditions_screen.dart';
class AppRoutes {
  AppRoutes._();

  static const String privacyPolicy = '/privacy-policy';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String profileDetail = '/profile_detail';
  static const String interestedUser = '/interested-user';
  static const settingScreen = 'Settings';
  static const changeEmailOtpScreen = 'ChangeEmailOtpScreen';
  static const changeOtpScreen = 'Change Otp Screen';
  static const changePhoneScreen = 'Change Phone';
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
/// Port of `NAVIGATION_SCREENS` from `src/Navigator/utils.js`.
/// Route *names* are kept identical to the RN screen names so any deep-link /
/// analytics / debugging references still line up.
class AuthRoutes {
  AuthRoutes._();

  static const loadingScreen = 'Loading Screen';
  static const loginScreen = 'LoginScreen';
  static const onBoardingScreen = 'OnBoarding';
  static const signInMainScreen = 'Sign in Options';
  static const phoneScreen = 'phone';
  static const signUp = 'SignUp';
  static const forgotScreen = 'Forgot Password';
  static const otpScreen = 'Otp';
  static const newPasswordScreen = 'New Password';
  static const privacyScreen = 'Privacy Policy';
  static const termsScreen = 'Terms and Conditions';
  static const verifiedScreen = 'Verified';
  static const accountSetupScreen = 'Account Setup';
  static const fillProfileScreen = 'Fill Profile';
  static const setLocationScreen = 'Set Location';
}

// class AppRoutes {
//   AppRoutes._();
//
//   static const homeScreen = 'HomeScreen';
//   static const questionListScreen = 'Question List Screen';
//   static const homeFilter = 'HomeFilterScreen';
//   static const questionsScreen = 'QuestionsScreen';
//   static const profileDetailScreen = 'Profle Detail';
//   static const chatScreen = 'Chat screen';
//   static const notificationScreen = 'Notification Screen';
//   static const paymentPlanScreen = 'Payment Plan';
//   static const settingScreen = 'Settings';
//   static const subscriptionsTermsScreen = 'Subscription Terms';
//   static const interestedUserScreen = 'Interested User';
//   static const favoriteUserScreen = 'Favorite User';
//   static const blockedUserScreen = 'Blocked User';
//   static const resetPasswordScreen = 'Reset Password';
//   static const visitedUserScreen = 'Visited User';
//   static const editProfileScreen = 'EditProfileScreen';
//   static const changeEmailOtpScreen = 'ChangeEmailOtpScreen';
//   static const changeOtpScreen = 'Change Otp Screen';
//   static const changePhoneScreen = 'Change Phone';
//   static const editQuestionsScreen = 'Edit Question';
//
//   /// Entry point for `UserTabbarNavigator` (RN registered it as `'tabbar'`).
//   static const tabbar = 'tabbar';
// }

class TabRoutes {
  TabRoutes._();

  static const home = 'Home';
  static const explore = 'Explore';
  static const tickets = 'Tickets';
  static const favorite = 'Favorite';
  static const profile = 'Profile';
}