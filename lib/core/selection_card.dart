import 'package:flutter/material.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/core/my_icons.dart';
import 'package:two_are_one/core/texts.dart';

class SelectionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int activeColor;
  final int leftCircleColor;
  final int rightCircleColor;
  final String leftIcon;
  final String rightIcon;

  const SelectionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.leftCircleColor,
    required this.rightCircleColor,
    required this.leftIcon,
    required this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    Color displayColor = isSelected ? Color(0xFFC8375E) : const Color(0xFFCDCDCD);
    double width = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: onTap,
      child: Containers(
        wHeight: 65,
        wWidth: double.infinity,
        border: Border.all(
          color: isSelected ? Color(0xFFC8375E) : Colors.grey.shade200,
          width: 1,
        ),
        hexValue: isSelected ? activeColor : 0xFFF3F3F3,
        opacityValue: isSelected ? 0.05: .5,
        radius: BorderRadius.circular(16),
        child: Row(
          children: [
            const SizedBox(width: 15),
            // Left icon circle
            Containers(
              padding: EdgeInsets.all(7),
              wWidth: 38,
              wHeight: 38,
                hexValue: leftCircleColor,
                shape: BoxShape.circle,
              child: Images(imageStr: leftIcon),
            ),
            // Right icon circle — slightly overlapping
            const SizedBox(width: 4),
            Containers(
                wWidth: 38,
                wHeight: 38,
                  padding: EdgeInsets.all(8),
                  hexValue: rightCircleColor,
                  shape: BoxShape.circle,
                child: Images(
                    imageStr: rightIcon),
              ),
            const SizedBox(width: 15),
            Expanded(
              child: Texts(
                text: label,
                size: 14,
                colorHexValue: isSelected ? 0xFFC8375E : 0xFF000000,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            MyIcons(
                iconData: isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: displayColor,
            ),
            const SizedBox(width: 17),
          ],
        ),
      ),
    );
  }
}





// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:two_are_one/core/containers.dart';
// import 'package:two_are_one/core/image.dart';
// import 'package:two_are_one/core/texts.dart';
//
// class SelectionCard extends StatelessWidget {
//   final String label;
//   final IconData? icon;
//   final int? circleColor;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final int activeColor; // The color when selected (Blue or Pink)
//   const SelectionCard({
//     super.key,
//     required this.label,
//      this.icon,
//     required this.isSelected,
//     required this.onTap,
//     required this.activeColor, this.circleColor, // Now required
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Logic: If selected, use activeColor. If not, use Grey.
//     Color displayColor = isSelected ? Color(activeColor) : const Color(0xFF7D7D7D);
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Containers(
//         wHeight: 50,
//         wWidth: 330,
//         // margin: const EdgeInsets.symmetric(vertical: 6),
//         // padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//         hexValue: 0xFFF3F3F3, radius: BorderRadius.circular(30),
//         child: Row(
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               margin: EdgeInsets.all( 5),
//               decoration: BoxDecoration(
//                 color: Color(circleColor ?? 0xFFA96E86),
//                 shape: BoxShape.circle,
//               ),
//               child: Images(
//                   imageStr: label== "Male"? "assets/svg_images/user2.svg":
//                   "assets/svg_images/Frame.svg"),
//               // child: MyIcons(
//               //   iconData:label == "Male" ? Icons.person_2_outlined : Icons.person_3_outlined,
//               //   size: 20,
//               //   color: displayColor,
//               // ),
//             ),
//             const SizedBox(width: 15),
//             Texts(
//               text: label,
//               size: 16,
//               fontWeight: FontWeight.w500,
//             ),
//             const Spacer(),
//             Icon(
//               isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
//               color: displayColor,
//             ),
//             const SizedBox(width: 17),
//           ],
//         ),
//       ),
//     );
//   }
// }