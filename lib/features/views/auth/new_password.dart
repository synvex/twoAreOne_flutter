import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/back_button.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/services/auth_service.dart'; // Import AuthService
import 'package:two_are_one/features/provider/password_visibility_provider.dart';
import 'login_screen.dart';

class NewPassword extends StatefulWidget {
  final String email; // Added email field
  const NewPassword({super.key, required this.email}); // Updated constructor

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  // Added controllers and service
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // The requested handle reset logic
  void _handleReset() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. Validate fields and match
    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Call AuthService.resetPassword
      final result = await _authService.resetPassword(
        email: widget.email,
        newPassword: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      // 3. Handle result
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset successfully! Please login."),
          ),
        );

        // Success: Clear stack and go to Login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? "Failed to reset password"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final passwordVisibilityProvider = Provider.of<PasswordVisibilityProvider>(
      context,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(right: 20, left: 20.0, top: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeaderWidget(isTrailing: false),
                Containers(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  hexValue: 0xFF77153C,
                  opacityValue: 0.15,
                  radius: BorderRadius.circular(40),
                  wHeight: 450,
                  wWidth: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      const Texts(
                        text: "Create New Password",
                        size: 26,
                        fontWeight: FontWeight.w600,
                        colorHexValue: 0xFF000000,
                      ),
                      const Texts(
                        textAlign: TextAlign.center,
                        size: 13,
                        colorHexValue: 0xFF727272,
                        text:
                            "Set a new password and you're all set to explore\nnew connections",
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Texts(
                          edgeInsets: EdgeInsets.only(
                            top: 30,
                            bottom: 8,
                            left: 8,
                          ),
                          text: "New Password",
                        ),
                      ),

                      Consumer<PasswordVisibilityProvider>(
                        builder: (context, value, child) {
                          return CustomInputField(
                            controller: _passwordController,
                            isPassword: value.isPasswordVisible,
                            fillColor: 0xFFEBDCE2,
                            borderColor: 0xFF847B7F,
                            hintText: "Enter your new password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                value.togglePasswordVisibility();
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              icon: Icon(
                                value.isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          );
                        },
                      ),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Texts(
                          edgeInsets: EdgeInsets.only(
                            top: 15,
                            bottom: 8,
                            left: 8,
                          ),
                          text: "Confirm Password",
                        ),
                      ),

                      Consumer<PasswordVisibilityProvider>(
                        builder: (context, value, child) {
                          return CustomInputField(
                            controller:
                                _confirmPasswordController, // Bind controller
                            isPassword: value.isConfirmPasswordVisible,
                            fillColor: 0xFFEBDCE2,
                            borderColor: 0xFF847B7F,
                            suffixIcon: IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              onPressed: () {
                                value.toggleConfirmPasswordVisibility();
                              },
                              icon: Icon(
                                value.isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                            hintText: "Confirm your password",
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * .15),
                  child: MainButtonWidget(
                    text: "Submit",
                    isLoading: _isLoading,
                    hexValue: 0xFFFFFFFF,
                    onTap: _handleReset, // Trigger logic
                    gradient: const LinearGradient(
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

// import 'package:flutter/material.dart';
// import 'package:two_are_one/core/widgets/back_button.dart';
// import 'package:two_are_one/core/widgets/main_button_widget.dart';
// import 'package:two_are_one/core/widgets/containers.dart';
// import 'package:two_are_one/core/widgets/textfield.dart';
// import 'package:two_are_one/core/widgets/texts.dart';
// import 'login_screen.dart';
// import 'onboarding_screen.dart';
//
// class NewPassword extends StatefulWidget {
//   const NewPassword({super.key});
//
//   @override
//   State<NewPassword> createState() => _NewPasswordState();
// }
//
// class _NewPasswordState extends State<NewPassword> {
//   final bool _isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final bool isLandscape =
//         MediaQuery.of(context).orientation == Orientation.landscape;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: false,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.only(right: 20, left: 20.0, top: 50),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Back_Button(
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => LoginScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 Containers(
//                   margin: EdgeInsets.only(top: 20),
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   hexValue: 0xFF77153C,
//                   opacityValue: 0.15,
//                   radius: BorderRadius.circular(40),
//                   wHeight: 450,
//                   wWidth: double.infinity,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(height: 100),
//                       Texts(
//                         text: "Create New Password",
//                         size: 26,
//                         fontWeight: FontWeight.w600,
//                         colorHexValue: 0xFF000000,
//                       ),
//                       Texts(
//                         textAlign: TextAlign.center,
//                         size: 13,
//                         colorHexValue: 0xFF727272,
//                         text:
//                             " Set a new password and you're all set to explore\nnew connections",
//                       ),
//                       Align(
//                         alignment: AlignmentGeometry.centerLeft,
//                         child: Texts(
//                           edgeInsets: EdgeInsets.only(
//                             top: 15,
//                             bottom: 8,
//                             left: 8,
//                           ),
//                           text: "New Password",
//                         ),
//                       ),
//                       CustomInputField(
//                         fillColor: 0xFFEBDCE2,
//                         borderColor: 0xFF847B7F,
//                         hintText: "Enter your new password",
//                         label: 'New Password',
//                       ),
//                       Align(
//                         alignment: AlignmentGeometry.centerLeft,
//                         child: Texts(
//                           edgeInsets: EdgeInsets.only(
//                             top: 10,
//                             bottom: 8,
//                             left: 8,
//                           ),
//                           text: "Confirm Password",
//                         ),
//                       ),
//                       CustomInputField(
//                         fillColor: 0xFFEBDCE2,
//                         borderColor: 0xFF847B7F,
//                         hintText: "Confirm your password",
//                         label: 'Confirm Password',
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(top: screenHeight * .21),
//                   child: MainButtonWidget(
//                     text: "Submit",
//                     isLoading: _isLoading,
//                     hexValue: 0xFFFFFFFF,
//                     onTap: () {
//                       setState(() {});
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginScreen()),
//                       );
//                     },
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF77153C), Color(0xFFDD276F)],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: isLandscape ? 20 : 0),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
