//
// import 'package:flutter/material.dart';
// import 'package:two_are_one/core/image.dart';
// import 'package:two_are_one/core/texts.dart';
//
// // Matches RN: const { width } = Dimensions.get('window')
// // Matches RN: const height = 170
// // Matches RN: const curveDepth = 100
// const double _kBarHeight = 170.0;
// const double _kCurveDepth = 100.0;
//
// class CustomBottomNavBar extends StatefulWidget {
//   const CustomBottomNavBar({super.key});
//
//   @override
//   State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
// }
//
// class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
//   int selectedIndex = 0;
//
//   final List<String> imgStr = [
//     "assets/svg_images/home.svg",
//     "assets/svg_images/unfill_star.svg",
//     "assets/svg_images/chat.svg",
//     "assets/svg_images/user2.svg",
//   ];
//   final List<String> tabNames = ["Home", "Favorite", "Chat", "Profile"];
//
//   @override
//   Widget build(BuildContext context) {
//     final double width = MediaQuery.of(context).size.width;
//
//     return SizedBox(
//       width: width,
//       height: _kBarHeight,
//       child: Stack(
//         children: [
//           // ── Layer 1: Gradient shadow — matches RN LinearGradient SVG layer ──
//           CustomPaint(
//             size: Size(width, _kBarHeight),
//             painter: _ArcShadowPainter(),
//           ),
//
//           // ── Layer 2: White fill — matches RN second <Path fill="#FFFBFB"> ──
//           ClipPath(
//             clipper: _ArcClipper(),
//             child: Container(
//               width: width,
//               height: _kBarHeight,
//               // matches RN fill="#FFFBFB"
//               color: const Color(0xFFFFFBFB),
//             ),
//           ),
//
//           // ── Layer 3: Tab items ─────────────────────────────────────────────
//           // Matches RN: top: height * 0.2 = 34px
//           Positioned(
//             top: _kBarHeight * 0.2,
//             left: 20,   // matches RN paddingHorizontal: 20
//             right: 20,
//             bottom: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: List.generate(imgStr.length, (index) {
//                 final bool isSelected = selectedIndex == index;
//                 return GestureDetector(
//                   onTap: () => setState(() => selectedIndex = index),
//                   behavior: HitTestBehavior.opaque,
//                   child: SizedBox(
//                     // matches RN iconWrapper: width:60, height:60
//                     width: 60,
//                     height: 60,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Images(
//                           imageStr: imgStr[index],
//                           height: 24,
//                           width: 24,
//                           // matches RN: isFocused ? ThemeColors.primary : '#9CA3AF'
//                           color: isSelected
//                               ? const Color(0xFF77153C)
//                               : const Color(0xFF9CA3AF),
//                         ),
//                         const SizedBox(height: 4),
//                         Texts(
//                           text: tabNames[index],
//                           size: 10,
//                           // matches RN label color logic
//                           colorHexValue: isSelected ? 0xFFDD276F : 0xFF000000,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Matches RN SVG Path Layer 2 (white fill) ──────────────────────────────────
// // RN path: M0,100 Q{width/2},0 {width},100 L{width},170 L0,170 Z
// // Peak is at y=0 — top of the widget. Sides start at y=curveDepth=100.
// // ClipPath keeps curve fully visible because peak y=0 == widget top edge.
// class _ArcClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     return Path()
//       ..moveTo(0, _kCurveDepth)                          // left side start
//       ..quadraticBezierTo(
//         size.width / 2, 0,                               // peak at y=0 (top edge)
//         size.width, _kCurveDepth,                        // right side start
//       )
//       ..lineTo(size.width, size.height)                  // bottom-right
//       ..lineTo(0, size.height)                           // bottom-left
//       ..close();
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> old) => false;
// }
//
// // ── Matches RN SVG Path Layer 1 (gradient shadow) ────────────────────────────
// // RN: LinearGradient from rgba(0,0,0,0.25) at top → transparent at bottom
// // Drawn on the same arc path, just behind the white layer
// class _ArcShadowPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final path = Path()
//       ..moveTo(0, _kCurveDepth)
//       ..quadraticBezierTo(size.width / 2, 0, size.width, _kCurveDepth)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//
//     // Matches RN container shadow: shadowColor '#77153C', elevation 50
//     final shadowPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           Colors.black.withOpacity(0.25), // matches RN stopColor rgba(0,0,0,0.25)
//           Colors.black.withOpacity(0.0),  // matches RN stopColor rgba(0,0,0,0)
//         ],
//         stops: const [0.0, 1.0],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
//       ..style = PaintingStyle.fill;
//
//     canvas.drawPath(path, shadowPaint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
// }
// // class CurvedBottomNavigationBar extends StatelessWidget {
// //   final int currentIndex;
// //   final ValueChanged<int> onTap;
// //
// //   const CurvedBottomNavigationBar({
// //     super.key,
// //     required this.currentIndex,
// //     required this.onTap,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       height: 90,
// //       child: Stack(
// //         alignment: Alignment.bottomCenter,
// //         children: [
// //           Positioned.fill(
// //             child: CustomPaint(
// //               painter: _NavBarPainter(),
// //             ),
// //           ),
// //           Positioned(
// //             left: 0,
// //             right: 0,
// //             top: 14,
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 20),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   _NavItem(
// //                     icon: Icons.home,
// //                     label: 'Home',
// //                     selected: currentIndex == 0,
// //                     onTap: () => onTap(0),
// //                   ),
// //                   _NavItem(
// //                     icon: Icons.chat_bubble,
// //                     label: 'Chat',
// //                     selected: currentIndex == 1,
// //                     onTap: () => onTap(1),
// //                     badgeCount: 7,
// //                   ),
// //                   _NavItem(
// //                     icon: Icons.favorite,
// //                     label: 'Favorite',
// //                     selected: currentIndex == 2,
// //                     onTap: () => onTap(2),
// //                   ),
// //                   _NavItem(
// //                     icon: Icons.person,
// //                     label: 'Profile',
// //                     selected: currentIndex == 3,
// //                     onTap: () => onTap(3),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _NavItem extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final bool selected;
// //   final VoidCallback onTap;
// //   final int badgeCount;
// //
// //   const _NavItem({
// //     required this.icon,
// //     required this.label,
// //     required this.selected,
// //     required this.onTap,
// //     this.badgeCount = 0,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final color = selected ? Colors.deepPurple : Colors.grey[600];
// //     return GestureDetector(
// //       onTap: onTap,
// //       behavior: HitTestBehavior.opaque,
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Stack(
// //             clipBehavior: Clip.none,
// //             children: [
// //               Container(
// //                 width: 52,
// //                 height: 52,
// //                 decoration: BoxDecoration(
// //                   color: selected ? Colors.deepPurple.shade50 : Colors.white,
// //                   shape: BoxShape.circle,
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withOpacity(0.05),
// //                       blurRadius: 8,
// //                       offset: const Offset(0, 4),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Icon(icon, color: color, size: 26),
// //               ),
// //               if (badgeCount > 0)
// //                 Positioned(
// //                   right: -4,
// //                   top: -4,
// //                   child: Container(
// //                     padding:
// //                     const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                     decoration: BoxDecoration(
// //                       color: Colors.red,
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: Colors.white, width: 2),
// //                     ),
// //                     child: Text(
// //                       badgeCount > 99 ? '99+' : '$badgeCount',
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 9,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           const SizedBox(height: 6),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               color: color,
// //               fontSize: 11,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _NavBarPainter extends CustomPainter {
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..shader = const LinearGradient(
// //         colors: [
// //           Color(0xFFFFFFFF),
// //           Color(0xFFF7F2FF),
// //         ],
// //         begin: Alignment.topCenter,
// //         end: Alignment.bottomCenter,
// //       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
// //       ..style = PaintingStyle.fill;
// //
// //     final path = Path()
// //       ..moveTo(0, 24)
// //       ..quadraticBezierTo(size.width * 0.20, 0, size.width * 0.45, 14)
// //       ..quadraticBezierTo(size.width * 0.55, 24, size.width * 0.65, 24)
// //       ..quadraticBezierTo(size.width * 0.85, 24, size.width, 0)
// //       ..lineTo(size.width, size.height)
// //       ..lineTo(0, size.height)
// //       ..close();
// //
// //     canvas.drawShadow(path, Colors.black.withOpacity(0.12), 10, true);
// //     canvas.drawPath(path, paint);
// //   }
// //
// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// // }
// //
//
//
//
//
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:two_are_one/core/image.dart';
// // import 'package:two_are_one/core/texts.dart';
// //
// // class CustomBottomNavBar extends StatefulWidget {
// //   const CustomBottomNavBar({super.key});
// //
// //   @override
// //   State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
// // }
// //
// // class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
// //   int selectedIndex = 0;
// //
// //   final List<String> imgStr = [
// //     "assets/svg_images/home.svg",
// //     "assets/svg_images/unfill_star.svg",
// //     "assets/svg_images/chat.svg",
// //     "assets/svg_images/user2.svg",
// //   ];
// //
// //   final List<String> tabNames = [
// //     "Home",
// //     "Favorite",
// //     "Chat",
// //     "Profile",
// //   ];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       color: Colors.transparent,
// //       child: Stack(
// //         alignment: Alignment.bottomCenter,
// //         children: [
// //           // 1. Background Painter
// //           CustomPaint(
// //             size: Size(MediaQuery.of(context).size.width, 135),
// //             painter: NavCurvePainter(),
// //           ),
// //           // 2. Interactive Animated Icons
// //           Container(
// //             height: 100,
// //             padding: const EdgeInsets.only(bottom: 12),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               crossAxisAlignment: CrossAxisAlignment.end,
// //               children: List.generate(imgStr.length, (index) {
// //                 bool isSelected = selectedIndex == index;
// //
// //                 return GestureDetector(
// //                   onTap: () => setState(() => selectedIndex = index),
// //                   behavior: HitTestBehavior.opaque,
// //                   // --- ADDED ANIMATED SCALE HERE ---
// //                   child: AnimatedScale(
// //                     scale: isSelected ? 1.2 : 1.0, // Enlarges by 20% when selected
// //                     duration: const Duration(milliseconds: 300),
// //                     curve: Curves.easeOutBack, // Gives it a slight bounce/elastic feel
// //                     child: Column(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         // Gradient Active Icon Logic
// //                         ShaderMask(
// //                           shaderCallback: (bounds) => isSelected
// //                               ? const LinearGradient(
// //                             colors: [Color(0xFF477CB6), Color(0xFF8B4DAB), Color(0xFFDD276F)],
// //                           ).createShader(bounds)
// //                               : const LinearGradient(colors: [Colors.black54, Colors.black54])
// //                               .createShader(bounds),
// //                           child: Images(
// //                             imageStr: imgStr[index],
// //                             height: 24,
// //                             width: 24,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 6),
// //                         Texts(
// //                           text: tabNames[index],
// //                           size: 10,
// //                           colorHexValue: isSelected ? 0xFFDD276F : 0xFF8E8E8E,
// //                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
// //                         ),
// //                         const SizedBox(height: 10),
// //                         // Animated Dot Indicator
// //                         // AnimatedContainer(
// //                         //   duration: const Duration(milliseconds: 300),
// //                         //   height: 4,
// //                         //   width: isSelected ? 4 : 0, // Dot grows from center
// //                         //   decoration: const BoxDecoration(
// //                         //     shape: BoxShape.circle,
// //                         //     gradient: LinearGradient(
// //                         //       colors: [Color(0xFF477CB6), Color(0xFFDD276F)],
// //                         //     ),
// //                         //   ),
// //                         // ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               }),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class NavCurvePainter extends CustomPainter {
// //   @override

import 'package:flutter/material.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/features/Bottom_Nav_Bar_Screens/profile_screen.dart';
import 'chat_screen.dart';
import 'favourite_screen.dart';
import 'home_screen.dart';

const double _kCurveDepth = 80.0;
const double _kBarHeight  = 80.0;

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
      // ✅ extendBody aur bottomNavigationBar DONO hatao
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
    "assets/svg_images/unfill_star.svg",
    "assets/svg_images/chat.svg",
    "assets/svg_images/user2.svg",
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
            top: _kCurveDepth,
            left: 0,
            right: 0,
            height: _kBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_imgStr.length, (index) {
                final bool isSelected = selectedIndex == index;
                return _NavItem(
                  imgStr: _imgStr[index],
                  label: _tabNames[index],
                  isSelected: isSelected,
                  onTap: () => onTabChanged(index),
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
        width: 65,
        height: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ── Animated scale + gradient icon ─────────────────────────────
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack, // bounce effect
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Selected hone pe glowing circle background ───────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isSelected ? 42 : 0,
                    height: isSelected ? 40 : 0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? const LinearGradient(
                        colors: [
                          Color(0x22477CB6),
                          Color(0x22DD276F),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                    ),
                  ),
                  // ── Gradient icon via ShaderMask ─────────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) => isSelected
                    // ✅ selected: gradient colors — matches commented code
                        ? const LinearGradient(
                      colors: [
                        Color(0xFF477CB6),
                        Color(0xFF8B4DAB),
                        Color(0xFFDD276F),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds)
                    // not selected: grey
                        : const LinearGradient(
                      colors: [Color(0xFF8E8E8E), Color(0xFF8E8E8E)],
                    ).createShader(bounds),
                    child: Images(
                      imageStr: imgStr,
                      height: 24,
                      width: 24,
                      color: Colors.white, // ShaderMask ko white chahiye
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),
            // ── Animated label ─────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFDD276F)
                    : const Color(0xFF8E8E8E),
              ),
              child: Text(label),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

// class _NavItem extends StatelessWidget {
//   final String imgStr;
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _NavItem({
//     required this.imgStr,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: SizedBox(
//         width: 65,
//         height: 65,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // ── Icon with animated scale ───────────────────────────────────
//             AnimatedScale(
//               scale: isSelected ? 1.15 : 1.0,
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeOutBack,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   // selected hone pe halka pink background
//                   color: isSelected
//                       ? const Color(0xFFDD276F).withOpacity(0.10)
//                       : Colors.transparent,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Images(
//                     imageStr: imgStr,
//                     height: 22,
//                     width: 22,
//                     color: isSelected
//                         ? const Color(0xFFDD276F)
//                         : const Color(0xFF9CA3AF),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 3),
//
//             // ── Label ─────────────────────────────────────────────────────
//             AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 200),
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight:
//                 isSelected ? FontWeight.bold : FontWeight.w500,
//                 color: isSelected
//                     ? const Color(0xFFDD276F)
//                     : const Color(0xFF9CA3AF),
//               ),
//               child: Text(label),
//             ),
//
//             // ── Active dot indicator ───────────────────────────────────────
//             const SizedBox(height: 3),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               width: isSelected ? 5 : 0,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? const Color(0xFFDD276F)
//                     : Colors.transparent,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
      path.shift(const Offset(0, -4)),
      Paint()
        ..color = Colors.black.withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter old) =>
      old.curveDepth != curveDepth || old.barHeight != barHeight;
}

// import 'package:flutter/material.dart';
// import 'package:two_are_one/core/image.dart';
// import 'package:two_are_one/core/texts.dart';
//
// // ── Sirf yeh do numbers change karo apni marzi se ─────────────────────────
// const double _kCurveDepth = 30.0;  // curve kitni upar uthegi (peak height)
// const double _kBarHeight  = 80.0;  // flat white area ki height (tabs ka hissa)
// // Total widget height = _kCurveDepth + _kBarHeight = 110px
// // ──────────────────────────────────────────────────────────────────────────
//
// class CustomBottomNavBar extends StatefulWidget {
//   const CustomBottomNavBar({super.key});
//
//   @override
//   State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
// }
//
// class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
//   int selectedIndex = 0;
//
//   final List<String> imgStr = [
//     "assets/svg_images/home.svg",
//     "assets/svg_images/unfill_star.svg",
//     "assets/svg_images/chat.svg",
//     "assets/svg_images/user2.svg",
//   ];
//   final List<String> tabNames = ["Home", "Favorite", "Chat", "Profile"];
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double totalHeight = _kCurveDepth + _kBarHeight;
//
//     return SizedBox(
//       width: screenWidth,
//       height: totalHeight,
//       child: Stack(
//         clipBehavior: Clip.none, // tabs ko clip mat karo
//         children: [
//
//           // ── Layer 1: Shadow ───────────────────────────────────────────────
//           // Curve ke upar ek halki shadow — same as tumhara pehla design
//           Positioned.fill(
//             child: CustomPaint(
//               painter: _ShadowPainter(
//                 curveDepth: _kCurveDepth,
//                 barHeight: _kBarHeight,
//               ),
//             ),
//           ),
//
//           // ── Layer 2: White curved shape ───────────────────────────────────
//           // ClipPath ensures: sirf curve ke andar white hai, upar kuch nahi
//           // Peak y=0 hai (widget ka top edge) — koi transparent gap nahi
//           ClipPath(
//             clipper: _CurveClipper(
//               curveDepth: _kCurveDepth,
//               barHeight: _kBarHeight,
//             ),
//             child: Container(
//               width: screenWidth,
//               height: totalHeight,
//               color: Colors.white,
//             ),
//           ),
//
//           // ── Layer 3: Tab icons ────────────────────────────────────────────
//           // _kCurveDepth se neeche start hote hain tabs
//           Positioned(
//             top: _kCurveDepth,
//             left: 0,
//             right: 0,
//             height: _kBarHeight,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: List.generate(imgStr.length, (index) {
//                 final bool isSelected = selectedIndex == index;
//                 return GestureDetector(
//                   onTap: () => setState(() => selectedIndex = index),
//                   behavior: HitTestBehavior.opaque,
//                   child: SizedBox(
//                     width: 60,
//                     height: 60,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         AnimatedScale(
//                           scale: isSelected ? 1.1 : 1.0,
//                           duration: const Duration(milliseconds: 200),
//                           curve: Curves.easeOutBack,
//                           child: Images(
//                             imageStr: imgStr[index],
//                             height: 24,
//                             width: 24,
//                             color: isSelected
//                                 ? const Color(0xFFDD276F)
//                                 : const Color(0xFF9CA3AF),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Texts(
//                           text: tabNames[index],
//                           size: 10,
//                           colorHexValue:
//                           isSelected ? 0xFFDD276F : 0xFF000000,
//                           fontWeight: isSelected
//                               ? FontWeight.bold
//                               : FontWeight.w500,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── White shape clipper ────────────────────────────────────────────────────────
// // Path:  left side (y = curveDepth)
// //        → arch peak (y = 0, widget top edge)
// //        → right side (y = curveDepth)
// //        → bottom corners
// // Result: exactly the curved white bar — nothing above the arch is white
// class _CurveClipper extends CustomClipper<Path> {
//   final double curveDepth;
//   final double barHeight;
//   const _CurveClipper({required this.curveDepth, required this.barHeight});
//
//   @override
//   Path getClip(Size size) {
//     return Path()
//       ..moveTo(0, curveDepth)                    // left side start
//       ..quadraticBezierTo(
//         size.width / 2, 0,                       // peak — exactly at y=0, no overflow
//         size.width, curveDepth,                  // right side start
//       )
//       ..lineTo(size.width, size.height)          // bottom-right
//       ..lineTo(0, size.height)                   // bottom-left
//       ..close();
//   }
//
//   @override
//   bool shouldReclip(covariant _CurveClipper old) =>
//       old.curveDepth != curveDepth || old.barHeight != barHeight;
// }
//
// // ── Shadow painter ─────────────────────────────────────────────────────────────
// // Curve ke top edge pe shadow — same shape, thoda blur ke saath
// class _ShadowPainter extends CustomPainter {
//   final double curveDepth;
//   final double barHeight;
//   const _ShadowPainter({required this.curveDepth, required this.barHeight});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Same arc path — shadow ke liye
//     final path = Path()
//       ..moveTo(0, curveDepth)
//       ..quadraticBezierTo(size.width / 2, 0, size.width, curveDepth)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//
//     // Soft blur shadow — bilkul waise jaise tumhara pehla design tha
//     final shadowPaint = Paint()
//       ..color = Colors.black.withOpacity(0.10)
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
//       ..style = PaintingStyle.fill;
//
//     // Shadow thodi upar shift karke draw karo taake curve ke upar dikhe
//     canvas.drawPath(path.shift(const Offset(0, -4)), shadowPaint);
//   }
//
//   @override
//   bool shouldRepaint(covariant _ShadowPainter old) =>
//       old.curveDepth != curveDepth || old.barHeight != barHeight;
// }