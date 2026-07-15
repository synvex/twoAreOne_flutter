import 'package:flutter/material.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/features/Bottom_Nav_Bar_Screens/profile_screen.dart';
import 'chat_screen.dart';
import 'favourite_screen.dart';
import 'home_screen.dart';

const double _kCurveDepth = 90.0;
const double _kBarHeight  = 73.0;

class MainBarScreen extends StatefulWidget {
  final int initialIndex; // agar kisi screen se direct tab open karna ho
  const MainBarScreen({super.key, this.initialIndex = 0});

  @override
  State<MainBarScreen> createState() => _MainBarScreenState();
}

class _MainBarScreenState extends State<MainBarScreen> {
  late int _selectedIndex;
  final List<Widget> _screens = const [
    HomeScreen(),
    FavouriteScreen(),
    ChatScreen(),
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
      backgroundColor: Colors.white,
      // React Native ki tarah Stack + Positioned use karo
      body: Stack(
        children: [
          // ── Screens full screen leti hain ─────────────────────────────
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          // ── Navbar bilkul bottom pe overlay hoti hai ──────────────────
          // Exactly like RN: position: 'absolute', bottom: 0
          Positioned(
            bottom: -25,
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
  static const List<String> _tabNames = [
    "Home",
    "Favorite",
    "Chat",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double totalHeight = _kCurveDepth + _kBarHeight;

    return SizedBox(
      width: screenWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ShadowPainter(
                curveDepth: _kCurveDepth,
                barHeight: _kBarHeight,
              ),
            ),
          ),

          // ── Layer 2: White curved shape ──────────────────────────────────
          ClipPath(
            clipper: _CurveClipper(
              curveDepth: _kCurveDepth,
              barHeight: _kBarHeight,
            ),
            child: Container(
              width: screenWidth,
              height: totalHeight,
              color: Colors.white,
            ),
          ),
          // ── Layer 3: Tab items
          Positioned(
            top: _kCurveDepth-10,
            left: 0,
            // bottom: 10,
            right: 0,
            height: _kBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_imgStr.length, (index) {
                final bool isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _NavItem(
                    imgStr: isSelected ? _selectedImgStr[index] : _imgStr[index],
                    label: _tabNames[index],
                    isSelected: isSelected,
                    onTap: () => onTabChanged(index),
                  ),
                );
              }),
            ),
          ),
        ],
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
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Selected Glow Effect (Halo behind icon) ──
                  // Ye sirf tab nazar ayega jab tab select hoga
                  if (isSelected)
                    SizedBox(
                      width: 38,
                      height: 38,
                      // decoration: BoxDecoration(
                      //   shape: BoxShape.circle,
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: const Color(0xFFDD276F).withOpacity(0.25),
                      //       blurRadius: 12,
                      //       spreadRadius: 4,
                      //     ),
                      //   ],
                      // ),
                    ),
                  // ── The SVG Icon ──
                  // Yahan humne koi color assign nahi kiya taake images ka
                  // apna gradient/color mutasir na ho.
                  Images(
                    imageStr: imgStr,
                    height: 26,
                    width: 26,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFDD276F)
                    : const Color(0xFF8E8E8E),
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
      ..quadraticBezierTo(
        size.width / 2, 0,
        size.width, curveDepth,
      )
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
        ..color = Colors.black.withOpacity(0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter old) =>
      old.curveDepth != curveDepth || old.barHeight != barHeight;
}

