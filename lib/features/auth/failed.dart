import 'package:flutter/material.dart';
import 'package:two_are_one/core/containers.dart';

class FailedWidget extends StatelessWidget {
  const FailedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Floating dots around the main circle
          _dot(0, -80, 5, 0.5),
          _dot(-80, -75, 19, 0.4),
          _dot(40, -45, 2, 0.6),
          _dot(80, -50, 14, 0.4),
          _dot(-90, 1, 2, 0.5),
          _dot(72, 30, 6, 0.5),
          _dot(71, 60, 6, 0.4),
          _dot(38, 70, 2, 0.4),
          _dot(-85, 50, 10, 0.6),
          _dot(-35, 80, 7, 0.6),

          // Large pink circle background
          Container(
            width: 135,
            height: 135,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFff8294).withOpacity(0.8),
                  const Color(0xFFdf605f).withOpacity(0.9)
                ],
              ),
            ),
          ),
          // White rounded square in the center
          Containers(
            wWidth: 44,
            wHeight: 44,
              hexValue: 0xFFFFFFFF,
              radius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            child: const Center(
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFFFF4D73),
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double x, double y, double size, double opacity) {
    return Positioned(
      left: 80 + x - (size / 2), // 80 is half of 160
      top: 80 + y - (size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFFff8294),
              Color(0xFFdf605f),
            ],
          ),
        ),
      ),
    );
  }
}
