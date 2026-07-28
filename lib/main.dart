import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/data/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/data/repo/socket_service.dart';
import 'package:two_are_one/data/viewmodels/chat_viewmodel.dart';
import 'package:two_are_one/data/viewmodels/notification_view_model.dart';
import 'package:two_are_one/features/views/Interested/interrested_user_screen.dart';
import 'package:two_are_one/features/views/Settings/settings_screen.dart';
import 'package:two_are_one/features/views/auth/login_screen.dart';
import 'package:two_are_one/features/views/home/profile_details_screen.dart';
import 'package:two_are_one/features/views/profile/edit_profile_screen.dart';
import 'core/routes/flow_router.dart';
import 'core/routes/routes.dart';
import 'data/viewmodels/notification_view_model.dart';
import 'features/views/Blocked/blocked_screen.dart';
import 'features/views/Settings/add_new_email_screen.dart';
import 'features/views/Settings/change_email_otp_screen.dart';
import 'features/views/Settings/change_otp_screen.dart';
import 'features/views/Settings/change_phone_screen.dart';
import 'features/views/Settings/reset_password_screen.dart';
import 'features/views/auth/onboarding.dart';
import 'features/views/others/privacy.dart';
import 'features/views/others/terms_and_conditions_screen.dart';
import 'features/views/visted_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        // .value, not create: - this must be the same instance ApiManager
        // drives via SocketService.instance, so widgets that watch it
        // (e.g. online-status dots) see the real connection state.
        ChangeNotifierProvider.value(value: SocketService.instance),
      ],
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
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/settings_screen': (context) => const SettingsScreen(),
          '/profile_detail': (context) => const ProfileDetailsScreen(),
          '/login': (context) =>  const LoginScreen(),
          '/interested_screen': (context) => const InterestedUserScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/blocked_screen': (context) => const BlockedUserScreen(),
          'visited_screen': (context) => const VisitedUserScreen(),
          SettingsRoutes.privacyPolicy: (context) =>
              const PrivacyPolicyScreen(),
          SettingsRoutes.termsOfUse: (context) =>
              const TermsAndConditionsScreen(),
        },
        onGenerateRoute: (settings) {
          final args = settings.arguments is Map
              ? settings.arguments as Map
              : const {};
          DateTime asDateTime(dynamic v) => v is DateTime
              ? v
              : (v is int
                    ? DateTime.fromMillisecondsSinceEpoch(v)
                    : DateTime.now().add(const Duration(seconds: 60)));
          switch (settings.name) {
            case SettingsRoutes.resetPassword:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const ResetPasswordScreen(),
              );
            case SettingsRoutes.addNewEmail:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const AddNewEmailScreen(),
              );
            case AppRoutes.changePhoneScreen:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const ChangePhoneScreen(),
              );
            case SettingsRoutes.changeOtp:
            case AppRoutes.changeOtpScreen:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => ChangeOtpScreen(
                  phone: args['phone']?.toString() ?? '',
                  isCurrent: args['isCurrent'] as bool? ?? false,
                  endTime: asDateTime(args['endTime']),
                ),
              );
            case SettingsRoutes.changeEmailOtp:
            case AppRoutes.changeEmailOtpScreen:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => ChangeEmailOtpScreen(
                  email: args['email']?.toString() ?? '',
                  isCurrent: args['isCurrent'] as bool? ?? false,
                  endTime: asDateTime(args['endTime']),
                ),
              );
            default:
              return null; // unknown routes still fall through to "Coming soon" — unchanged behavior
          }
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

Future<Widget> getInitialScreen() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) return const OnboardingScreen();

  ApiManager.setUpRequestToken(token);
  return await OnboardingFlowRouter.resolveResumeScreen();
}
