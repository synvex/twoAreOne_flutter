import 'package:flutter/material.dart';

import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/core/texts.dart';


class NotchSheetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double width = size.width;
    double height = size.height;

    Path path = Path();
    // Path starts from top right (before corner)
    path.moveTo(width - 50, 0);
    // Top right corner
    path.cubicTo(width - 20, 0, width, 20, width, 45);
    // Right side and bottom
    path.lineTo(width, height);
    path.lineTo(0, height);
    // Left side
    path.lineTo(0, 45);
    // Top left corner
    path.cubicTo(0, 20, 20, 0, 45, 0);
    // Horizontal line to notch start
    path.lineTo(width * 0.35, 0);
    // Notch curve down
    path.cubicTo(width * 0.42, 0, width * 0.41, 36, width * 0.5, 36);
    // Notch curve up
    path.cubicTo(width * 0.59, 36, width * 0.56, 0, width * 0.65, 0);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MenuItem extends StatelessWidget {
  final String imgStr;
  final String label;
  final VoidCallback onPress;
  final bool iconLoading;

  const MenuItem({super.key,
    required this.imgStr,
    required this.label,
    required this.onPress,
    this.iconLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 5.0, horizontal: 30.0),
        child: Containers(
          padding: EdgeInsets.all(10),
          wWidth: double.infinity,
          hexValue: 0xFFE0E0E0,
          radius: BorderRadius.circular(50),
          opacityValue: .4,
          child: Row(
            children: [
              Containers(
                hexValue: 0xFFE0E0E0,
                padding: EdgeInsets.all(12),
                shape: BoxShape.circle,
                child: iconLoading
                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                    : Images(
                       // color: Colors.grey,
                       imageStr: imgStr,
                       height: 32,
                       width: 32,
                     )
              ),
              const SizedBox(width: 15),
              Texts(
                text: label,
                    size: 16,
                    colorHexValue: 0xFF000000,
                    fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showCustomBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        height: 330, // sheetHeight parameter
        width: double.infinity,
        child: Stack(
          children: [
            // 1. Custom SVG Background
            CustomPaint(
              size: const Size(double.infinity, 350),
              painter: NotchSheetPainter(),
            ),
            // 2. The Notch Handle (Pill shape at the very top)
            Positioned(
              top: 2,
              left: 0,
              right: 0,
              child: Center(
                child: Containers(
                  wWidth: 55,
                  wHeight: 8,
                    hexValue: 0xFFE0E0E0,
                    radius: BorderRadius.circular(99),
                ),
              ),
            ),
            // 3. Content
            Padding(
              padding: const EdgeInsets.only(top: 50.0), // Content ko notch se niche lane ke liye
              child: Column(
                children: [
                  MenuItem(

                    imgStr: 'assets/svg_images/Favorite/viewProfile.svg',
                    label: "View Profile",
                    onPress: () {
                      Navigator.pop(context);
                      // Navigate logic here
                    },
                  ),
                  MenuItem(
                    imgStr: 'assets/svg_images/Favorite/blockProfile.svg',
                    label: "Block Profile",
                    iconLoading: false, // pass state here
                    onPress: () {
                      // Block logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}