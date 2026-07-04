import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/core/my_icons.dart';
import 'package:two_are_one/features/auth/forget_password.dart';
import 'package:two_are_one/features/main_screens/main_screen.dart';
import '../../core/back_button.dart';
import '../../core/buttons.dart';
import '../../core/image.dart';
import '../../core/textfield.dart';
import '../../core/texts.dart';
import '../../services/Api_Helper/api_manager.dart';
import '../../services/auth_service.dart';
import '../Bottom_Nav_Bar_Screens/custom_nav_bar.dart';
import 'failed.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Define Controllers and State
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
    _passwordController.addListener(() => setState(() => _passwordError = null));
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
    // if (email.isEmpty) {
    //   setState(() => _emailError = "Email is required");
    //   return;
    // }
    // if (password.isEmpty) {
    //   setState(() => _passwordError = "Password is required");
    //   return;
    // }
    setState(() {
      _isLoading = true;
      _emailError = emailError;
      _passwordError = passwordError;
    });

    try {
      final result = await _authService.login(
          email: email, password: password);

      if (!mounted) return;
      if (result['success'] == true) {
        final responseBody = result['data'];
        final userData = responseBody['data']; // The nested 'data' object

        // final token = result['data']?['api_token']?.toString() ?? '';
        final token = userData?['api_token']?.toString() ??
            userData?['token']?.toString() ?? '';
        if (token.isNotEmpty) {
          ApiManager.setUpRequestToken(token); // sets Dio headers immediately
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_full_name', result['data']?['full_name']?.toString() ?? '');
          await prefs.setString('user_email', result['data']?['email']?.toString() ?? '');
          await prefs.setString('profile_image_url', result['data']?['profile_picture']?.toString() ?? '');
          print("✅ Token set successfully: $token");
        }
        // SUCCESS
        // Navigate and clear navigation stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const MainBarScreen()),
              (route) => false,
        );
      }
      else {
        // FAILURE - The alert/snackbar will now show the real error from PHP
         String _errorMsg = result[
                  'error'] ?? "Incorrect email or password";
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 30,
                    width: double.infinity,
                    ),
                    const FailedWidget(),
                    const SizedBox(height: 20),
                    const Texts(text: "Oops, Failed!",  colorHexValue: 0xFFdf605f,
                        size: 22, fontWeight: FontWeight.bold),
                    const SizedBox(height: 15),
                     Texts(
                      textAlign: TextAlign.center,
                      text: _errorMsg.isEmpty ? "Login failed" : _errorMsg,
                      size: 14, colorHexValue: 0xFF4D4D4D,
                    ),
                    const SizedBox(height: 25),
                    Buttons(
                      height: 50,
                      text: "Close",

                      onTap: () => Navigator.pop(context),
                      gradient: const LinearGradient(colors: [Color(0xFF77153C), Color(0xFFDD276F)]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } on SocketException{
      _showErrorDialog("No internet connection. Please check your network and try again.");
    } on TimeoutException {
      _showErrorDialog("Server is taking too long to respond. Please try again.");
    }
    catch (e) {
      _showErrorDialog("Something went wrong. Please try again.");
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (context) {
      //     bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
      //     return AlertDialog(
      //       backgroundColor: Colors.white,
      //       surfaceTintColor: Colors.white,
      //       shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(24)),
      //       content: SingleChildScrollView(
      //         child: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             SizedBox(height: 20),
      //             const FailedWidget(),
      //             const SizedBox(height: 10),
      //             const Texts(text: "Oops, Failed!",  colorHexValue: 0xFFdf605f,
      //                 size: 22, fontWeight: FontWeight.bold),
      //             const SizedBox(height: 15),
      //             const Texts(
      //               textAlign: TextAlign.center,
      //               text: "An error occurred. Please try again.",
      //               size: 14, colorHexValue: 0xFF4D4D4D,
      //             ),
      //             const SizedBox(height: 25),
      //             Buttons(
      //               height: 50,
      //               text: "Close",
      //               onTap: () => Navigator.pop(context),
      //               gradient: const LinearGradient(colors: [Color(0xFF77153C), Color(0xFFDD276F)]),
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // );
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
    // if (password.length < 8) return "Password must be at least 8 characters";
    // if (!password.contains(RegExp(r'[A-Z]'))) return "Password must contain at least one uppercase letter";
    // if (!password.contains(RegExp(r'[a-z]'))) return "Password must contain at least one lowercase letter";
    // if (!password.contains(RegExp(r'[0-9]'))) return "Password must contain at least one number";
    // if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) return "Password must contain at least one special character";
    return null; // valid
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const FailedWidget(),
              const SizedBox(height: 20),
              const Texts(text: "Oops, Failed!",  colorHexValue: 0xFFdf605f,
                  size: 22, fontWeight: FontWeight.bold),
              const SizedBox(height: 15),
              Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: Texts(text: message, size: 18,)),
              const SizedBox(height: 25),
              Buttons(
                 height: 50,
                text: "Close",
                onTap: () => Navigator.pop(context),
                gradient: const LinearGradient(colors: [Color(0xFF77153C), Color(0xFFDD276F)]),
              ),
            //   Texts(text: "Login Failed",
            //       size: 18, fontWeight: FontWeight.w600,)
             ],
          ),
        ),
        actions: [
          TxtButton(
            text: 'Try Again', onTap: () {Navigator.pop(context);},
            colorHex: 0xFFDD276F,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
  // void _handleLogin() async {
  //   final email = _emailController.text.trim();
  //   final password = _passwordController.text.trim();
  //
  //   if (email.isEmpty || password.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please fill in all fields")),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final result = await _authService.login(
  //         email: email, password: password);
  //
  //     if (result['success']) {
  //       if (!mounted) return;
  //       // Navigate to Home Screen (or Questionnaire if that's your flow)
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => MainScreen(),));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(
  //             result['error'] ?? "Login failed")),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.topLeft,
                child: Back_Button(
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 37),
              const Images(
                imageStr: 'assets/images/two_are_one.png',
                height: 51,
                width: 215,
              ),
              const SizedBox(height: 10),
              const Texts(
                text: "Welcome Back",
                colorHexValue: 0xFF4D4D4D,
                size: 20,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 15,),
              const Texts(
                textAlign: TextAlign.center,
                text: "Reconnect with your matches and\nexplore exciting new connections.",
                colorHexValue: 0xFF333333,
                size: 13,
                fontWeight: FontWeight.w300,
              ),
              const SizedBox(height: 35),
              // Email Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0, bottom: 10),
                  child: Texts(text: "Email", fontWeight: FontWeight.w400, size: 16),
                ),
              ),
              CustomInputField(
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                label: "Email",
                hintText: "Enter your email",
              ),
              const SizedBox(height: 10),
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
                  child: Texts(text: "Password",
                      fontWeight: FontWeight.w400, size: 16),
                ),
              ),
              CustomInputField(
                controller: _passwordController,
                label: "Password",
                hintText: "Password",
                prefixIcon: Icons.lock_open,
                isPassword: _obscurePassword,
                suffixIcon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(
                    0xFF787878)),
                onTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 6),
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
              // Checkbox and Forget Password Row
              Row(
                children: [
                  const Spacer(),
                  TxtButton(
                    fontWeight: FontWeight.w500,
                    text: "Forgot the Password?",
                    sizeTxt: 12,
                    colorHex: 0xFF000000,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const ForgetPassword(email: '',)));
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Buttons(
                  text: 'Login',
                  hexValue: 0xFFFFFFFF,
                  isLoading: _isLoading,
                  onTap: _handleLogin,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Divider
              Row(
                children: [
                  const Expanded(child: Images(imageStr: "assets/images/left_polygon.svg")),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Texts(
                        text: "Or Login with",
                        colorHexValue: 0xFF000000,
                        size: 12,
                        fontWeight: FontWeight.w300),
                  ),
                  const Expanded(child: Images(imageStr: 'assets/images/right_polygon.svg')),
                ],
              ),
              const SizedBox(height: 30),
              // Social Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Images(imageStr: "assets/images/apple_img.png", height: 42, width: 42),
                  const SizedBox(width: 17),
                  const Images(imageStr: "assets/images/google_img.png", height: 42, width: 42),
                ],
              ),
              const SizedBox(height: 60),
              // Footer: Sign Up Link
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
              //     GestureDetector(
              //       onTap: () => Navigator.pushReplacement(
              //         context,
              //         MaterialPageRoute(builder: (context) => const MainScreen()),
              //       ),
              //       child: const Text(
              //         "Sign Up",
              //         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              //       ),
              //     ),
              //   ],
              // ),

            ],
          ),
        ),
      ),
    );
  }
  void _showError(String? msgEmail, String? msgPassword) {
    setState(() {
    _passwordError = msgPassword;
    _emailError = msgEmail;
    });
  }
  void _showResultPopup(String phoneNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FailedWidget(),
                const SizedBox(height: 10),
                const Text("Oops, Failed!", style: TextStyle(color: Color(0xFFdf605f), fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                const Texts(
                  textAlign: TextAlign.center,
                  text: "This Number is already linked to another account. Please use a different phone number",
                  size: 14, colorHexValue: 0xFF4D4D4D,
                ),
                const SizedBox(height: 25),
                Buttons(
                  height: 50,
                  text: "Close",
                  onTap: () => Navigator.pop(context),
                  gradient: const LinearGradient(colors: [Color(0xFF77153C), Color(0xFFDD276F)]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}











// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(
//               horizontal: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 40),
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Back_Button(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },),
//               ),
//               const SizedBox(height: 37),
//               Images(imageStr: 'assets/images/two_are_one.png',
//                 height: 51,
//                 width: 215,
//               ),
//               const SizedBox(height: 10),
//               const Texts(
//                 text: "Welcome Back",
//                 colorHexValue: 0xFF4D4D4D,
//                 size: 20,
//                 fontWeight: FontWeight.w500,
//               ),
//               const Texts(
//                 textAlign: TextAlign.center,
//                 text: "Reconnect with your matches and explore\nexciting new connections.",
//                 colorHexValue: 0xFF333333,
//                 size: 12,
//                 fontWeight: FontWeight.w300,
//               ),
//               const SizedBox(height: 30),
//               const CustomInputField(
//                 prefixIcon: Icons.email_outlined,
//                 label: "Email",
//                 hintText: "Enter your full name",
//               ),
//               const CustomInputField(
//                 label: "Password",
//                 hintText: "● ● ● ● ● ● ● ●",
//                 prefixIcon: Icons.lock_open,
//                 isPassword: true,
//                 suffixIcon: Icon(Icons.visibility_outlined, color: Color(0xFF787878)),
//               ),
//               Row(
//                 children: [
//                   Checkbox(
//                     side: BorderSide(
//                       width: 0.5,
//                       color: Color(0xFF808080),
//                     ),
//                     onChanged: (value) {
//                     }, value: true,),
//                   Texts(text: "Save Login Info",
//                     size: 12,
//                     fontWeight: FontWeight.w500,
//                     colorHexValue: 0xFF808080,),
//                   const Spacer(),
//                   TxtButton(
//                     fontWeight: FontWeight.w500,
//                     text: "Forget Password?",
//                     sizeTxt: 12,
//                     colorHex: 0xFF808080,
//                     onTap: (){
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) => ForgetPassword(),));
//                     },)
//                 ],
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: Buttons(
//                   text: 'Login',
//                   hexValue: 0xFFFFFFFF,
//                   onTap: () {
//                     Navigator.pushReplacement(
//                         context, MaterialPageRoute(builder: (context) => QuestionnaireScreen(),));
//                   },
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF77153C),
//                       Color(0xFFDD276F)],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Row(
//                 children: [
//                   const Expanded(
//                     child: Images(
//                       imageStr: "assets/images/left_polygon.svg",
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Texts(
//                         text: "Or Login with",
//                         colorHexValue: 0xFF000000,
//                         size: 12,
//                         fontWeight: FontWeight.w300),
//                   ),
//                   const Expanded(
//                     child: Images(
//                       imageStr: 'assets/images/right_polygon.svg',
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               // Social Icons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Images(imageStr: "assets/images/apple_img.png",
//                       height: 42, width: 42),
//                   const SizedBox(width: 17),
//                   Images(
//                       imageStr: "assets/images/google_img.png",
//                       height: 42, width: 42
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 80),
//               // Footer
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
//                   GestureDetector(
//                     onTap: () {},
//                     child: const Text(
//                       "Sign Up",
//                       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//
//   }
// }
