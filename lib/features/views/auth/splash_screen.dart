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

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  bool _openingSettings = false;
  bool _checkingPermissions = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when user returns from App Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openingSettings) {
      _openingSettings = false;

      _checkPermissions();
    }
  }

  // ----------------------------------------------------------
  // PERMISSION FLOW
  // ----------------------------------------------------------

  Future<void> _checkPermissions() async {
    if (_checkingPermissions) return;

    _checkingPermissions = true;

    // Check required permissions
    final hasPermissions = await PermissionManager.instance
        .checkRequiredPermissions();

    if (!mounted) return;

    // All required permissions already allowed
    if (hasPermissions) {
      _checkingPermissions = false;

      _handleSession();
      return;
    }

    // Request required permissions
    final granted = await PermissionManager.instance
        .requestRequiredPermissions();

    if (!mounted) return;

    // User allowed all required permissions
    if (granted) {
      _checkingPermissions = false;

      _handleSession();
      return;
    }

    // Required permission still denied
    // Send user to application settings
    _checkingPermissions = false;
    _openingSettings = true;

    await PermissionManager.instance.openSettings();
  }

  // ----------------------------------------------------------
  // SESSION FLOW
  // ----------------------------------------------------------

  Future<void> _handleSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('auth_token');

      // No token = user is not logged in
      if (token == null || token.isEmpty) {
        _goTo(const OnboardingScreen());
        return;
      }

      // Token exists, configure API authorization
      ApiManager.setUpRequestToken(token);

      // Resume user's correct screen
      final screen = await OnboardingFlowRouter.resolveResumeScreen();

      if (!mounted) return;

      _goTo(screen);
    } catch (e) {
      debugPrint('Session initialization error: $e');

      // If session initialization fails,
      // send user to onboarding.
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
