import 'dart:async';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/services/auth_service.dart';
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
    String inputDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    String selectedCodeDigits = _selectedCountryCode.replaceAll(
      RegExp(r'\D'),
      '',
    );
    String localNumber = inputDigits;
    if (inputDigits.startsWith(selectedCodeDigits) &&
        inputDigits.length > selectedCodeDigits.length) {
      localNumber = inputDigits.substring(selectedCodeDigits.length);
    }
    if (localNumber.startsWith('0')) {
      localNumber = localNumber.substring(1);
    }
    if (localNumber.length < 9 || localNumber.length > 11) {
      setState(() {
        _errorMessage = "Please enter a valid phone number";
      });
      return;
    }

    final phoneNoWithCode = "$_selectedCountryCode$localNumber";

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.checkPhoneExists(phoneNo: phoneNoWithCode);

      if (!mounted) return;

      if (result['success'] == true) {
        _startFirebaseOTP(phoneNoWithCode);
      } else {
        setState(() {
          _isLoading = false;
        });

        final errorMsg = (result['error'] ?? '').toString().toLowerCase();

        if (errorMsg.contains("already exists") || errorMsg.contains("linked")) {
          _showError(
            "This Number is already linked to another account. Please use a different phone number",
          );
        } else if (errorMsg == "no_internet") {
          _showError("No internet connection. Please check your network and try again.");
        } else if (errorMsg == "timeout") {
          _showError("Server is taking too long. Please try again.");
        } else if (errorMsg == "something_went_wrong") {
          _showError("Something went wrong. Please try again.");
        } else {
          _showError(
            errorMsg.isEmpty ? "Verification check failed" : result['error'].toString(),
          );
        }
      }
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showError("No internet connection. Please check your network and try again.");
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showError("Server is taking too long. Please try again.");
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showError("Something went wrong. Please try again.");
    }
  }

  void _startFirebaseOTP(String phoneNumber) {
    _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NoOtpVerification(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      },
      onVerificationFailed: (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage = e.message ?? "Failed to send OTP. Please try again.";
        });
      },
    );
  }

  void _showError(String msg) {
    setState(() {
      _errorMessage = msg;
    });
  }

  // void _verifyPhoneNo() async {
  //   String inputDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
  //   String selectedCodeDigits = _selectedCountryCode.replaceAll(
  //     RegExp(r'\D'),
  //     '',
  //   );
  //
  //   String localNumber = inputDigits;
  //
  //   if (inputDigits.startsWith(selectedCodeDigits) &&
  //       inputDigits.length > selectedCodeDigits.length) {
  //     localNumber = inputDigits.substring(selectedCodeDigits.length);
  //   }
  //
  //   if (localNumber.startsWith('0')) {
  //     localNumber = localNumber.substring(1);
  //   }
  //
  //   if (localNumber.length < 9 || localNumber.length > 11) {
  //     setState(() {
  //       _errorMessage = "Please enter a valid phone number";
  //     });
  //     return;
  //   }
  //
  //   final phoneNoWithCode = "$_selectedCountryCode$localNumber";
  //
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });
  //
  //   try {
  //     final result = await _authService.checkPhoneExists(
  //       phoneNo: phoneNoWithCode,
  //     );
  //
  //     if (!mounted) return;
  //
  //     if (result['success'] == true) {
  //       _startFirebaseOTP(phoneNoWithCode);
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //
  //       String errorMsg = result['error']?.toString() ?? "";
  //
  //       if (errorMsg.toLowerCase().contains("already exists") ||
  //           errorMsg.contains("linked")) {
  //         _showResultPopup(phoneNoWithCode);
  //       } else if (errorMsg == "no_internet") {
  //         _showError(
  //           "No internet connection. Please check your network and try again.",
  //         );
  //       } else if (errorMsg == "timeout") {
  //         _showError("Server is taking too long. Please try again.");
  //       } else if (errorMsg == "something_went_wrong") {
  //         _showError("Something went wrong. Please try again.");
  //       } else {
  //         _showError(errorMsg.isEmpty ? "Verification check failed" : errorMsg);
  //       }
  //     }
  //   } on SocketException {
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     _showError(
  //       "No internet connection. Please check your network and try again.",
  //     );
  //   } on TimeoutException {
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     _showError("Server is taking too long. Please try again.");
  //   } catch (e) {
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     _showError("Something went wrong. Please try again.");
  //   }
  // }
  //
  // void _startFirebaseOTP(String phoneNumber) {
  //   _authService.verifyPhoneNumber(
  //     phoneNumber: phoneNumber,
  //     onCodeSent: (verificationId) {
  //       if (!mounted) return;
  //
  //       setState(() {
  //         _isLoading = false;
  //       });
  //
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => NoOtpVerification(
  //             phoneNumber: phoneNumber,
  //             verificationId: verificationId,
  //           ),
  //         ),
  //       );
  //     },
  //     onVerificationFailed: (e) {
  //       if (!mounted) return;
  //       setState(() {
  //         _isLoading = false;
  //         _errorMessage = e.message?? "Please enter a valid phone number";
  //       });
  //     },
  //   );
  // }
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
              AppHeaderWidget(
                  isLeading: true, isTrailing: false),
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
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 120.w,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    child: CountryCodePicker(
                      initialSelection: "PK",
                      favorite: const ["PK", "US"],
                      showFlag: true,
                      showFlagDialog: true,
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: true,
                      padding: EdgeInsets.only(top: 10, left: 0),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      onChanged: (country) {
                        setState(() {
                          _selectedCountryCode = country.dialCode ?? "+92";
                          _selectedCountryName = country.code ?? "PK";
                        });
                      },
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
              SizedBox(height: 13.h),
              Text(
                "Enter your phone number. We’ll text you a code\n"
                "to verify it's really you and keep your journey safe.",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              MainButtonWidget(
                text: "Next",
                isLoading: _isLoading,
                onTap: _verifyPhoneNo,
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
      builder: (_) {
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
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25.h),
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

  // void _showError(String msg) {
  //   setState(() {
  //     _errorMessage = msg;
  //   });
  // }
}
