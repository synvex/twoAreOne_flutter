import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_are_one/data/models/notification_items.dart';

import '../constants/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const NotificationCard({
    super.key,
    required this.item,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = item.showActions;
    final Color cardColor = isDark ? AppColors.black : AppColors.lightGray;
    final Color titleColor = isDark ? AppColors.white : AppColors.primaryText;
    final Color subTextColor = isDark ? AppColors.grey1 : AppColors.grey2;
    final Color dotColor = item.isOnline
        ? AppColors.green
        : (isDark ? AppColors.grey1 : AppColors.grayColor);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor,
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
                    item.avatarUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Icon(
                        Icons.person,
                        color: AppColors.grey2,
                        size: 24.r,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, color: AppColors.grey2, size: 24.r),
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
                            text: '@${item.username}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          TextSpan(
                            text: '  ${item.action}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.date,
                      style: TextStyle(fontSize: 12.sp, color: subTextColor),
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
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 26.h),
                  Text(
                    item.timeAgo,
                    style: TextStyle(fontSize: 11.sp, color: subTextColor),
                  ),
                ],
              ),
            ],
          ),
          if (item.showActions) ...[
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Decline',
                    color: AppColors.darkGrey,
                    textColor: AppColors.white,
                    onTap: onDecline,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    color: AppColors.mehroon,
                    textColor: AppColors.white,
                    onTap: onAccept,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
