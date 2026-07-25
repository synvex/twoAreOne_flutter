import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_images.dart';
import 'package:two_are_one/core/constants/app_colors.dart';

import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/features/views/notification/notification_screen.dart';

import 'login_screen.dart';
import 'no_verification.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 18.0, top: isLandscape ? 10 : 0),
            child: Column(
              children: [
                SizedBox(
                  height: 0.42.sh,
                  width: 1.sw,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // BLUE CIRCLE
                      Container(
                        width: 0.82.sw,
                        height: 0.80.sw,
                        decoration: const BoxDecoration(
                          color: AppColors.onboardingCircleBlue,
                          shape: BoxShape.circle,
                        ),
                      ),

                      // BOTTOM RIGHT AVATAR
                      Positioned(
                        bottom: 0.06.sh,
                        right: 0.072.sw,
                        child: Container(
                          width: 98.w,
                          height: 98.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                AppImages.onboardingBottomRight,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // MAIN IMAGE
                      Positioned(
                        child: Image.asset(
                          AppImages.onboardingMainImage,
                          width: 0.59.sw,
                          height: 0.53.sw,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // TOP LEFT AVATAR
                      Positioned(
                        top: 0.074.sh,
                        left: 0.095.sw,
                        child: Container(
                          width: 67.5.w,
                          height: 67.5.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(AppImages.onboardingTopLeft),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // TOP RIGHT AVATAR
                      Positioned(
                        top: 0.025.sh,
                        right: 0.09.sw,
                        child: Container(
                          width: 0.20.sw,
                          height: 0.20.sw,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(AppImages.onboardingTopRight),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // BOTTOM LEFT AVATAR
                      Positioned(
                        bottom: 0.072.sh,
                        left: 0.13.sw,
                        child: Container(
                          width: 62.w,
                          height: 62.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(AppImages.onboardingBottomLeft),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 2. Page Indicators
                const SizedBox(height: 20),
                Image.asset(AppImages.appLogo, height: 52, width: 214),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          AppImages.smartMatching,
                          height: 50.h,
                          width: 50.w,
                        ),
                        Text(
                          "Smart Matching\nEngine",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          AppImages.interactive,
                          height: 35.h,
                          width: 35.w,
                        ),
                        Text(
                          "Interactive\nReal Profiles",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          AppImages.secureAndPrivate,
                          height: 50.h,
                          width: 50.w,
                        ),
                        Text(
                          "Secure & Private\nConnections",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 33.h),
                MainButtonWidget(
                  text: "Create Account",
                  gradient: LinearGradient(
                    colors: [AppColors.mehroon, AppColors.gradientFirst],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NoVerification()),
                    );
                    // Navigator.pushNamed(context, '/signup');
                  },
                ),
                const SizedBox(height: 8),
                MainButtonWidget(
                  hex: AppColors.black.value,
                  text: "Sign In",
                  hexValue: AppColors.black.value,
                  color: AppColors.black,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "By tapping ",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      child: Text(
                        "Create account ",
                        style: GoogleFonts.poppins(
                          color: AppColors.mehroon,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      "or ",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      child: Text(
                        "Sign in",
                        style: GoogleFonts.poppins(
                          color: AppColors.mehroon,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      " you agree",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "to our ",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        "Terms.",
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      "Learn how we process your data  ",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "our",
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          " Privacy Policy",
                          style: GoogleFonts.poppins(
                            color: AppColors.mehroon,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
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
