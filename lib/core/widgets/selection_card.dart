import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/my_icons.dart';
import 'package:two_are_one/core/widgets/texts.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Containers(
        wHeight: 60,
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
              padding: EdgeInsets.all(8),
              wWidth: 36,
              wHeight: 36,
                hexValue: leftCircleColor,
                shape: BoxShape.circle,
              child: Images(imageStr: leftIcon),
            ),
            // Right icon circle — slightly overlapping
            const SizedBox(width: 4),
            Containers(
                wWidth: 36,
                wHeight: 36,
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
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
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