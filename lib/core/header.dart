import 'package:flutter/material.dart';
import 'package:two_are_one/core/image.dart';
import 'app_colors.dart';
import 'back_button.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final Widget? trailing;
  final Widget? leadingIcon;

  const AppHeader({
    super.key,
    required this.title,
    required this.onBackPressed,
    this.trailing,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16,top: 25,bottom: 18),
      margin: const EdgeInsets.symmetric(vertical: 16,),//
      decoration: BoxDecoration(
        color: AppColors.headerBackground,
        border: Border(
          bottom: BorderSide(color: Color(0xFF000000).withOpacity(0.8), width: 2),
        ),
      ),
      child: Row(
        children: [
         Back_Button(onTap: onBackPressed),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 40,
            child: trailing,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}