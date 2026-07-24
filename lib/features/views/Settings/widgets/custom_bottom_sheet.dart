import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
class CustomBottomSheet extends StatelessWidget {
  final double sheetHeight;
  final Widget child;

  const CustomBottomSheet({super.key, required this.child, this.sheetHeight = 420});

  /// Shows the sheet the same way RN's `isVisible` + `onClose` pair did:
  /// tapping the backdrop (or the invisible top strip) dismisses it.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double sheetHeight = 420,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CustomBottomSheet(sheetHeight: sheetHeight, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      height: sheetHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(width, sheetHeight),
            painter: _NotchedSheetPainter(),
          ),
          // curve: small pill handle drawn over the notch, tap = dismiss
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 55,
                height: 8,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
          Positioned(
            top: sheetHeight * 0.14,
            left: 0,
            right: 0,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child),
          ),
        ],
      ),
    );
  }
}

class _NotchedSheetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w - 50, 0)
      ..cubicTo(w - 20, 0, w, 20, w, 45)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..lineTo(0, 45)
      ..cubicTo(0, 20, 20, 0, 45, 0)
      ..lineTo(w * 0.35, 0)
      ..cubicTo(w * 0.42, 0, w * 0.41, 36, w * 0.5, 36)
      ..cubicTo(w * 0.59, 36, w * 0.56, 0, w * 0.65, 0)
      ..lineTo(w - 50, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
