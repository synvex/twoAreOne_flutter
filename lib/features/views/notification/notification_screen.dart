import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/utils/skelton_util.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/notification_card.dart';
import 'package:two_are_one/data/viewmodels/notification_view_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<NotificationViewModel>(context, listen: false);
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    await _viewModel.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              AppHeaderWidget(
                isLeading: true,
                isTrailing: false,
                title: "Notification",
              ),

              SizedBox(height: 35.h),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.black,
                  backgroundColor: AppColors.background,
                  child: Consumer<NotificationViewModel>(
                    builder: (context, vm, child) {
                      if (vm.isLoading) {
                        return SkeletonEffect.chatList(itemCount: 8);
                      }

                      if (vm.notificationList.isEmpty) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: Text("No notifications found"),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: vm.notificationList.length,
                        itemBuilder: (context, index) {
                          final notification = vm.notificationList[index];

                          return NotificationCard(item: notification);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
