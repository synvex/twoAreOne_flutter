import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/my_icons.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/features/auth/email_otp_verification.dart';
import 'package:two_are_one/features/auth/login.dart';
import 'package:two_are_one/models/location_data.dart';
import '../../core/buttons.dart';
import '../../core/image.dart';
import '../../core/textfield.dart';
import '../../services/auth_service.dart';
import '../main_screens/location_selector.dart';

class SignUpPage extends StatefulWidget {
 final String verifiedPhoneNo;
 const SignUpPage({super.key, required this.verifiedPhoneNo});

 @override
 State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
 String _selectedGender = "male"; // Hardcoded to match original codebase architecture
 String _selectedLocation = "";   // Holds city or formal address string
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
  // 1. Reset all errors to null before validating again
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

  // 2. Validation Logic (storing messages instead of returning immediately)

  // Email Validation
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (email.isEmpty) {
   _emailError = "Email is required";
  } else if (!emailRegex.hasMatch(email)) {
   _emailError = "Email is invalid";
  }

  // Password Validation
  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d])[A-Za-z\d\S]{8,}$');
  if (password.isEmpty) {
   _passwordError = "Password is required";
  } else if (!passwordRegex.hasMatch(password)) {
   _passwordError = "Must be 8+ characters with Upper, Lower, Number & Special char";
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
   _nameError = "Name can only contain letters";
  }

  // Location Validation
  if (_selectedLocation.isEmpty) {
   _locationError = "Location is required";
  }

  // 3. CHECK: If any error variable is NOT null, stop here and show them on UI
  if (_emailError != null || _passwordError != null || _ageError != null || _nameError != null || _locationError != null) {
   setState(() {}); // Refresh UI to show the red text under fields
   return; // Exit function
  }

  // 4. If code reaches here, everything is valid. Proceed to API call.
  setState(() => _isLoading = true);

  try {
   final deviceInfo = await _authService.getDeviceInfo();
   final deviceId = deviceInfo['device_id'] ?? "";
   final deviceToken = deviceInfo['device_token'] ?? "";

   final result = await _authService.signUp(
    fullName: name,
    email: email,
    password: password,
    age: ageNum!, // Use ! because we validated it's not null above
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
     MaterialPageRoute(builder: (context) => EmailOtpVerification(email: email)),
    );
   } else {
    _showSnackBar(result['error'] ?? "Signup failed");
   }
  } catch (e) {
   _showSnackBar("Error: $e");
  } finally {
   if (mounted) setState(() => _isLoading = false);
  }
 }

 // void _handleSignUp() async {
 //  final name = _nameController.text.trim();
 //  final email = _emailController.text.trim();
 //  final password = _passwordController.text.trim();
 //  final ageStr = _ageController.text.trim();
 //
 //  // 1. Validation Logic matching React Native validation checks
 //  if (email.isEmpty) {
 //   _showErrorBanner("Email is required");
 //   return;
 //  }
 //  // Simple regex validation matching original project requirements
 //  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
 //  if (!emailRegex.hasMatch(email)) {
 //   _showErrorBanner("Email is invalid");
 //   return;
 //  }
 //
 //  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d])[A-Za-z\d\S]{8,}$');
 //  if (password.isEmpty) {
 //   _showErrorBanner("Password is required");
 //   return;
 //  } else if (!passwordRegex.hasMatch(password)) {
 //   _showErrorBanner("Password must be at least 8 characters long and include uppercase, lowercase, number, and special character");
 //   return;
 //  }
 //
 //  if (ageStr.isEmpty) {
 //   _showErrorBanner("Age is required");
 //   return;
 //  }
 //  final ageNum = int.tryParse(ageStr);
 //  if (ageNum == null || ageNum < 1 || ageNum > 99) {
 //   _showErrorBanner("Age must be a number between 1 and 99");
 //   return;
 //  }
 //
 //  if (name.isEmpty) {
 //   _showErrorBanner("Name is required");
 //   return;
 //  } else if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(name)) {
 //   _showErrorBanner("Name can only contain letters and spaces");
 //   return;
 //  }
 //
 //  if (_selectedLocation.isEmpty) {
 //   _showErrorBanner("Location is required");
 //   return;
 //  }
 //
 //  setState(() => _isLoading = true);
 //
 //  try {
 //   // 2. Fetch unique hardware identifiers
 //   final deviceInfo = await _authService.getDeviceInfo();
 //   final deviceId = deviceInfo?['device_id'] ?? "";
 //   final deviceToken = deviceInfo?['device_token'] ?? "";
 //
 //   // 3. Make the API Authentication Request
 //   final result = await _authService.signUp(
 //    fullName: name,
 //    email: email,
 //    password: password,
 //    age: ageNum,
 //    gender: _selectedGender, // Sent as "male" matching source setup
 //    location: _city,         // Maps to location.city configuration
 //    phoneNo: widget.verifiedPhoneNo,
 //    country: _country,
 //    state: _state,
 //    city: _city,
 //    latitude: _latitude,
 //    longitude: _longitude,
 //    deviceId: deviceId,
 //    deviceToken: deviceToken,
 //   );
 //
 //   if (result['success']) {
 //    if (!mounted) return;
 //    Navigator.pushReplacement(
 //     context,
 //     MaterialPageRoute(
 //      builder: (context) => EmailOtpVerification(email: email),
 //     ),
 //    );
 //   } else {
 //    _showSnackBar(result['error'] ?? "Signup failed");
 //   }
 //  } catch (e) {
 //   _showSnackBar("Error: $e");
 //  } finally {
 //   if (mounted) setState(() => _isLoading = false);
 //  }
 // }

 void _showErrorBanner(String message) {
  setState(() => _errorMessage = message);
  ScaffoldMessenger.of(context).clearMaterialBanners();
  ScaffoldMessenger.of(context).showMaterialBanner(
   MaterialBanner(
    content: Text(message),
    backgroundColor: Colors.red.shade50,
    actions: [
     TextButton(
      child: const Text("Close", style: TextStyle(color: Colors.red)),
      onPressed: () => ScaffoldMessenger.of(context).clearMaterialBanners(),
     )
    ],
   ),
  );
 }

 void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
   SnackBar(content: Text(message)),
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
      const SizedBox(height: 100),
      Images(
       imageStr: 'assets/images/two_are_one.png',
       height: 52,
       width: 225,
      ),
      const SizedBox(height: 25),
      const Texts(
       text: "Sign Up Today",
       colorHexValue: 0xFF000000,
       size: 21,
       fontWeight: FontWeight.w500,
      ),
      const SizedBox(height: 15),
      const Texts(
       textAlign: TextAlign.center,
       text: "Discover real people looking for real\nrelationships",
       colorHexValue: 0xFF000000,
       size: 13,
       fontWeight: FontWeight.w300,
      ),
      const SizedBox(height: 15),
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
       wHeight: 45,
       hexValue: 0xFFF0EFEF,
       margin: const EdgeInsets.only(bottom: 5),
       radius: BorderRadius.circular(30),
       child: Row(
        children: [
         const SizedBox(width: 10),
         MyIcons(iconData: CupertinoIcons.phone, color: Colors.grey),
         const SizedBox(width: 10),
         Texts(
          text: widget.verifiedPhoneNo,
          size: 16,
          fontWeight: FontWeight.w400,
          colorHexValue: 0xFF787878,
         )
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
       label: "Full Name",
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
       label: "Age",
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
       label: " Email",
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
       label: "Password",
       hintText: "********",
       prefixIcon: Icons.lock_open,
       isPassword: _obscurePassword,
       suffixIcon: MyIcons(
        color: Colors.grey,
        iconData: _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
       ),
       onTap: () => setState(() {
        _obscurePassword = !_obscurePassword;
       }),
      ),
      _errorWidget(_passwordError),
      const SizedBox(height: 5),
      LocationSelectorField(
       labels: "Location",
       // Assuming LocationSelectorField passes a detailed map setup following your Places selection updates
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
        print("Selected Coordinates: $_latitude, $_longitude");
       },
      ),
      _errorWidget(_locationError),
      const SizedBox(height: 40),
      SizedBox(
       // width: double.infinity,
       height: 55,
       child: Buttons(
        width: MediaQuery.of(context).size.width/1.23,
        text: 'Signup',
        onTap: _handleSignUp,
        gradient: const LinearGradient(
         colors: [Color(0xFF77153C), Color(0xFFDD276F)],
        ),
       ),
      ),
      const SizedBox(height: 35),
      Row(
       children: [
        const Expanded(child: Images(imageStr: "assets/images/left_polygon.svg")),
        Padding(
         padding: const EdgeInsets.symmetric(horizontal: 10),
         child: Texts(
          text: "Or Sign up with",
          colorHexValue: 0xFF000000,
          size: 12,
          fontWeight: FontWeight.w300,
         ),
        ),
        const Expanded(child: Images(imageStr: "assets/images/right_polygon.svg")),
       ],
      ),
      const SizedBox(height: 20),
      Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
        Images(imageStr: "assets/images/apple_img.png", height: 42, width: 42),
        const SizedBox(width: 17),
        Images(imageStr: "assets/images/google_img.png", height: 42, width: 42),
       ],
      ),
      const SizedBox(height: 40),
     ],
    ),
   ),
  );
 }
 Widget _errorWidget(String? errorMsg) {
  return errorMsg != null
      ? Padding(
   padding: const EdgeInsets.only( top: 6,),
   child: Align(
    alignment: Alignment.centerLeft,
    child: Texts(
     text: errorMsg,
     colorHexValue: 0xFFD32F2F,size: 15),
   ),
  )
      : const SizedBox(height: 2); // Standard spacing if no error
 }
}








