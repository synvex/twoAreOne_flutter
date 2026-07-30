import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/data/services/auth_service.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'no_otp_verification.dart';

class NoVerification extends StatefulWidget {
  const NoVerification({super.key});

  @override
  State<NoVerification> createState() => _NoVerificationState();
}

class _NoVerificationState extends State<NoVerification> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _selectedCountryCode = "+92";
  String _selectedCountryName = "PK";
  String? _errorMessage;

  void _verifyPhoneNo() async {
    // 1. Sanitize Input
    String inputDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    String selectedCodeDigits = _selectedCountryCode.replaceAll(
      RegExp(r'\D'),
      '',
    );
    String localNumber = inputDigits;

    // Handle double-prefixing
    if (inputDigits.startsWith(selectedCodeDigits) &&
        inputDigits.length > selectedCodeDigits.length) {
      localNumber = inputDigits.substring(selectedCodeDigits.length);
    }

    // Strip leading zeros
    if (localNumber.startsWith('0')) {
      localNumber = localNumber.substring(1);
    }

    // Validation
    if (localNumber.length < 9 || localNumber.length > 11) {
      setState(() => _errorMessage = "Please enter a valid phone number");
      return;
    }

    final phoneNoWithCode = "$_selectedCountryCode$localNumber";
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step A: Check database (Matches RN's ApiManager.fetch)
      final result = await _authService.checkPhoneExists(
        phoneNo: phoneNoWithCode,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Phone is available -> Start Firebase (Matches RN's onApiResponse)
        _startFirebaseOTP(phoneNoWithCode);
      } else {
        // Phone exists or other error (Matches RN's onApiError)
        setState(() => _isLoading = false);
        String errorMsg = result['error']?.toString() ?? "";
        if (errorMsg.toLowerCase().contains("already exists") ||
            errorMsg.contains("linked")) {
          _showResultPopup(phoneNoWithCode);
        } else if (errorMsg == "no_internet") {
          _showError(
            "No internet connection. Please check your network and try again.",
          );
        } else if (errorMsg == "timeout") {
          _showError("Server is taking too long. Please try again.");
        } else if (errorMsg == "something_went_wrong") {
          _showError("Something went wrong. Please try again.");
        } else {
          _showError(errorMsg.isEmpty ? "Verification check failed" : errorMsg);
        }
      }
    } on SocketException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(
        "No internet connection. Please check your network and try again.",
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Server is taking too long. Please try again.");
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Something went wrong. Please try again.");
    }
  }

  void _startFirebaseOTP(String phoneNumber) {
    _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NoOtpVerification(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      },
      onVerificationFailed: (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showError(e.message ?? "Firebase could not send OTP");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeaderWidget(isLeading: true, isTrailing: false),
              SizedBox(height: 40.h),
              Text(
                "Can we get your number?",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 24.sp,
                ),
              ),

              SizedBox(height: 30.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _showCountryPicker,
                    child: Container(
                      width: 90.w,
                      padding: const EdgeInsets.only(bottom: 1),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Texts(
                            text: "$_selectedCountryName $_selectedCountryCode",
                            size: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          const Icon(
                            CupertinoIcons.arrowtriangle_down_fill,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(child: TxtField(controller: _phoneController)),
                ],
              ),
              SizedBox(height: 13.h),
              if (_errorMessage != null)
                Texts(
                  text: _errorMessage!,
                  colorHexValue: 0xFFD32F2F,
                  size: 13,
                  fontWeight: FontWeight.w400,
                ),
              const SizedBox(height: 13),
              Text(
                "Enter your phone number. We’ll text you a code\n"
                "to verify it's really you and keep your journey safe.",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500, // optional
                ),
              ),
              Spacer(),
              MainButtonWidget(
                text: "Next",
                onTap: _verifyPhoneNo,
                isLoading: _isLoading,
                gradient: const LinearGradient(
                  colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultPopup(String phoneNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Images(imageStr: "assets/svg_images/error.svg"),
                SizedBox(height: 10.h),
                Text(
                  "Oops, Failed!",
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.failedcolor,
                  ),
                ),

                SizedBox(height: 15.h),
                Text(
                  "This Number is already linked to another account. Please use a different phone number",
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.verifactiontext,
                  ),
                ),

                SizedBox(height: 25.sp),
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

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Texts(text: "Select Country"),
          ),
          ListTile(
            leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
            title: const Text("United States (+1)"),
            onTap: () {
              setState(() {
                _selectedCountryCode = "+1";
                _selectedCountryName = "US";
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Text("🇵🇰", style: TextStyle(fontSize: 24)),
            title: const Text("Pakistan (+92)"),
            onTap: () {
              setState(() {
                _selectedCountryCode = "+92";
                _selectedCountryName = "PK";
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
  }
}
