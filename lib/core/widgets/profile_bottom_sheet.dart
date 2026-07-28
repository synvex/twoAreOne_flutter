import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/image.dart';

class MenuBottomSheet extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onSettings;
  final VoidCallback onDelete;

  const MenuBottomSheet({
    super.key,
    required this.onLogout,
    required this.onSettings,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double sheetHeight = 400; // Menu ke hisab se height set karein

    return Container(
      height: sheetHeight,
      color: Colors.transparent,
      child: Stack(
        children: [
          // Same Curved Background
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, sheetHeight),
            painter: CurveBackgroundPainter(),
          ),
          // Grey Drag Handle (Small container curve)
          Positioned(
            top: 5,
            left: MediaQuery.of(context).size.width / 2 - 28,
            right: MediaQuery.of(context).size.width / 2 - 27,
            child: Container(
              width: 55,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Actual Content
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 80, 25, 0),
            child: Column(
              children: [
                _sheetItem(
                  iconImg: 'assets/svg_images/Profile/profileEdit.svg',
                  label: "Edit Profile",
                  onTap: onSettings,
                ),
                const SizedBox(height: 15),
                _sheetItem(
                  iconImg: 'assets/svg_images/Profile/deleteAccount.svg',
                  // icon: Icons.logout_rounded,
                  label: "Delete Account",
                  labelColor: const Color(
                    0xFF77153C,
                  ), // Maroon color for Logout
                  onTap: onDelete,
                ),
                _sheetItem(
                  iconImg: 'assets/svg_images/Profile/profileLogout.svg',
                  // icon: Icons.logout_rounded,
                  label: "Logout",
                  labelColor: const Color(
                    0xFF77153C,
                  ), // Maroon color for Logout
                  onTap: onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _sheetItem({
    required String iconImg,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
  })
  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0x80B9B9B9)),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Thora light color for better UI
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Images(imageStr: iconImg),
              // Icon(icon, color: labelColor ?? Colors.black87),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: labelColor ?? Colors.black,
              ),
            ),
            // const Spacer(),
          ],
        ),
      ),
    );
  }
}

class CurveBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    double w = size.width;
    double h = size.height;

    path.moveTo(45, 0);
    path.lineTo(w * 0.35, 0);
    path.cubicTo(w * 0.42, 0, w * 0.41, 36, w * 0.5, 36);
    path.cubicTo(w * 0.59, 36, w * 0.60, 0, w * 0.65, 0);
    path.lineTo(w - 45, 0);
    path.quadraticBezierTo(w, 0, w, 45);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.lineTo(0, 45);
    path.quadraticBezierTo(0, 0, 45, 0);
    path.close();

    canvas.drawPath(path.shift(
        const Offset(0, -2)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
