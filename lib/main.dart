import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/services/home_service.dart';
import 'features/Bottom_Nav_Bar_Screens/custom_nav_bar.dart';
import 'features/Screens/edit_profile_screen.dart';
import 'features/auth/login.dart';
import 'features/home/profile_details_screen.dart';
import 'features/main_screens/main_screen.dart';
import 'features/main_screens/profile_setup_screen.dart';
import 'features/main_screens/question_screen.dart';
import 'features/onboarding.dart';
import 'firebase_options.dart';
import 'models/user_profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Are One',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Global key so ApiManager can show dialogs/navigate
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/profile_detail': (context) => const ProfileDetailsScreen(),
        '/login': (context) => const LoginPage(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
      home: FutureBuilder<Widget>(
        future: getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data ?? const OnboardingScreen();
        },
      ),
    );
  }
}

Widget _screenFromCache(Map<String, String?> cached) {
  final complete = cached['complete_question'] == "true";
  final screenType = cached['screen_type'] ?? "0";

  final skeletonModel = UserProfileModel(
    gender: cached['gender'] ?? "",
    sexuality: cached['sexuality'] ?? "",
  );

  if (complete) return const MainBarScreen();

  switch (screenType) {
    case "0":
      return const MainScreen();
    case "1":
      return ProfileSetupScreen(profileModel: skeletonModel);
    case "2":
      return QuestionnaireScreen(profileModel: skeletonModel);
    default:
      return const MainScreen();
  }
}
Future<Map<String, String?>> _readCachedUserInfo(SharedPreferences prefs) async {
  return {
    'complete_question': prefs.getString('cached_complete_question'),
    'screen_type': prefs.getString('cached_screen_type'),
    'gender': prefs.getString('cached_gender'),
    'sexuality': prefs.getString('cached_sexuality'),
  };
}
Future<void> _writeCachedUserInfo(
    SharedPreferences prefs, Map<String, dynamic> data) async
{
  await prefs.setString(
      'cached_complete_question', data['complete_question']?.toString() ?? "");
  await prefs.setString(
      'cached_screen_type', data['screen_type']?.toString() ?? "0");
  await prefs.setString('cached_gender', data['gender']?.toString() ?? "");
  await prefs.setString(
      'cached_sexuality', data['sexuality']?.toString() ?? "");
}
Future<Widget> getInitialScreen() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) return const OnboardingScreen();

  ApiManager.setUpRequestToken(token);

  final homeService = HomeService();
  final res = await homeService.getUserInfo();

  if (res['success'] == true) {
    final data = res['data'] as Map<String, dynamic>;
    // FIX: cache the server's answer locally so that a future launch with
    // no internet can still route the user correctly instead of forcing
    // them back to the login screen.
    await _writeCachedUserInfo(prefs, data);
    return _screenFromCache(await _readCachedUserInfo(prefs));
  }

  // FIX (offline/boot regression): the server explicitly said the token is
  // invalid/expired -> this really is a logged-out state, so go to login.
  if (res['isSessionExpired'] == true) {
    await ApiManager.logout();
    return const LoginPage();
  }

  // FIX (offline/boot regression): any other failure (no internet, server
  // down, timeout, etc.) is NOT proof the user is logged out. If we have a
  // cached copy of their last known state, use it — exactly like the RN
  // app, which renders the app from AsyncStorage first and only reconciles
  // with the server in the background.
  final cached = await _readCachedUserInfo(prefs);
  if (cached['screen_type'] != null) {
    return _screenFromCache(cached);
  }

  // No cache and no successful response yet — safest fallback.
  return const LoginPage();
}


// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:two_are_one/services/Api_Helper/api_manager.dart';
// import 'package:two_are_one/services/home_service.dart';
// import 'features/Bottom_Nav_Bar_Screens/custom_nav_bar.dart';
// import 'features/auth/login.dart';
// import 'features/home/profile_details_screen.dart';
// import 'features/main_screens/main_screen.dart';
// import 'features/main_screens/profile_setup_screen.dart';
// import 'features/main_screens/question_screen.dart';
// import 'features/onboarding.dart';
// import 'firebase_options.dart';
// import 'models/user_profile_model.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Two Are One',
//       debugShowCheckedModeBanner: false,
//       navigatorKey: navigatorKey, // Global key so ApiManager can show dialogs/navigate
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       routes: {
//         '/profile_detail': (context) => const ProfileDetailsScreen(),
//         '/login': (context) => const LoginPage(),
//       },
//       home: FutureBuilder<Widget>(
//         future: getInitialScreen(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(body: Center(child: CircularProgressIndicator()));
//           }
//           return snapshot.data ?? const OnboardingScreen();
//         },
//       ),
//     );
//   }
// }
//
// /// Builds a screen from LOCALLY CACHED data (no network needed). Used both
// /// as the offline fallback and to persist what we last knew from the
// /// server, mirroring how the React Native app keeps `USER_INFO` in
// /// AsyncStorage so a returning user isn't kicked to the login screen just
// /// because they opened the app without internet.
// ///
// Widget _screenFromCache(Map<String, String?> cached) {
//   final complete = cached['complete_question'] == "true";
//   final screenType = cached['screen_type'] ?? "0";
//
//   final skeletonModel = UserProfileModel(
//     gender: cached['gender'] ?? "",
//     sexuality: cached['sexuality'] ?? "",
//   );
//
//   if (complete) return const MainBarScreen();
//
//   switch (screenType) {
//     case "0":
//       return const MainScreen();
//     case "1":
//       return ProfileSetupScreen(profileModel: skeletonModel);
//     case "2":
//       return QuestionnaireScreen(profileModel: skeletonModel);
//     default:
//       return const MainScreen();
//   }
// }
//
// Future<Map<String, String?>> _readCachedUserInfo(SharedPreferences prefs) async {
//   return {
//     'complete_question': prefs.getString('cached_complete_question'),
//     'screen_type': prefs.getString('cached_screen_type'),
//     'gender': prefs.getString('cached_gender'),
//     'sexuality': prefs.getString('cached_sexuality'),
//   };
// }
//
// Future<void> _writeCachedUserInfo(
//     SharedPreferences prefs, Map<String, dynamic> data) async
// {
//   await prefs.setString(
//       'cached_complete_question', data['complete_question']?.toString() ?? "");
//   await prefs.setString(
//       'cached_screen_type', data['screen_type']?.toString() ?? "0");
//   await prefs.setString('cached_gender', data['gender']?.toString() ?? "");
//   await prefs.setString(
//       'cached_sexuality', data['sexuality']?.toString() ?? "");
// }
//
// Future<Widget> getInitialScreen() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('auth_token');
//
//   if (token == null || token.isEmpty) return const OnboardingScreen();
//
//   ApiManager.setUpRequestToken(token);
//
//   final homeService = HomeService();
//   final res = await homeService.getUserInfo();
//
//   if (res['success'] == true) {
//     final data = res['data'] as Map<String, dynamic>;
//     // FIX: cache the server's answer locally so that a future launch with
//     // no internet can still route the user correctly instead of forcing
//     // them back to the login screen.
//     await _writeCachedUserInfo(prefs, data);
//     return _screenFromCache(await _readCachedUserInfo(prefs));
//   }
//
//   // FIX (offline/boot regression): the server explicitly said the token is
//   // invalid/expired -> this really is a logged-out state, so go to login.
//   if (res['isSessionExpired'] == true) {
//     await ApiManager.logout();
//     return const LoginPage();
//   }
//
//   // FIX (offline/boot regression): any other failure (no internet, server
//   // down, timeout, etc.) is NOT proof the user is logged out. If we have a
//   // cached copy of their last known state, use it — exactly like the RN
//   // app, which renders the app from AsyncStorage first and only reconciles
//   // with the server in the background.
//   final cached = await _readCachedUserInfo(prefs);
//   if (cached['screen_type'] != null) {
//     return _screenFromCache(cached);
//   }
//
//   // No cache and no successful response yet — safest fallback.
//   return const LoginPage();
// }
