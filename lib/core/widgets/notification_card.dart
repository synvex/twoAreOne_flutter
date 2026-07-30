import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/utils/date_time_formater.dart';
import 'package:two_are_one/core/utils/random_color_picker_util.dart';
import 'package:two_are_one/data/models/notification_model.dart';

import '../constants/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const NotificationCard({
    super.key,
    required this.item,
    this.onAccept,
    this.onDecline,
  });
  bool _isOnline(NotificationModel item) {
    return item.userInfo.currentActive == "1" ||
        item.userInfo.isActualLogin == "1" ||
        item.userInfo.isMakeOnlines == "1";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Container(
                  width: 48.r,
                  height: 48.r,
                  color: AppColors.grey1,
                  child: Image.network(
                    item.userInfo.profileImgUrl.toString(),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      final bgColor = RandomColorPickerUtil.getColor(
                        item.userInfo.fullName.toString(),
                      );
                      return CircleAvatar(
                        radius: 24.r,
                        backgroundColor: bgColor,
                        child: Center(
                          child: Text(
                            item.userInfo.fullName.toString().trim().isNotEmpty
                                ? item.userInfo.fullName
                                      .toString()
                                      .trim()[0]
                                      .toUpperCase()
                                : "?",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      final bgColor = RandomColorPickerUtil.getColor(
                        item.userInfo.fullName.toString(),
                      );
                      return CircleAvatar(
                        radius: 24.r,
                        backgroundColor: bgColor,
                        child: Center(
                          child: Text(
                            item.userInfo.fullName.toString().trim().isNotEmpty
                                ? item.userInfo.fullName
                                      .toString()
                                      .trim()[0]
                                      .toUpperCase()
                                : "?",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '@${item.userInfo.fullName}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                          TextSpan(
                            text: item.msgType == 'views'
                                ? ' Viewed your profile'
                                : item.msgType == 'likes'
                                ? ' Liked your profile'
                                : item.msgType == 'favourites'
                                ? ' Added you to favourites'
                                : item.msgType == 'match'
                                ? ' You have a new match'
                                : item.msgType == 'super_like'
                                ? ' Super liked your profile'
                                : item.msgType == 'comment'
                                ? ' Commented on your post'
                                : item.msgType == 'follow'
                                ? ' Started following you'
                                : item.msgType == 'gift'
                                ? ' Sent you a gift'
                                : item.msgType == 'visit'
                                ? ' Visited your profile'
                                : item.msgType == 'unmatch'
                                ? ' Unmatched with you'
                                : ' Sent you a message',

                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '',
                      // DateTimeFormatter.onlyDate(item.datetime),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w300,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      color: _isOnline(item)
                          ? AppColors.green
                          : AppColors.grayColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 26.h),
                  Text(
                    '',
                    // DateTimeFormatter.chatTime(item.datetime),
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
