import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Port of `src/components/Loader`. Small inline spinner used inside screens
/// (list pagination footers, button loading state, etc.) - as opposed to
/// [LoadingScreen] which is the full-screen boot loader.
class Loader extends StatelessWidget {
  final double size;
  final Color color;
  const Loader({super.key, this.size = 24, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
    );
  }
}
