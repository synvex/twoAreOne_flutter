import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/data/services/auth_service.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/failed.dart';
import 'package:two_are_one/features/views/auth/onboarding.dart';
import 'package:two_are_one/features/views/auth/forget_password.dart';
import '../../../core/routes/flow_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  late final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Clear error as soon as user types anything
    _emailController.addListener(() => setState(() => _emailError = null));
    _passwordController.addListener(
      () => setState(() => _passwordError = null),
    );
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final emailError = _validateEmail(email);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      return;
    }
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      return;
    }

    if (emailError != null || passwordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _emailError = emailError;
      _passwordError = passwordError;
    });
    try {
      final result = await _authService.login(email: email, password: password);

      if (!mounted) return;
      if (result['success'] == true) {
        final userData = result['data']; // The nested 'data' object
        final token =
            userData?['api_token']?.toString() ??
            userData?['token']?.toString() ??
            '';
        if (token.isNotEmpty) {
          ApiManager.setUpRequestToken(token); // sets Dio headers immediately
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString(
            'user_full_name',
            result['data']?['full_name']?.toString() ?? '',
          );
          await prefs.setString(
            'user_email',
            result['data']?['email']?.toString() ?? '',
          );
          await prefs.setString(
            'profile_image_url',
            result['data']?['profile_picture']?.toString() ?? '',
          );
          print("✅ Token set successfully: $token");
        }
        final nextScreen = await OnboardingFlowRouter.resolveResumeScreen();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
// <<<<<<< saqlain-02
          MaterialPageRoute(builder: (context) => nextScreen),
            (route) => false,
          //     const MainBarScreen(
          //       initialIndex: 0,)),
          // (route) => false,
// =======
//           MaterialPageRoute(builder: (context) => const CustomNavBar()),
//           (route) => false,
// >>>>>>> refector
        );
      } else {
        // FAILURE - The alert/snackbar will now show the real error from PHP
        String errorMsg = result['error'] ?? "Incorrect email or password";
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            bool isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 30, width: double.infinity),
                    const FailedWidget(),
                    const SizedBox(height: 20),
                    const Texts(
                      text: "Oops, Failed!",
                      colorHexValue: 0xFFdf605f,
                      size: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 15),
                    Texts(
                      textAlign: TextAlign.center,
                      text: errorMsg.isEmpty ? "Login failed" : errorMsg,
                      size: 14,
                      colorHexValue: 0xFF4D4D4D,
                    ),
                    const SizedBox(height: 25),
                    MainButtonWidget(
                      height: 50,
                      text: "Close",

                      onTap: () => Navigator.pop(context),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        debugPrint("❌ Login failed: $errorMsg");
      }
    } on SocketException {
      _showErrorDialog(
        "No internet connection. Please check your network and try again.",
      );
    } on TimeoutException {
      _showErrorDialog(
        "Server is taking too long to respond. Please try again.",
      );
    } catch (e) {
      _showErrorDialog("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  String? _validateEmail(String email) {
    if (email.isEmpty) return "Email is required";

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Email is invalid";
    }

    return null; // valid
  }
  String? _validatePassword(String password) {
    if (password.isEmpty) return "Password is required";
    return null; // valid
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const FailedWidget(),
              const SizedBox(height: 20),
              const Texts(
                text: "Oops, Failed!",
                colorHexValue: 0xFFdf605f,
                size: 22,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 15),
              Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Texts(text: message, size: 18),
              ),
              const SizedBox(height: 25),
              MainButtonWidget(
                height: 50,
                text: "Close",
                onTap: () => Navigator.pop(context),
                gradient: const LinearGradient(
                  colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                ),
              ),
              //   Texts(text: "Login Failed",
              //       size: 18, fontWeight: FontWeight.w600,)
            ],
          ),
        ),
        actions: [
          TxtButton(
            text: 'Try Again',
            onTap: () {
              Navigator.pop(context);
            },
            colorHex: 0xFFDD276F,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              AppHeaderWidget(
                onLeadingTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OnboardingScreen()),
                ),
                isLeading: true,
                isTrailing: false,
              ),
              SizedBox(height: 37.h),
              Images(
                imageStr: 'assets/images/two_are_one.png',
                height: 51.h,
                width: 215.w,
              ),
              SizedBox(height: 10.h),
              Text(
                "Welcome Back",
                style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Reconnect with your matches and\nexplore exciting new connections.",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w300,

                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 35.h),
              // Email Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0, bottom: 10),
                  child: Texts(
                    text: "Email",
                    fontWeight: FontWeight.w400,
                    size: 16,
                  ),
                ),
              ),
              CustomInputField(
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                hintText: "Enter your email",
              ),
              SizedBox(height: 10.h),
              if (_emailError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Texts(
                      text: _emailError!,
                      colorHexValue: 0xFFD32F2F,
                      size: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              // Password Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0, bottom: 5),
                  child: Texts(
                    text: "Password",
                    fontWeight: FontWeight.w400,
                    size: 16,
                  ),
                ),
              ),
              CustomInputField(
                controller: _passwordController,
                hintText: "Password",
                prefixIcon: Icons.lock_open,
                isPassword: _obscurePassword,
                suffixIcon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF787878),
                ),
                onTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              SizedBox(height: 16.h),
              if (_passwordError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Texts(
                      text: _passwordError!,
                      colorHexValue: 0xFFD32F2F,
                      size: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgetPassword(email: ''),
                    ),
                  ),
                  child: Text(
                    "Forgot the Password?",
                    style: GoogleFonts.inter(
                      color: AppColors.primaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: MainButtonWidget(
                  text: 'Login',
                  hexValue: 0xFFFFFFFF,
                  isLoading: _isLoading,
                  onTap: _handleLogin,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
