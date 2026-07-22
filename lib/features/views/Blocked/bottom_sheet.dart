import 'package:flutter/material.dart';

class UserActionBottomSheet extends StatelessWidget {
  final List<Widget> children;
  final double sheetHeight;

  const UserActionBottomSheet({
    super.key,
    required this.children,
    this.sheetHeight = 300,
  });

  static Future<void> show(
      BuildContext context, {
        required List<Widget> children,
        double sheetHeight = 300,
      })
  {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UserActionBottomSheet(
        children: children,
        sheetHeight: sheetHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {}, // absorb taps on the sheet itself
          child: SizedBox(
            width: width,
            height: sheetHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                CustomPaint(
                  size: Size(width, sheetHeight),
                  painter: _SheetPainter(Colors.white),
                ),
                Container(
                  width: 55,
                  height: 8,
                  margin: const EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Positioned(
                  top: 48,
                  left: 16,
                  right: 16,
                  child: Column(children: children),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetPainter extends CustomPainter {
  final Color color;
  _SheetPainter(this.color);

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

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SheetPainter oldDelegate) =>
      oldDelegate.color != color;
}

class SheetMenuItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const SheetMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0x99EEEEEE),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 55,
                height: 55,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              Container(
                width: 55,
                height: 55,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
                child: icon,
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}