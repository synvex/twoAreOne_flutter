import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_colors.dart';

import '../../../../core/utils/date_time_util.dart';

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String senderName;
  final String senderProfilePicture;
  final int time;

  const ChatBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.senderName,
    required this.senderProfilePicture,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isMe)
                ClipOval(
                  child: Image.network(
                    senderProfilePicture,
                    height: 24.h,
                    width: 24.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return CircleAvatar(
                        radius: 12.r,
                        backgroundColor: AppColors.grayColor,
                        child: Text(
                          senderName.trim().isNotEmpty
                              ? senderName.trim()[0].toUpperCase()
                              : "?",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.background,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .75,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isMe
                        ? [AppColors.mehroon, AppColors.gradientFirst]
                        : [AppColors.skeletonBase, AppColors.skeletonBase],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 4 : 18),
                    bottomRight: Radius.circular(isMe ? 18 : 4),
                  ),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.inriaSerif(
                    fontSize: 14.sp,
                    color: isMe ? AppColors.background : AppColors.black,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(
              right: isMe ? 0 : 8.w,
              left: isMe ? 34.w : 0,
            ),
            child: Text(
              DateTimeUtil.unixToLocalTime(time),
              style: GoogleFonts.inriaSerif(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
