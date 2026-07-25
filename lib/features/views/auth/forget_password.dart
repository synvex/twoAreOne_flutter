import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 25, left: 25.0, top: 60),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Back_Button(
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Containers(
                  margin: EdgeInsets.only(top: 20),
                  hexValue: 0xFF77153C,
                  opacityValue: 0.15,
                  radius: BorderRadius.circular(40),
                  wHeight: 400,
                  wWidth: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50.h),
                      Containers(
                        wHeight: 70.h,
                        wWidth: 70.h,
                        hexValue: 0xFFC8A0B0,
                        shape: BoxShape.circle,
                        child: MyIcons(iconData: Icons.mail_outlined, size: 30),
                      ),
                      SizedBox(height: 20.h),
                      Texts(
                        text: "Forget Password ?",
                        size: 26,
                        fontWeight: FontWeight.w600,
                        colorHexValue: 0xFF000000,
                        edgeInsets: EdgeInsets.only(bottom: 10),
                      ),
                      Texts(
                        textAlign: TextAlign.center,
                        size: 13,
                        colorHexValue: 0xFF727272,
                        text:
                            " Don’t worry, it happens to all of us. Just\nenter your"
                            " email address and we’ll send you\na one-time code to help you get back in",
                      ),
                      SizedBox(height: 50.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * .23),
                  child: MainButtonWidget(
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
                ),
                SizedBox(height: isLandscape ? 20 : 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
