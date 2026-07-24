import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/Error/api_error.dart';
import '../../../../core/constants/app_colors.dart';

class CustomAlert {
  CustomAlert._();

  static Future<void> showError(BuildContext context, ApiError error) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(error.title, style:
        GoogleFonts.poppins(fontWeight: FontWeight.w600),),
        content: Text(error.message, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (error.isNetworkError && error.retryAction != null) {
                error.retryAction!();
              }
            },
            child: Text(
              error.alertActionButton,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showMessage(BuildContext context, {required String title, required String message}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Text(message, style: GoogleFonts.poppins(
            fontSize: 14,)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Ok',
                style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
    ],
      ),
    );
  }
}
