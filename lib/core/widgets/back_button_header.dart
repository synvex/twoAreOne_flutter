import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class BackButtonHeader extends StatelessWidget {
  final VoidCallback? onPress;
  final String? title;
  final String? subTitle;
  final bool noBack;
  final bool noIcon;
  final Widget? icon;
  final VoidCallback? onIconPress;

  const BackButtonHeader({
    super.key,
    this.onPress,
    this.title,
    this.subTitle,
    this.noBack = false,
    this.noIcon = false,
    this.icon,
    this.onIconPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!noBack)
            GestureDetector(
              onTap: onPress ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border1)),
                child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.darkGrey),
              ),
            )
          else
            const SizedBox(width: 50, height: 50),
          if (title != null)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subTitle != null)
                    Text(subTitle!, textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(   fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.black)),
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(   fontWeight: FontWeight.bold,
    fontSize: 24, color: AppColors.black)),
                ],
              ),
            ),
          if (!noIcon)
            GestureDetector(
              onTap: onIconPress,
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD9D9D9))),
                child: icon,
              ),
            )
          else
            const SizedBox(width: 50, height: 50),
        ],
      ),
    );
  }
}
