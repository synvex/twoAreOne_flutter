// main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/features/Bottom_Nav_Bar_Screens/custom_nav_bar.dart';
import 'package:two_are_one/features/home/profile_details_screen.dart';
import 'package:two_are_one/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/services/home_service.dart';

import 'features/auth/login.dart';
import 'features/Bottom_Nav_Bar_Screens/home_screen.dart';
import 'features/main_screens/main_screen.dart';
import 'features/main_screens/profile_setup_screen.dart';
import 'features/main_screens/question_screen.dart';
import 'features/onboarding.dart';
import 'firebase_options.dart';
import 'models/user_profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Restore token
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token != null && token.isNotEmpty) {
    ApiManager.setUpRequestToken(token);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Are One',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Global key for dialogs
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Use FutureBuilder to determine the start screen
      routes: {
        // ✅ ADD THIS
        '/profile_detail': (context) => const ProfileDetailsScreen(),
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

// main.dart

Future<Widget> getInitialScreen() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) return const OnboardingScreen();

  ApiManager.setUpRequestToken(token);

  final homeService = HomeService();
  final res = await homeService.getUserInfo();

  if (res['success'] == true) {
    final data = res['data'];
    final complete = data['complete_question']?.toString() == "true";
    final screenType = data['screen_type']?.toString() ?? "0";

    // ✅ Create a skeleton model to avoid passing NULL to constructors
    final savedGender = data['gender']?.toString() ?? "";
    final savedLookingFor = data['sexuality']?.toString() ?? "";

    final skeletonModel = UserProfileModel(
      gender: savedGender,
      sexuality: savedLookingFor,
    );

    if (complete) return const MainBarScreen(); // Route "3" is Home

    switch (screenType) {
      case "0":
        return const MainScreen(); // MainScreen is the Preferences/Gender screen
      case "1":
        return ProfileSetupScreen(profileModel: skeletonModel);
      case "2":
        return QuestionnaireScreen(profileModel: skeletonModel);
      default:
        return const MainScreen();
    }
  }

  return const LoginPage();
}











// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:two_are_one/features/auth/login.dart';
// import 'package:two_are_one/features/main_screens/main_screen.dart';
// import 'package:two_are_one/features/onboarding.dart';
// import 'package:two_are_one/services/Api_Helper/api_manager.dart';
// import 'package:two_are_one/services/home_service.dart';
// import 'features/main_screens/profile_setup_screen.dart';
// import 'features/main_screens/question_screen.dart';
// import 'firebase_options.dart';
//
// void main() async {
//   // 1. Ensure Flutter is ready
//   WidgetsFlutterBinding.ensureInitialized();
//   // await HomeService.restoreTokenOnBoot();
//   // 2. Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('auth_token');
//   // if (token != null ) {
//   //   ApiManager.setUpRequestToken(token);
//   // }
//   if (token != null && token.isNotEmpty) {
//     // 2. This is the crucial step to make match data show up on boot
//     ApiManager.setUpRequestToken(token);
//     debugPrint("Restored token on boot: $token");
//   }
//   runApp(const MyApp());
// }
// Future<Widget> getInitialScreen() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('auth_token');
//
//   if (token == null || token.isEmpty) return const OnboardingScreen();
//
//   ApiManager.setUpRequestToken(token);
//
//   // Fetch latest screen_type from user-info.php (Exactly like RN)
//   final homeService = HomeService();
//   final res = await homeService.getUserInfo();
//
//   if (res['success'] == true) {
//     final data = res['data'];
//     final complete = data['complete_question']?.toString() == "true";
//     final screenType = data['screen_type']?.toString() ?? "0";
//
//     if (complete) return const MainScreen(); // Route "3"
//
//     switch (screenType) {
//       case "0": return const MainScreen(); // Match RN logic
//       case "1": return const ProfileSetupScreen(gender: '', lookingFor: '', profileModel: null,);
//       case "2": return const QuestionnaireScreen(profileModel: null,);
//       default: return const MainScreen();
//     }
//   }
//
//   return const LoginPage(); // Fallback if info fetch fails (token expired)
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       // home: MainScreen(),
//         navigatorKey: navigatorKey,
//         home: const OnboardingScreen(),
//     );
//   }
// }
