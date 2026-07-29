import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/back_button.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/services/auth_service.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import '../../../core/routes/flow_router.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';
import 'new_password.dart';

class EmailOtpVerification extends StatefulWidget {
  final String email;
  final bool isFromForget;
  const EmailOtpVerification({
    super.key,
    required this.email,
    required this.isFromForget,
  });

  @override
  State<EmailOtpVerification> createState() => _EmailOtpVerificationState();
}

class _EmailOtpVerificationState extends State<EmailOtpVerification> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isResendAvailable = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _isResendAvailable = false;
    _timer?.cancel(); // Cancel any existing timers before starting a new one

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _isResendAvailable = true;
          _timer?.cancel(); // Stop tracking once it reaches 0
        });
      }
    });
  }

  // 4. FORMAT SECONDS INT TO A "00:SS" STRING CONVERSION
  String get _formattedTime {
    String seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "00:$seconds";
  }

  void _resendOtp() async {
    if (!_isResendAvailable) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      // Determine which API to call based on the flow
      if (widget.isFromForget) {
        // For Forgot Password, resending is usually just calling forgotPassword again
        result = await _authService.forgotPassword(email: widget.email);
      } else {
        // For Registration, call your resend API
        result = await _authService.resendEmailOtp(email: widget.email);
      }

      if (result['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("A new OTP has been sent!")),
        );
        _startTimer(); // Restart the 60 seconds countdown
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Texts(text: result['error'] ?? "Failed to resend OTP"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Texts(text: "Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _verifyOtp() async {
    String otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 6-digit OTP")),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final result = await _authService.verifyEmailOtp(
        email: widget.email,
        otp: otp,
        isFromForget: widget.isFromForget,
      );

      if (result['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account verified successfully!")),
        );
        if (widget.isFromForget) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => NewPassword(email: widget.email),
            ),
            (route) => false,
          );
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) =>
          //   const NewPassword()),
          // );
        } else {
          // SIGN UP FLOW: Resolve where the user left off (Gender, Profile, or Home)
          final nextScreen = await OnboardingFlowRouter.resolveResumeScreen();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
            (route) => false,
          );
        }
        // else {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => const MainScreen()),
        //   );
        // }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? "Verification failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
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
          padding: EdgeInsets.only(right: 20.w, left: 20.w, top: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeaderWidget(isTrailing: false),
                Containers(
                  padding: EdgeInsets.only(top: 15),
                  margin: EdgeInsets.only(top: 15),
                  hexValue: 0xFF77153C,
                  opacityValue: 0.15,
                  radius: BorderRadius.circular(20),
                  wHeight: 400,
                  wWidth: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: 15.h),
                      Containers(
                        wHeight: 70.h,
                        wWidth: 70.w,
                        hexValue: 0xFF77153C,
                        opacityValue: .3,
                        radius: BorderRadius.circular(50.sp),
                        child: Center(
                          child: Images(
                            imageStr: 'assets/images/mobile.svg',
                            height: 40.h,
                            width: 21.w,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        "OTP VERIFICATION",
                        style: GoogleFonts.poppins(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),

                      SizedBox(height: 10.h),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "We’ve sent a 6-digit code to your\n",
                          style: GoogleFonts.inter(
                            color: Color(0xFF727272),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: "${widget.email}\n",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  'Enter the code below to confirm it’s really you',
                              style: TextStyle(
                                color: Color(0xFF727272),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50.h),
                      CircleField(controller: _otpController),
                      SizedBox(height: 15.h),
                      Texts(
                        text: _formattedTime,
                        size: 12,
                        fontWeight: FontWeight.w400,
                        colorHexValue: _isResendAvailable
                            ? 0xFF727272
                            : 0xFF77153C,
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Texts(
                            text: "Didn't receive OTP ?",
                            colorHexValue: 0xFF727272,
                            size: 13,
                          ),
                          InkWell(
                            onTap: _isResendAvailable ? _resendOtp : null,
                            child: Texts(
                              text: " Send OTP",
                              fontWeight: FontWeight.w500,
                              colorHexValue: _isResendAvailable
                                  ? 0xFF77153C
                                  : 0xFFB0B0B0,
                              size: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * .23),
                  child: MainButtonWidget(
                    isLoading: _isLoading,
                    text: "Verify",
                    hexValue: 0xFFFFFFFF,
                    onTap: _verifyOtp,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Texts(
                      text: "Already have an account?",
                      colorHexValue: 0xFF77153C,
                      size: 15,
                    ),
                    InkWell(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                      child: const Texts(
                        text: " Login",
                        fontWeight: FontWeight.w500,
                        colorHexValue: 0xFF000000,
                        size: 14,
                      ),
                    ),
                  ],
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
