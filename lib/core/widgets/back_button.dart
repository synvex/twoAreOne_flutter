import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/image.dart';

class Back_Button extends StatelessWidget {
  final VoidCallback onTap;
  const Back_Button({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Containers(
        wWidth: 48,
        wHeight: 48,
        alignment: Alignment.center,
        shape: BoxShape.circle,
        hexValue: 0xFFFFFFFF,
        border: Border.all(
          color: const Color(0xFF786C65).withValues(alpha: 0.4),
          width: 1,
        ),
        child: Images(
          height: 25,
          width: 25,
          color: const Color(0xFF786C65).withValues(alpha: 0.7),
          imageStr: "assets/svg_images/backButton.svg",
        ),
      ),
    );
  }
}
