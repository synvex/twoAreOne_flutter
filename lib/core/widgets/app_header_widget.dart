import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_icons.dart';

class AppHeaderWidget extends StatelessWidget {
  final String? title;

  final VoidCallback? onLeadingTap;
  final VoidCallback? onTrailingTap;

  final Widget? leadingIcon;
  final Widget? trailing;
  final Widget? titleWidget;

  final bool isLeading;
  final bool isTrailing;
  final bool isTitle;

  final TextStyle? titleStyle;
  const AppHeaderWidget({
    super.key,
    this.title,
    this.onLeadingTap,
    this.onTrailingTap,
    this.leadingIcon,
    this.trailing,
    this.titleWidget,
    this.titleStyle,
    this.isLeading = true,
    this.isTrailing = true,
    this.isTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 40;

    return Row(
      children: [
        /// Leading
        SizedBox(
          width: buttonSize.w,
          height: buttonSize.w,
          child: isLeading
              ? GestureDetector(
                  onTap:
                      onLeadingTap ??
                      () {
                        Navigator.pop(context);
                      },
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.transparent,
                    child: leadingIcon ?? SvgPicture.asset(AppIcons.backIcon),
                  ),
                )
              : const SizedBox(),
        ),
        /// Title
        Expanded(
          child: isTitle
              ? titleWidget ??
                    Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style:
                          titleStyle ??
                          GoogleFonts.roboto(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w500,
                          ),
                    )
              : const SizedBox(),
        ),

        /// Trailing
        SizedBox(
          width: buttonSize.w,
          height: buttonSize.w,
          child: isTrailing
              ? GestureDetector(
                  onTap: onTrailingTap,
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.transparent,
                    child: trailing ?? SvgPicture.asset(AppIcons.vert_more),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
