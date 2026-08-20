import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/my_icons.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/models/location_data.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/data/services/auth_service.dart';
import 'package:two_are_one/features//views/main/location_selector.dart';
import 'package:two_are_one/core/widgets/failed.dart';
import 'email_otp_verification.dart';

class SignUpScreen extends StatefulWidget {
  final String verifiedPhoneNo;
  const SignUpScreen({super.key, required this.verifiedPhoneNo});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Initialize service

  String? _errorMessage;
  String? _nameError;
  String? _ageError;
  String? _emailError;
  String? _passwordError;
  String? _locationError;
  bool _isLoading = false; // To show loading spinner
  bool _obscurePassword = true;

  // Form State Values
  final String _selectedGender =
      "male"; // Hardcoded to match original codebase architecture
  String _selectedLocation = ""; // Holds city or formal address string
  String _country = "";
  String _state = "";
  String _city = "";
  String _latitude = "";
  String _longitude = "";

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    setState(() {
      _nameError = null;
      _ageError = null;
      _emailError = null;
      _passwordError = null;
      _locationError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final ageStr = _ageController.text.trim();

    // Email Validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      _emailError = "Email is required";
    } else if (!emailRegex.hasMatch(email)) {
      _emailError = "Email is invalid";
    }

    // Password Validation
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d])[A-Za-z\d\S]{8,}$',
    );
    if (password.isEmpty) {
      _passwordError = "Password is required";
    } else if (!passwordRegex.hasMatch(password)) {
      _passwordError =
          "Must be 8+ characters with Upper, Lower, Number & Special char";
    }

    // Age Validation
    final ageNum = int.tryParse(ageStr);
    if (ageStr.isEmpty) {
      _ageError = "Age is required";
    } else if (ageNum == null || ageNum < 1 || ageNum > 99) {
      _ageError = "Age must be between 1 and 99";
    }

    // Name Validation
    if (name.isEmpty) {
      _nameError = "Name is required";
    } else if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(name)) {
      _nameError = "Name can only contain letters and spaces";
    }
    if (_state.isEmpty) {
      _locationError = _selectedLocation.isEmpty
          ? "Location is required"
          : "Please select a location with a valid state";
    }

    if (_emailError != null ||
        _passwordError != null ||
        _ageError != null ||
        _nameError != null ||
        _locationError != null) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      final deviceInfo = await _authService.getDeviceInfo();
      final deviceId = deviceInfo['device_id'] ?? "";
      final deviceToken = deviceInfo['device_token'] ?? "";

      final result = await _authService.signUp(
        fullName: name,
        email: email,
        password: password,
        age: ageNum!,
        gender: _selectedGender,
        location: _city,
        phoneNo: widget.verifiedPhoneNo,
        country: _country,
        state: _state,
        city: _city,
        latitude: _latitude,
        longitude: _longitude,
        deviceId: deviceId,
        deviceToken: deviceToken,
      );

      if (result['success']) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailOtpVerification(email: email, isFromForget: false),
          ),
        );
      } else {
        _showErrorDialog(result['error'] ?? "Signup failed");
      }
    } catch (e) {
      _showErrorDialog("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              SizedBox(height: 15.h),
              Texts(
                text: title,
                colorHexValue: 0xFFdf605f,
                size: 22,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 15.h),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100.h),
            Images(
              imageStr: 'assets/images/two_are_one.png',
              height: 52.h,
              width: 225.w,
            ),
            SizedBox(height: 25.h),
            const Texts(
              text: "Sign Up Today",
              colorHexValue: 0xFF000000,
              size: 21,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 15.h),
            const Texts(
              textAlign: TextAlign.center,
              text: "Discover real people looking for real\nrelationships",
              colorHexValue: 0xFF000000,
              size: 13,
              fontWeight: FontWeight.w300,
            ),
            SizedBox(height: 15.h),
            const Align(
              alignment: Alignment.centerLeft,
              child: Texts(
                text: "Phone",
                fontWeight: FontWeight.w400,
                size: 16,
                edgeInsets: EdgeInsets.only(bottom: 10),
              ),
            ),
            Containers(
              wHeight: 45.h,
              hexValue: 0xFFF0EFEF,
              margin: const EdgeInsets.only(bottom: 5),
              radius: BorderRadius.circular(30.r),
              child: Row(
                children: [
                  SizedBox(width: 10.w),
                  MyIcons(iconData: CupertinoIcons.phone, color: Colors.grey),
                  SizedBox(width: 10.w),
                  Texts(
                    text: widget.verifiedPhoneNo,
                    size: 16,
                    fontWeight: FontWeight.w400,
                    colorHexValue: 0xFF787878,
                  ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Texts(
                text: "Full Name",
                fontWeight: FontWeight.w400,
                size: 16,
                edgeInsets: EdgeInsets.only(bottom: 10, top: 4),
              ),
            ),
            CustomInputField(
              textInputType: TextInputType.name,
              controller: _nameController,
              formatter: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]')),
              ],
              hintText: "Enter your full name",
              prefixIcon: Icons.quick_contacts_mail_outlined,
            ),
            _errorWidget(_nameError),
            const Align(
              alignment: Alignment.centerLeft,
              child: Texts(
                text: "Age",
                fontWeight: FontWeight.w400,
                size: 16,
                edgeInsets: EdgeInsets.only(bottom: 10, top: 4),
              ),
            ),
            CustomInputField(
              textInputType: TextInputType.number,
              controller: _ageController,
              // label: "Age",
              hintText: "Enter your age",
              prefixIcon: CupertinoIcons.person_crop_circle,
            ),
            _errorWidget(_ageError),
            const Align(
              alignment: Alignment.centerLeft,
              child: Texts(
                text: "Email",
                fontWeight: FontWeight.w400,
                size: 16,
                edgeInsets: EdgeInsets.only(bottom: 10, top: 4),
              ),
            ),
            CustomInputField(
              textInputType: TextInputType.emailAddress,
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              // label: " Email",
              hintText: "Enter your email",
            ),
            _errorWidget(_emailError),
            const Align(
              alignment: Alignment.centerLeft,
              child: Texts(
                text: "Password",
                fontWeight: FontWeight.w400,
                size: 16,
                edgeInsets: EdgeInsets.only(bottom: 10, top: 4),
              ),
            ),
            CustomInputField(
              controller: _passwordController,
              // label: "Password",
              hintText: "********",
              prefixIcon: Icons.lock_open,
              isPassword: _obscurePassword,
              suffixIcon: MyIcons(
                color: Colors.grey,
                iconData: _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onTap: () => setState(() {
                _obscurePassword = !_obscurePassword;
              }),
            ),
            _errorWidget(_passwordError),
            const SizedBox(height: 5),
            const Align(
              alignment: Alignment.centerLeft,
              child: Texts(
                text: "Location",
                fontWeight: FontWeight.w400,
                size: 16,
                edgeInsets: EdgeInsets.only(bottom: 10, top: 4),
              ),
            ),
            LocationSelectorField(
              onLocationSelected: (LocationData locationData) {
                setState(() {
                  _selectedLocation = locationData.address ?? '';
                  _country = locationData.country ?? '';
                  _state = locationData.state ?? '';
                  _city = locationData.city ?? '';
                  _latitude = locationData.latitude.toString();
                  _longitude = locationData.longitude.toString();
                  _locationError = null;
                });
              },
              onLocationCleared: () {
                setState(() {
                  _selectedLocation = "";
                  _country = "";
                  _state = "";
                  _city = "";
                  _latitude = "";
                  _longitude = "";
                });
              },
            ),

            _errorWidget(_locationError),
            const SizedBox(height: 40),
            SizedBox(
              // width: double.infinity,
              height: 55.h,
              child: MainButtonWidget(
                width: MediaQuery.of(context).size.width / 1.23,
                text: 'Signup',
                isLoading: _isLoading,
                onTap: _handleSignUp,
                gradient: const LinearGradient(
                  colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                ),
              ),
            ),
            SizedBox(height: 35.h),
            Row(
              children: [
                const Expanded(
                  child: Images(imageStr: "assets/images/left_polygon.svg"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Texts(
                    text: "Or Sign up with",
                    colorHexValue: 0xFF000000,
                    size: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Expanded(
                  child: Images(imageStr: "assets/images/right_polygon.svg"),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Images(
                  imageStr: "assets/images/apple_img.png",
                  height: 42.h,
                  width: 42.w,
                ),
                SizedBox(width: 17.w),
                Images(
                  imageStr: "assets/images/google_img.png",
                  height: 42.h,
                  width: 42.w,
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(String? errorMsg) {
    return errorMsg != null
        ? Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Texts(text: errorMsg, colorHexValue: 0xFFD32F2F, size: 15),
            ),
          )
        : SizedBox(height: 2.h); // Standard spacing if no error
  }
}
