import 'package:flutter/material.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/image.dart';

class Back_Button extends StatelessWidget {
  final VoidCallback onTap;
  const Back_Button({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Containers(
        wWidth: 50,
        wHeight: 50,
        alignment: Alignment.center,
        shape: BoxShape.circle,
        hexValue: 0xFFFFFFFF,
        border: Border.all(
          color: const Color(0xFF786C65).withOpacity(0.6),
          width: 1,
        ),
        child: const Images(
          height: 30,
          width: 30,
          color: Color(0xFF786C65),
          imageStr: "assets/svg_images/backButton.svg",
        ),
      ),
    );
  }
}
