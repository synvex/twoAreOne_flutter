import 'package:flutter/material.dart';

class CircularAvatar extends StatelessWidget {
  final Widget widget;
  final double radius;
  final int? hexColor;

  const CircularAvatar({
    super.key,
    required this.widget,
    required this.radius,
    this.hexColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(hexColor ?? 0x00000000),
      child: widget,
    );
  }
}
