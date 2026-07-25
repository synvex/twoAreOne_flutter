import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/data/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/data/services/home_service.dart';
import 'package:two_are_one/data/viewmodels/chat_viewmodel.dart';
import 'package:two_are_one/features/views/Interested/interrested_user_screen.dart';
import 'package:two_are_one/features/views/Settings/settings_screen.dart';
import 'package:two_are_one/features/views/auth/login_screen.dart';
import 'package:two_are_one/features/views/bottom_nav/custom_nav_bar.dart';
import 'package:two_are_one/features/views/home/profile_details_screen.dart';
import 'package:two_are_one/features/views/main/main_screen.dart';
import 'package:two_are_one/features/views/main/profile_setup_screen.dart';
import 'package:two_are_one/features/views/main/question_screen.dart';
import 'package:two_are_one/features/views/profile/edit_profile_screen.dart';
import 'core/routes/routes.dart';
import 'data/models/user_profile_model.dart';
import 'features/views/Blocked/blocked_screen.dart';
import 'features/views/auth/onboarding_screen.dart';
import 'features/views/others/privacy.dart';
import 'features/views/others/terms_and_conditions_screen.dart';
import 'features/views/visted_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ChatViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Two Are One',
        debugShowCheckedModeBanner: false,
        navigatorKey:
            navigatorKey, // Global key so ApiManager can show dialogs/navigate
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
        ),
        routes: {
          '/settings_screen': (context) => const SettingsScreen(),
          '/profile_detail': (context) => const ProfileDetailsScreen(),
          '/login': (context) => const LoginScreen(),
          '/interested_screen': (context) => const InterestedUserScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/blocked_screen': (context) => const BlockedUserScreen(),
          'visited_screen': (context) => const VisitedUserScreen(),
          SettingsRoutes.privacyPolicy: (context) =>
              const PrivacyPolicyScreen(),
          SettingsRoutes.termsOfUse: (context) =>
              const TermsAndConditionsScreen(),
        },
        home: FutureBuilder<Widget>(
          future: getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data ?? const OnboardingScreen();
          },
        ),
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

Future<Map<String, String?>> _readCachedUserInfo(
  SharedPreferences prefs,
) async {
  return {
    'complete_question': prefs.getString('cached_complete_question'),
    'screen_type': prefs.getString('cached_screen_type'),
    'gender': prefs.getString('cached_gender'),
    'sexuality': prefs.getString('cached_sexuality'),
  };
}

Future<void> _writeCachedUserInfo(
  SharedPreferences prefs,
  Map<String, dynamic> data,
) async {
  await prefs.setString(
    'cached_complete_question',
    data['complete_question']?.toString() ?? "",
  );
  await prefs.setString(
    'cached_screen_type',
    data['screen_type']?.toString() ?? "0",
  );
  await prefs.setString('cached_gender', data['gender']?.toString() ?? "");
  await prefs.setString(
    'cached_sexuality',
    data['sexuality']?.toString() ?? "",
  );
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
    await _writeCachedUserInfo(prefs, data);
    return _screenFromCache(await _readCachedUserInfo(prefs));
  }

  if (res['isSessionExpired'] == true) {
    await ApiManager.logout();
    return const LoginScreen();
  }

  final cached = await _readCachedUserInfo(prefs);
  if (cached['screen_type'] != null) {
    return _screenFromCache(cached);
  }

  // No cache and no successful response yet — safest fallback.
  return const LoginScreen();
}
