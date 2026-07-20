import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

/// Port of the RN `MenuItem` component + `sheetItem` / `sheetIcon` /
/// `label` styles used inside the bottom sheet.
class BottomSheetMenuItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const BottomSheetMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.only(left: 8, right: 16),
        decoration: BoxDecoration(
          color: const Color(0x99EEEEEE),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
              )
            else
              Container(
                width: 55,
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.grey1,
                  shape: BoxShape.circle,
                ),
                child: icon,
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
