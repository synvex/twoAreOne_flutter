import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/widgets/image.dart';

class ReportSuccessDialog extends StatelessWidget {
  final VoidCallback? onPressed;

  const ReportSuccessDialog({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320.w,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.w,
              height: 70.w,
              decoration: const BoxDecoration(
                // color: Color(0xffFCE8F1),
                shape: BoxShape.circle,
              ),
              child: const Images(imageStr: "assets/svg_images/reportdone.svg"),
            ),

            SizedBox(height: 18.h),

            Text(
              "Report Submitted",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xffD61E6E),
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              "Thank you for your report. Our moderation team will review this profile and take appropriate action if it violates our Community Guidelines.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                height: 1.5,
                color: const Color(0xff6B7280),
              ),
            ),

            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed:
                    onPressed ??
                    () {
                      Navigator.pop(context);
                    },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xffC62364),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  "Done",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
