import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/constants/app_images.dart';
import 'package:two_are_one/core/permission/permission_manager.dart';

import 'package:two_are_one/data/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/core/routes/flow_router.dart';
import 'package:two_are_one/features/views/auth/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  // ----------------------------------------------------------
  // PERMISSION FLOW
  // ----------------------------------------------------------

  Future<void> _checkPermissions() async {
    // Ask for permissions (shows system dialogs).
    // We don't care about the result — allow or deny,
    // the app continues either way.
    await PermissionManager.instance.requestRequiredPermissions();

    if (!mounted) return;

    _handleSession();
  }

  // ----------------------------------------------------------
  // SESSION FLOW
  // ----------------------------------------------------------

  Future<void> _handleSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _goTo(const OnboardingScreen());
        return;
      }

      ApiManager.setUpRequestToken(token);

      final screen = await OnboardingFlowRouter.resolveResumeScreen();

      if (!mounted) return;

      _goTo(screen);
    } catch (e) {
      debugPrint('Session initialization error: $e');
      _goTo(const OnboardingScreen());
    }
  }

  // ----------------------------------------------------------
  // NAVIGATION
  // ----------------------------------------------------------

  void _goTo(Widget screen) {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(AppImages.appLogo, height: 30.h, width: 160.w),
      ),
    );
  }
}
