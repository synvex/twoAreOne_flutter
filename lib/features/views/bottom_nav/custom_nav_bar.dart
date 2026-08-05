import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/data/viewmodels/chat_viewmodel.dart';
import 'package:two_are_one/features/views/bottom_nav/profile_screen.dart';
import '../chat/message_screen.dart';
import 'favourite_screen.dart';
import 'home_screen.dart';

const double _kCurveDepth = 100.0;
const double _kBarHeight = 170.0;

class CustomNavBar extends StatefulWidget {
  final int initialIndex;
  const CustomNavBar({super.key, this.initialIndex = 0});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late int _selectedIndex;
  final List<Widget> _screens = const [
    HomeScreen(),
    FavouriteScreen(),
    MessageScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      // React Native ki tarah Stack + Positioned use karo
      body: Stack(
        children: [
          // ── Screens full screen leti hain ─────────────────────────────
          IndexedStack(index: _selectedIndex, children: _screens),
          // ── Navbar bilkul bottom pe overlay hoti hai ──────────────────
          // Exactly like RN: position: 'absolute', bottom: 0
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTabChanged: _onTabChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  static const List<String> _imgStr = [
    "assets/svg_images/home.svg",
    "assets/svg_images/Tabbar/InActiveExplore.svg",
    "assets/svg_images/chat.svg",
    "assets/svg_images/Tabbar/InactiveProfile.svg",
  ];
  static const List<String> _selectedImgStr = [
    "assets/svg_images/Tabbar/Home.svg",
    "assets/svg_images/Tabbar/favouriteTapped.svg",
    "assets/svg_images/Tabbar/chatTapped.svg",
    "assets/svg_images/Tabbar/Profile.svg",
  ];
  static const List<String> _tabNames = ["Home", "Favorite", "Chat", "Profile"];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final chatViewModel = context.watch<ChatViewModel>();
    return SizedBox(
      width: screenWidth,
      height: _kBarHeight + 18,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(height: 30),
            Positioned.fill(
              child: CustomPaint(
                painter: _ShadowPainter(
                  curveDepth: _kCurveDepth,
                  barHeight: _kBarHeight,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              bottom: -20,
              child: Transform.translate(
                offset: const Offset(0, 6),
                child: ClipPath(
                  clipper: _CurveClipper(
                    curveDepth: _kCurveDepth,
                    barHeight: _kBarHeight,
                  ),
                  child: Container(
                    width: screenWidth,
                    height: _kBarHeight,
                    color: const Color(0xFF77153C).withOpacity(0.12),
                  ),
                ),
              ),
            ),

            // main white bar
            ClipPath(
              clipper: _CurveClipper(
                curveDepth: _kCurveDepth,
                barHeight: _kBarHeight,
              ),
              child: Container(
                width: screenWidth,
                height: _kBarHeight,
                color: Colors.white,
              ),
            ),
            // tab items
            Positioned(
              top: 54,
              left: 0,
              right: 0,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(_imgStr.length, (index) {
                  final bool isSelected = selectedIndex == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Stack(
                        children: [
                          _NavItem(
                            imgStr: isSelected
                                ? _selectedImgStr[index]
                                : _imgStr[index],
                            label: _tabNames[index],
                            isSelected: isSelected,
                            onTap: () => onTabChanged(index),
                          ),

                          index == 2
                              ? Positioned(
                                  right: 14.w,
                                  top: 18.h,
                                  child: Visibility(
                                    visible:
                                        chatViewModel.unreadConversationCount !=
                                        0,
                                    child: CircleAvatar(
                                      radius: 10.r,
                                      backgroundColor: isSelected
                                          ? Colors.transparent
                                          : AppColors.red,
                                      child: Center(
                                        child: Text(
                                          isSelected
                                              ? ''
                                              : chatViewModel
                                                    .unreadConversationCount
                                                    .toString(),
                                          style: GoogleFonts.poppins(
                                            color: AppColors.white,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String imgStr;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.imgStr,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Positioned(
                      bottom: -4,
                      // left: .5,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                        child: Images(
                          color: Color(0xFFDD276F).withValues(alpha: .7),
                          imageStr: imgStr,
                          height: isSelected ? 28 : 24,
                          width: isSelected ? 29 : 24,
                        ),
                      ),
                    ),
                  Images(
                    imageStr: imgStr,
                    height: isSelected ? 28 : 24,
                    width: isSelected ? 28 : 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFDD276F)
                    : const Color(0xFF000000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  final double curveDepth;
  final double barHeight;
  const _CurveClipper({required this.curveDepth, required this.barHeight});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, curveDepth)
      ..quadraticBezierTo(size.width / 2, 0, size.width, curveDepth)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CurveClipper old) =>
      old.curveDepth != curveDepth || old.barHeight != barHeight;
}

class _ShadowPainter extends CustomPainter {
  final double curveDepth;
  final double barHeight;
  const _ShadowPainter({required this.curveDepth, required this.barHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, curveDepth)
      ..quadraticBezierTo(size.width / 2, 0, size.width, curveDepth)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path.shift(const Offset(0, -1)),
      Paint()
        ..color = const Color(0xFF77153C).withOpacity(0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter old) =>
      old.curveDepth != curveDepth || old.barHeight != barHeight;
}
