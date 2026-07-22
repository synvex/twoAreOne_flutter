import 'package:flutter/material.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/font.dart';
import 'package:two_are_one/data/viewmodels/interested_view_model.dart';

class InterestedTabBar extends StatelessWidget {
  final InterestedTab activeTab;
  final ValueChanged<InterestedTab> onTabSelected;
  const InterestedTabBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 10,bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: InterestedTab.values
            .map((tab) => Expanded(child: _buildTab(tab)))
            .toList(),
      ),
    );
  }

  Widget _buildTab(InterestedTab tab) {
    final isActive = tab == activeTab;
    return GestureDetector(
      onTap: () => onTabSelected(tab),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.mehroon : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          tab.label,
          style: TextStyle(
            fontSize: 16,
            fontFamily: isActive ? AppFonts.poppinsMedium : AppFonts.poppinsRegular,
            color: isActive ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }
}
