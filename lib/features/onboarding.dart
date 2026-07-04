import 'package:flutter/material.dart';
import 'package:two_are_one/core/buttons.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/features/auth/login.dart';
import 'package:two_are_one/features/auth/no_verification.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // 2. Define a base size for the graphics.
    // In portrait, it's based on width. In landscape, it's based on height.
    final double scaleBase = isLandscape ? screenHeight * .94 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.only(bottom: 18.0,top: isLandscape ? 10:0),
            child: Column(
              children: [
            SizedBox(
            height: isLandscape ? screenHeight * 0.88 : screenHeight * 0.42,
              width: screenWidth,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // BLUE CIRCLE (Responsive)
                  Container(
                    width: scaleBase * 0.82,
                    height: scaleBase * 0.8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7EA3CC),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Avatar(
                    bottom: isLandscape ? screenHeight* 0.135 :screenHeight * 0.06,
                    right: isLandscape ? screenWidth * 0.295: screenWidth * 0.072,
                    size:  98,
                    imageStr: 'assets/images/bottom_right.png',
                  ),
                  // MAIN IMAGE (Responsive)
              Positioned(
                    child: Images(
                      imageStr: "assets/images/onboarding_img.png",
                      width: scaleBase * 0.59, // Scaled instead of fixed 236
                      height: scaleBase * 0.53, // Scaled instead of fixed 236
                    ),
                  ),
                  // AVATAR - TOP LEFT
                  Avatar(
                    top: isLandscape ? screenHeight* 0.14 : screenHeight * 0.074,
                    left: isLandscape ?  screenWidth * 0.315:
                    screenWidth * 0.095,
                    size: 67.5, // Scaled instead of fixed 68
                    imageStr: 'assets/images/top_left.png',
                  ),
                  // AVATAR - TOP RIGHT
                  Avatar(
                    top: isLandscape ? screenHeight* .08 : screenHeight * 0.025,
                    right: isLandscape ? screenWidth * 0.31 :
                    screenWidth * 0.09,
                    size: scaleBase * 0.2, // Scaled instead of fixed 81
                    imageStr: 'assets/images/right_top.png',
                  ),
                  // AVATAR - BOTTOM LEFT
                  Avatar(
                    bottom: isLandscape ? screenHeight* .17 : screenHeight * 0.072,
                    left: isLandscape ? screenWidth * 0.326 : screenWidth * 0.13,
                    size: 62,
                    imageStr: 'assets/images/left_bottom.png',
                  ),
                ],
              ),
            ),
            // 2. Page Indicators
            const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     _buildIndicator(screenWidth, false),
            //     SizedBox(width: screenWidth * 0.02),
            //     _buildIndicator(screenWidth, true),
            //     SizedBox(width: screenWidth * 0.02),
            //     _buildIndicator(screenWidth, false),
            //   ],
            // ),
                Image.asset("assets/images/two_are_one.png",
                  height: 52,
                  width: 214,
                ),
                SizedBox(height: screenHeight * 0.038),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureItem(context,
                        "assets/images/one.png",
                      "Smart Matching\nEngine",
                      45
                    ),
                    _buildFeatureItem(context,
                        "assets/images/two.png",
                        "Interactive\nReal Profiles",
                      45
                    ),
                    _buildFeatureItem(
                        context,
                      "assets/images/three.png",
                      "Secure & Private\nConnections",
                      45,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.047),
                Buttons(
                  text: "Create Account",
                  gradient: const LinearGradient(
                    colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoVerification(),));
                    // Navigator.pushNamed(context, '/signup');
                  }, ),
                const SizedBox(height: 8,),
                Buttons(
                  hex: 0xFF000000,
                  text: "Sign In",
                  hexValue: 0xFF000000,
                  color: Color(0xFF000000),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),));
                  }, ),
                SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Texts(text: "By tapping ",
                      fontWeight: FontWeight.w400,size: 13,),
                    InkWell(
                      child:Texts(text: "Create account ",
                          colorHexValue: 0xFF77153C,
                          fontWeight: FontWeight.w600,size: 13),
                    ),
                    Texts(text: "or ",
                      fontWeight: FontWeight.w400,size: 13,),
                    InkWell(
                      child:Texts(text: "Sign in",
                          colorHexValue: 0xFF77153C,
                          fontWeight: FontWeight.w600,size: 13),
                    ),
                    Texts(text: " you agree",
                      fontWeight: FontWeight.w400,size: 13,),
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Texts(text: "to our ",
                      fontWeight: FontWeight.w400,size: 13,),
                    Container(
                          margin: EdgeInsets.only(bottom: 0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 1.5),
                            ),
                          ),
                          child: Texts(
                            text: "Terms.",
                            colorHexValue: 0xFF000000,
                            size: 13,),
                        ),
                    Texts(text: "Learn how we process your data  ",
                      fontWeight: FontWeight.w400,size: 13,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Texts(text: "our"),
                    InkWell(
                      child:Container(
                        // margin: EdgeInsets.only(bottom: 0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1.5),
                          ),
                        ),
                        child: Texts(text: " Privacy Policy",
                            colorHexValue: 0xFF77153C,
                            fontWeight: FontWeight.w600,size: 13),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build Feature Icons
  Widget _buildFeatureItem(BuildContext context,
      String imgStr,
   String label,
      double avatarSize,
      ) {
    return Column(
      children: [
        SizedBox(
            height: avatarSize,
            width: avatarSize,
            child: Stack(
                children: [
                  Avatar(size: avatarSize, imageStr: imgStr)
                ],
            )
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w400
          ),
        )
      ],
    );
  }

  // Helper for Carousel Indicators
  Widget _buildIndicator(double screenWidth, bool isActive) {
    return Container(
      width: 34,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF7D1038) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