//
// class SignUpPage extends StatefulWidget {
//  final String verifiedPhoneNo;
//  const SignUpPage({super.key, required this.verifiedPhoneNo});
//
//  @override
//  State<SignUpPage> createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//  final TextEditingController _nameController = TextEditingController();
//  final TextEditingController _ageController = TextEditingController();
//  final TextEditingController _emailController = TextEditingController();
//  final TextEditingController _passwordController = TextEditingController();
//  final AuthService _authService = AuthService(); // Initialize service
//  bool _isLoading = false; // To show loading spinner
//  bool _obscurePassword = true;
//  String _selectedGender = "male";
//  String _selectedLocation = "";
//  String _latitude = "";
//  String _longitude = "";
//
//  @override
//  void dispose() {
//   _nameController.dispose();
//   _ageController.dispose();
//   _emailController.dispose();
//   _passwordController.dispose();
//   super.dispose();
//  }
//  void _handleSignUp() async {
//   // Basic validation
//   if (_nameController.text.isEmpty ||
//       _emailController.text.isEmpty ||
//       _passwordController.text.isEmpty ||
//       _ageController.text.isEmpty ||
//       _selectedLocation.isEmpty
//   ) {
//    ScaffoldMessenger.of(context).showMaterialBanner(
//     MaterialBanner(content: const Text("All fields are required"),
//      actions: [TxtButton(text: "Close", onTap: ()=> Navigator.pop(context))],),
//    );
//    return;
//   }
//   setState(() => _isLoading = true);
//   try {
//    final email = _emailController.text.trim();
//    final deviceInfo = await _authService.getDeviceInfo();
//
//    final result = await _authService.signUp(
//     fullName: _nameController.text.trim(),
//     email: email,
//     password: _passwordController.text.trim(),
//     age: int.tryParse(_ageController.text) ?? 18,
//     phoneNo: widget.verifiedPhoneNo, //from the previous screen
//     // Passing empty/default values for the other required parameters in your API
//     // gender: "",
//     // location: "",
//     // latitude: "",
//     // longitude: "",
//     // deviceId: "",
//     // deviceToken: "",
//     // phoneNo: "",
//     // country: "",
//     // state: "",
//     // city: "",
//     location: _selectedLocation,
//     latitude: _latitude,
//     longitude: _longitude,
//     // deviceId: deviceInfo['device_id']!,
//     // deviceToken: deviceInfo['device_token']!, // Just a unique identifier
//     country: "",
//     state: "",
//     city: "",
//    );
//
//    if (result['success']) {
//     if (!mounted) return;
//     Navigator.pushReplacement(
//      context,
//      MaterialPageRoute(
//          builder: (context) => EmailOtpVerification(email: email)),
//     );
//    }
//    else {
//     ScaffoldMessenger.of(context).showSnackBar(
//      SnackBar(
//          content: Text(result['error'] ?? "Signup failed")),
//     );
//    }
//   } catch (e) {
//    ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text("Error: $e")),
//    );
//   } finally {
//    if (mounted) setState(() => _isLoading = false);
//   }
//  }
//  @override
//  Widget build(BuildContext context) {
//   return Scaffold(
//    backgroundColor: Colors.white,
//    body: SafeArea(
//     child: SingleChildScrollView(
//      padding: const EdgeInsets.symmetric(horizontal: 20),
//      child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//        const SizedBox(height: 100),
//        Images(imageStr: 'assets/images/two_are_one.png',
//         height: 45,
//         width: 218,
//        ),
//        const SizedBox(height: 10),
//        const Texts(
//         text: "Sign Up Today",
//         colorHexValue: 0xFF4D4D4D,
//         size: 21, fontWeight: FontWeight.w500,
//        ),
//        const SizedBox(height: 30),
//        Texts(
//         textAlign: TextAlign.center,
//         text: "Discover real people looking for real\nrelationships",
//         colorHexValue: 0xFF575454,
//         size: 13, fontWeight: FontWeight.w300,
//        ),
//        const SizedBox(height: 15,),
//        const Align(
//         alignment: Alignment.centerLeft,
//         child: Texts(text: "Phone", fontWeight: FontWeight.w400, size: 16,
//          edgeInsets: EdgeInsets.only(bottom: 5),),
//        ),
//        Containers(
//         wHeight: 45,
//         hexValue: 0xFFF0EFEF,
//         margin: EdgeInsets.only(
//             bottom: 5
//         ),
//         radius: BorderRadius.circular(30),
//         child: Row(
//          children: [
//           const SizedBox(width: 10),
//           MyIcons(iconData: CupertinoIcons.phone,color: Colors.grey,),
//           Texts(text: widget.verifiedPhoneNo, size: 16, fontWeight: FontWeight.w400,colorHexValue: 0xFF787878,)
//          ],
//         ),
//        ),
//        const Align(
//         alignment: Alignment.centerLeft,
//         child: Texts(text: "Full Name", fontWeight: FontWeight.w400, size: 16,edgeInsets: EdgeInsets.only(bottom: 7,top: 4),),
//        ),
//        CustomInputField(
//         textInputType: TextInputType.name,
//         controller: _nameController,
//         label: "Full Name",
//         hintText: "Enter your full name",
//         // prefixIcon: CupertinoIcons.a,
//         prefixIcon: Icons.quick_contacts_mail_outlined,
//        ),
//        const Align(
//         alignment: Alignment.centerLeft,
//         child: Texts(text: "Age", fontWeight: FontWeight.w400, size: 16,edgeInsets: EdgeInsets.only(bottom: 7,top: 4),),
//        ),
//        CustomInputField(
//         textInputType: TextInputType.number,
//         controller: _ageController,
//         label: "Age",
//         hintText: "Age",
//         prefixIcon: CupertinoIcons.person_crop_circle,
//
//        ),
//        const Align(
//         alignment: Alignment.centerLeft,
//         child: Texts(text: "Email", fontWeight: FontWeight.w400, size: 16,edgeInsets: EdgeInsets.only(bottom: 7,top: 4),),
//        ),
//        CustomInputField(
//         textInputType: TextInputType.emailAddress,
//         controller: _emailController,
//         prefixIcon: Icons.email_outlined,
//         label: " Email",
//         hintText: "Enter your email",
//        ),
//        const Align(
//         alignment: Alignment.centerLeft,
//         child: Texts(text: "Password", fontWeight: FontWeight.w400, size: 16,edgeInsets: EdgeInsets.only(bottom: 7,top: 4),),
//        ),
//        CustomInputField(
//         controller: _passwordController,
//         label: "Password",
//         hintText: "● ● ● ● ● ● ● ●",
//         prefixIcon: Icons.lock_open,
//         isPassword: _obscurePassword,
//         suffixIcon: MyIcons(iconData: Icons.visibility_off_rounded,),
//         onTap: () => setState(() {
//          _obscurePassword = !_obscurePassword;;
//         }),
//        ),
//        SizedBox(height: 5),
//        LocationSelectorField(
//         labels: "Location",
//         onLocationSelected: (location) {
//          setState(() {
//           _selectedLocation = location;
//          });
//          print("Selected: $location");
//          // Save this to your state or variable for the API call
//         },
//        ),
//
//        const SizedBox(height: 85),
//        const SizedBox(height: 30),
//        SizedBox(
//         width: double.infinity,
//         height: 55,
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator(color: Color(0xFF77153C)))
//             : Buttons(
//
//          text: 'Signup',
//          onTap: _handleSignUp,
//          gradient: const LinearGradient(
//           colors: [Color(0xFF77153C), Color(0xFFDD276F)],
//          ),
//         ),
//        ),
//        const SizedBox(height: 30),
//        Row(
//         children: [
//          const Expanded(child: Images(
//              imageStr: "assets/images/left_polygon.svg")),
//          Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Texts(
//               text: "Or Sign up with",
//               colorHexValue: 0xFF000000, size: 12,
//               fontWeight: FontWeight.w300),
//          ),
//          const Expanded(
//              child: Images(
//               imageStr: "assets/images/right_polygon.svg",)),
//         ],
//        ),
//        const SizedBox(height: 20),
//        // Social Icons
//        Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//          Images(imageStr: "assets/images/apple_img.png",
//              height: 42, width: 42),
//          const SizedBox(width: 17),
//          Images(
//              imageStr: "assets/images/google_img.png",
//              height: 42, width: 42
//          ),
//         ],
//        ),
//        const SizedBox(height: 40),
//
//        Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//          const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
//          GestureDetector(
//           onTap: () {
//            Navigator.pushReplacement(
//                context,
//                MaterialPageRoute(
//                 builder: (context) => LoginPage(),));
//           },
//           child: const Text(
//            "Login",
//            style: TextStyle(
//                fontWeight: FontWeight.bold,
//                color: Colors.black),
//           ),
//          ),
//         ],
//        ),
//        const SizedBox(height: 20),
//       ],
//      ),
//     ),
//    ),
//   );
//  }
// }
//
