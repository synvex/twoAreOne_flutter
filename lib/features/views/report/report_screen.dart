import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/constants/app_icons.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/data/viewmodels/report_viewmodel.dart';
import 'package:two_are_one/features/views/report/report_dialog.dart';

class ReportScreen extends StatefulWidget {
  final int reportId;
  const ReportScreen({super.key, required this.reportId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final bool _isLoading = false;

  final TextEditingController commentController = TextEditingController();

  String selectedReason = "Other";

  final List<String> reasons = [
    "Fake Profile",
    "Inappropriate Photos",
    "Harassment or Bullying",
    "Spam or Scam",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    final reportViewModel = Provider.of<ReportViewModel>(
      context,
      listen: false,
    );
    return Scaffold(
      backgroundColor: AppColors.mehroon,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: AppHeaderWidget(
                leadingIcon: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.transparent,
                    child: SvgPicture.asset(
                      AppIcons.backIcon,
                      color: Colors.white,
                    ),
                  ),
                ),

                titleWidget: Text(
                  "           Report Profile",
                  style: GoogleFonts.roboto(
                    fontSize: 22.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                isTrailing: false,
              ),
            ),

            SizedBox(height: 20.h),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Help Us Keep Our Community Safe",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1F3340),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      Text(
                        "Tell us why you're reporting this profile. Your report will be reviewed by our moderation team.",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: const Color(0xff7F93A3),
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 28.h),

                      Text(
                        "SELECT THE ISSUES YOU'VE EXPERIENCED",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xff8D99AE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 18.h),

                      ...reasons.map(
                        (reason) => Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xffE5E7EB),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: RadioListTile<String>(
                                value: reason,
                                groupValue: selectedReason,
                                onChanged: (value) {
                                  setState(() {
                                    selectedReason = value!;
                                  });
                                },
                                activeColor: const Color(0xffD61E6E),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                ),
                                title: Text(
                                  reason,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: const Color(0xff1F3340),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Your Comment ",
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                color: const Color(0xff1F3340),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: "(Optional)",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xffE5E7EB)),
                        ),
                        child: TextFormField(
                          controller: commentController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "Please describe what happened",
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16.w),
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: Consumer<ReportViewModel>(
                          builder: (context, value, child) {
                            return MainButtonWidget(
                              text: "Submit Feedback",
                              hexValue: 0xFFFFFFFF,
                              isLoading: value.isLoading,
                              onTap: () async {
                                final success = await value.submitReport(
                                  widget.reportId,
                                  selectedReason,
                                  commentController.text,
                                );

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => ReportSuccessDialog(
                                    message: value.message,
                                    onPressed: () {
                                      Navigator.pop(context);

                                      if (success) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                );
                              },
                              gradient: const LinearGradient(
                                colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 20.h),
                    ],
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
