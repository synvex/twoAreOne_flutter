import 'package:flutter/material.dart';

class StackedUserCards extends StatelessWidget {
  const StackedUserCards({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double sideCardWidth = 230.0;
    const double sideCardHeight = 248.0;
    const double centerCardWidth = 210.0;
    const double centerCardHeight = 230.0;
    const double stackHeight = 250.0;
    // Define the specific radius once to keep it consistent
    const borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(42),
      bottomRight: Radius.circular(42),
      // topLeft and topRight are zero by default
    );

    return SizedBox(
      height: stackHeight,
      width: screenWidth,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // --- LEFT CARD ---
          Positioned(
            top: 5,
            left: isLandscape ? 212 : 7,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: sideCardWidth,
                height: sideCardHeight,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      spreadRadius: -2,
                      offset: const Offset(5, 8),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/left_person.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // --- RIGHT CARD ---
          Positioned(
            top: 5,
            right: isLandscape ? 218 : 7, // exactly 1px from right edge
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: sideCardWidth,
                height: sideCardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: -2,
                      offset: const Offset(-5, 8),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/right_person.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // --- CENTER CARD ---
          Positioned(
            top: 0,
            child: Container(
              width: centerCardWidth,
              height: centerCardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    spreadRadius: -10,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(42),
                child: Image.asset(
                  'assets/images/couple.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}









