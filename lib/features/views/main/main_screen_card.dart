import 'package:flutter/material.dart';

class StackedUserCards extends StatelessWidget {
  const StackedUserCards({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
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
            left: isLandscape ? 212: 7,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: sideCardWidth,
                height: sideCardHeight,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
            right: isLandscape? 218: 7, // exactly 1px from right edge
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: sideCardWidth,
                height: sideCardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: -10,
                    offset: const Offset(0,18),
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









// import 'package:flutter/material.dart';
//
// class StackedUserCards extends StatelessWidget {
//   const StackedUserCards({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = 425;
//     double cardHeight = 220;
//     double sideCardWidth = 200;
//     double centerCardWidth = 221;
//     final bool onLandScape = MediaQuery.of(context).orientation == Orientation.landscape;
//     return SizedBox(
//       height: 245, // Extra space for shadows
//       width: screenWidth,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned(
//             top: 1,
//             left: sideCardWidth* .05,
//             child: Transform.rotate(
//               angle: -0.005, // Slight tilt
//               child: Container(
//                 width: 200,
//                 height:  255,
//                 decoration: BoxDecoration(
//                   color: const Color(0x00000000), // Yellow
//                   borderRadius: BorderRadius.circular(42),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.02),
//                       blurRadius: 7,
//                       offset: const Offset(-2, 4),
//                     )
//                   ],
//                   image: const DecorationImage(
//                     image: AssetImage('assets/images/left_person.png'), // Replace with your asset
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // --- RIGHT CARD (Blue) ---
//           Positioned(
//             top: 1,
//             right: sideCardWidth*.015,
//             child: Transform.rotate(
//               angle: .005, // Slight tilt
//               child: Container(
//                 width: 220,
//                 height:  255,
//                 decoration: BoxDecoration(
//                    color: const Color(0x00000000), // transparent
//                   borderRadius:  BorderRadius.circular(42),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.02 ),
//                       blurRadius: 15,
//                       offset: const Offset(2, 4),
//                     )
//                   ],
//                   image: const DecorationImage(
//                     image: AssetImage(
//                         'assets/images/right_person.png',
//                     ), // Replace with your asset
//                     fit: BoxFit.cover,
//
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // --- CENTER CARD (Focused) ---
//           Positioned(
//             top: 0,
//             child: Container(
//               width: 215,
//               height:  235,
//               decoration: BoxDecoration(
//                 // color: Colors.white.withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(42),
//                 // border: Border.all(
//                     // color: Colors.white70, width: 1),
//                 // image: DecorationImage(
//                 //   image: AssetImage(
//                 //       'assets/images/couple.png'
//                 //   ), // Replace with your asset
//                 //   fit: BoxFit.cover,
//                 // ),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(42),
//                 child: Image.asset(
//                   'assets/images/couple.png',
//                   fit: BoxFit.cover,        // fills the card fully
//                   alignment: Alignment.topCenter, // focus on faces not feet
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }