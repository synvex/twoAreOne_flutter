import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'loader.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPress;
  final bool loading;
  final bool disabled;
  final List<Color>? colors;
  final Color textColor;
  final double borderRadius;
  final double height;
  final Widget? leftIcon;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.title,
    this.onPress,
    this.loading = false,
    this.disabled = false,
    this.colors,
    this.textColor = AppColors.white,
    this.borderRadius = 100,
    this.height = 55,
    this.leftIcon,
    this.constraints,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;
    final gradientColors = colors ?? const [Color(0xFF77153C), Color(0xFFDD276F)];

    return GestureDetector(
      onTap: isDisabled ? null : onPress,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1,
        child: Container(
          height: height,
          margin: const EdgeInsets.only(top: 4),
          padding: padding,
          constraints: constraints,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leftIcon != null) ...[leftIcon!, const SizedBox(width: 8)],
              if (loading)
                Loader(color: textColor, size: 20)
              else
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: textColor,),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
