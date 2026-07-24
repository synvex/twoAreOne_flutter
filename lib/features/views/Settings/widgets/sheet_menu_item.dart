import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loader.dart';

class SheetMenuItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPress;
  final bool iconLoading;
  final Color? labelColor;

  const SheetMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.onPress,
    this.iconLoading = false,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onPress,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(left: 8, right: 16),
        decoration: BoxDecoration(
          color: const Color(0x99EEEEEE),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(color:Color(0xFFD9D9D9), shape: BoxShape.circle),
              child: iconLoading ? const Loader(size: 20, color: AppColors.black) : icon,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 16,
                fontWeight: FontWeight.w500,
                color: labelColor ?? AppColors.black,),
            ),
          ],
        ),
      ),
    );
  }
}
