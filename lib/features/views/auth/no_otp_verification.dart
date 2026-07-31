import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/services/auth_service.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/features/views/auth/login_screen.dart';
import 'package:two_are_one/features/views/auth/sign_up_screen.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/containers.dart';

class NoOtpVerification extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const NoOtpVerification({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<NoOtpVerification> createState() => _NoOtpVerificationState();
}

class _NoOtpVerificationState extends State<NoOtpVerification> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  late String _currentVerificationId;
  bool _isLoading = false;
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  final bool _isError = true;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    String otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = "Invalid OTP");
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: otp,
      );

      await _firebaseAuth.signInWithCredential(credential);

      if (!mounted) return;

      // FIX: Pass the actual phone number, NOT the verificationId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SignUpScreen(verifiedPhoneNo: widget.phoneNumber),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? "Invalid OTP");
    } catch (e) {
      setState(() => _errorMessage = "An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resendOtp() async {
    if (!_canResend) return;
    setState(() => _isLoading = true);

    await _authService.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (newVerificationId) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _currentVerificationId = newVerificationId;
        });
        _startTimer();
      },
      onVerificationFailed: (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        setState(() => _errorMessage = e.message ?? "Failed to resend OTP");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, top: 40.h, right: 20.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Containers(
                  hexValue: 0xFF77153C,
                  opacityValue: 0.15,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  radius: BorderRadius.circular(70.r),
                  wHeight: 470.h,
                  wWidth: screenWidth / 1.15.w,
                  child: Column(
                    children: [
                      SizedBox(height: 25.h),
                      Containers(
                        wHeight: 70.h,
                        wWidth: 70.w,
                        hexValue: 0xFF77153C,
                        opacityValue: .3,
                        radius: BorderRadius.circular(60),
                        child: Center(
                          child: Images(
                            imageStr: 'assets/images/mobile.svg',
                            height: 40.h,
                            width: 21.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        "OTP VERIFICATION",
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        "We've sent a 6 digit OTP to your",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.forgettext,
                        ),
                      ),
                      Texts(
                        text: widget.phoneNumber,
                        colorHexValue: 0xFF000000,
                        size: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      const Texts(
                        edgeInsets: EdgeInsets.only(top: 3),
                        text:
                            "Enter the code below to confirm that it's really you",
                        colorHexValue: 0xFF727272,
                        size: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 40.h),
                      CircleField(controller: _otpController),
                      SizedBox(height: 25.h),
                      if (_errorMessage != null)
                        Texts(
                          text: _errorMessage!,
                          colorHexValue: 0xFFD32F2F,
                          size: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      SizedBox(height: 25.h),
                      Texts(
                        text:
                            "00:${_secondsRemaining.toString().padLeft(2, '0')}",
                        size: 14,
                        fontWeight: FontWeight.bold,
                        colorHexValue: 0xFF77153C,
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive OTP ?",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: AppColors.forgettext,
                            ),
                          ),

                          InkWell(
                            onTap: _canResend ? _resendOtp : null,
                            child: Text(
                              " Send OTP",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: AppColors.mehroon,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * .14),
                  child: MainButtonWidget(
                    text: "Verify",
                    onTap: _verifyOtp,
                    isLoading: _isLoading,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: AppColors.mehroon,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
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
