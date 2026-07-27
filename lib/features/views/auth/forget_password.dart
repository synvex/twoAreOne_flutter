import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/constants/app_icons.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/back_button.dart';
import 'package:two_are_one/core/widgets/my_icons.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/services/auth_service.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/failed.dart';
import 'email_otp_verification.dart';

class ForgetPassword extends StatefulWidget {
  final String? email;
  const ForgetPassword({super.key, required this.email});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    final email = _emailController.text.trim();

    // 1. Validation (Matches RN validateInputs)
    if (email.isEmpty) {
      _showErrorDialog("Email is required");
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorDialog("Email is invalid");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. API Call (Matches RN ApiManager.fetch)
      final existenceCheck = await _authService.checkEmailExists(email: email);
      if (existenceCheck['success'] == false) {
        _showUserNotFoundDialog();
      } else {
        final result = await _authService.forgotPassword(email: email);
        if (result['success']) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EmailOtpVerification(email: email, isFromForget: true),
            ),
          );
        } else {
          _showErrorDialog(result['error'] ?? "Failed to send OTP");
        }
      }
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUserNotFoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                const FailedWidget(),
                SizedBox(height: 10.h),
                const Text(
                  "Oops, Failed!",
                  style: TextStyle(
                    color: Color(0xFFdf605f),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15.h),
                const Texts(
                  textAlign: TextAlign.center,
                  text: "Email not found",
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
  }

  void _showErrorDialog(String message, {String title = "Oops, Failed!"}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FailedWidget(),
              const SizedBox(height: 15),
              Texts(
                text: title,
                colorHexValue: 0xFFdf605f,
                size: 22,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 15),
              Texts(
                textAlign: TextAlign.center,
                text: message,
                size: 14,
                colorHexValue: 0xFF4D4D4D,
              ),
              SizedBox(height: 25.h),
              MainButtonWidget(
                height: 50.h,
                text: "Close",
                onTap: () => Navigator.pop(context),
                gradient: const LinearGradient(
                  colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(right: 25.w, left: 25.0.w, top: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeaderWidget(isLeading: true, isTrailing: false),
                Container(
                  margin: EdgeInsets.only(top: 20.h),
                  width: double.infinity,
                  height: 400.h,
                  decoration: BoxDecoration(
                    color: AppColors.mehroon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50.h),

                      Container(
                        width: 70.h,
                        height: 70.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC8A0B0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(AppIcons.mailIcon, size: 30),
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        "Forget Password ?",
                        style: GoogleFonts.inter(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        "Don’t worry, it happens to all of us. Just\n"
                        "enter your email address and we’ll send you\n"
                        "a one-time code to help you get back in",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 50.h),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomInputField(
                          controller: _emailController,
                          fillColor: 0xFFFFFFFF,

                          borderColor: 0xFF77153C,
                          hintText: "Enter your email address",
                          prefixIcon: Icons.mail_outline,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 200.h),
                MainButtonWidget(
                  isLoading: _isLoading,
                  text: "Continue",
                  hexValue: 0xFFFFFFFF,
                  onTap: () {
                    _handleContinue();
                  },
                  gradient: LinearGradient(
                    colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
