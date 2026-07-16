import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centered spinner used by every screen that loads remote content.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.mehroon),
    );
  }
}