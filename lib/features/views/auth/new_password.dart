import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/back_button.dart';
import 'package:two_are_one/core/widgets/buttons.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'login.dart';
import 'onboarding.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final bool _isLoading = false;
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
          padding: const EdgeInsets.only(right: 20, left: 20.0, top: 50),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Back_Button(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OnboardingScreen(),
                      ),
                    );
                  },
                ),
                Containers(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  hexValue: 0xFF77153C,
                  opacityValue: 0.15,
                  radius: BorderRadius.circular(40),
                  wHeight: 450,
                  wWidth: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 100),
                      Texts(
                        text: "Create New Password",
                        size: 26,
                        fontWeight: FontWeight.w600,
                        colorHexValue: 0xFF000000,
                      ),
                      Texts(
                        textAlign: TextAlign.center,
                        size: 13,
                        colorHexValue: 0xFF727272,
                        text:
                            " Set a new password and you're all set to explore\nnew connections",
                      ),
                      Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: Texts(
                          edgeInsets: EdgeInsets.only(
                            top: 15,
                            bottom: 8,
                            left: 8,
                          ),
                          text: "New Password",
                        ),
                      ),
                      CustomInputField(
                        fillColor: 0xFFEBDCE2,
                        borderColor: 0xFF847B7F,
                        hintText: "Enter your new password",
                        label: 'New Password',
                      ),
                      Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: Texts(
                          edgeInsets: EdgeInsets.only(
                            top: 10,
                            bottom: 8,
                            left: 8,
                          ),
                          text: "Confirm Password",
                        ),
                      ),
                      CustomInputField(
                        fillColor: 0xFFEBDCE2,
                        borderColor: 0xFF847B7F,
                        hintText: "Confirm your password",
                        label: 'Confirm Password',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * .21),
                  child: Buttons(
                    text: "Submit",
                    isLoading: _isLoading,
                    hexValue: 0xFFFFFFFF,
                    onTap: () {
                      setState(() {});
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
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
