import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/features/auth/sign_up.dart';
import 'package:two_are_one/services/auth_service.dart';
import '../../core/back_button.dart';
import '../../core/buttons.dart';
import '../../core/textfield.dart';

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
  bool _isError = true;

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
    _timer = Timer.periodic(
        const Duration(seconds: 1), (timer) {
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
            builder: (context) => SignUpPage(
              verifiedPhoneNo: widget.phoneNumber, 
            )),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Containers(
                  hexValue: 0xFF77153C,
                  opacityValue: 0.15,
                  radius: BorderRadius.circular(70),
                  wHeight: 470,
                  wWidth: screenWidth / 1.15,
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Containers(
                        wHeight: 70, wWidth: 70, hexValue: 0xFF77153C, opacityValue: .3, radius: BorderRadius.circular(60),
                        child: Center(child: Images(imageStr: 'assets/images/mobile.svg', height: 40, width: 21)),
                      ),
                      const SizedBox(height: 15),
                      const Texts(text: "OTP VERIFICATION", size: 24, fontWeight: FontWeight.w600),
                      const SizedBox(height: 15),
                      const Texts(text: "We've sent a 6 digit OTP to your",
                          colorHexValue: 0xFF727272, size: 13, fontWeight: FontWeight.w500),
                      Texts(text: widget.phoneNumber, colorHexValue: 0xFF000000, size: 13, fontWeight: FontWeight.w500),
                      const Texts(edgeInsets:EdgeInsets.only(top: 3), text: "Enter the code below to confirm that it's really you", colorHexValue: 0xFF727272, size: 13, fontWeight: FontWeight.w500),
                      const SizedBox(height: 40),
                      CircleField(controller: _otpController),
                      const SizedBox(height: 25),
                      if (_errorMessage != null)
                        Texts(text: _errorMessage!, colorHexValue: 0xFFD32F2F, size: 13, fontWeight: FontWeight.w500),
                      const SizedBox(height: 25),
                      Texts(text: "00:${_secondsRemaining.toString().padLeft(2, '0')}", size: 14, fontWeight: FontWeight.bold, colorHexValue: 0xFF77153C),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Texts(text: "Didn't receive OTP ?", colorHexValue: 0xFF727272, size: 13),
                          InkWell(
                            onTap: _canResend ? _resendOtp : null,
                            child: const Texts(text: " Send OTP", fontWeight: FontWeight.w500, colorHexValue: 0xFF77153C, size: 13),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * .14),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF77153C))
                      : Buttons(
                          text: "Verify",
                          onTap: _verifyOtp,
                          gradient: const LinearGradient(colors: [Color(0xFF77153C), Color(0xFFDD276F)]),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Texts(text: "Already have an account? ", colorHexValue: 0xFF77153C),
                    GestureDetector(
                      onTap: () {},
                      child: const Texts(text: "Login", fontWeight: FontWeight.bold, colorHexValue: 0xFF000000),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
