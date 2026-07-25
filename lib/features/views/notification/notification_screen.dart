import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/notification_card.dart';
import 'package:two_are_one/data/models/notification_items.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const List<NotificationItem> _todayItems = [
    NotificationItem(
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      username: 'kim',
      action: 'Favourite you',
      date: '26/06/2025',
      timeAgo: '25 min ago',
      isOnline: true,
    ),
    NotificationItem(
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      username: 'tanya',
      action: 'Interested you',
      date: '26/06/2025',
      timeAgo: '40 min ago',
    ),
    NotificationItem(
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      username: 'Fernando',
      action: 'Block you',
      date: '26/06/2025',
      timeAgo: '01 hr ago',
      isOnline: true,
    ),
  ];

  static const List<NotificationItem> _previousItems = [
    NotificationItem(
      avatarUrl: 'https://i.pravatar.cc/150?img=25',
      username: 'ema',
      action: 'Interested you',
      date: '25/06/2025',
      timeAgo: '21 hr ago',
    ),
    NotificationItem(
      avatarUrl: 'https://i.pravatar.cc/150?img=45',
      username: 'mei',
      action: 'Favourite you',
      date: '25/06/2025',
      timeAgo: '17 hr ago',
      showActions: true,
    ),
    NotificationItem(
      avatarUrl: 'https://i.pravatar.cc/150?img=48',
      username: 'elizabeth',
      action: 'Interested you',
      date: '23/06/2025',
      timeAgo: '3d ago',
    ),
    NotificationItem(
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      username: 'annie',
      action: 'viewed you',
      date: '22/06/2025',
      timeAgo: '4d ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ).copyWith(top: 8.h, bottom: 16.h),
                children: [
                  _SectionTitle(title: 'Today'),
                  SizedBox(height: 12.h),
                  ..._todayItems.map((item) => NotificationCard(item: item)),
                  SizedBox(height: 8.h),
                  _SectionTitle(title: 'Previous'),
                  SizedBox(height: 12.h),
                  ..._previousItems.map((item) => NotificationCard(item: item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.headerBackground,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              'Notification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
          _CircleIconButton(icon: Icons.more_vert, onTap: () {}),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36.w,
          height: 36.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border1, width: 1),
          ),
          child: Icon(icon, size: 20.sp, color: AppColors.primaryText),
        ),
      ),
    );
  }
}
