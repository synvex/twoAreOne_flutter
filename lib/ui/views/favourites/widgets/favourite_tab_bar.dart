import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/font.dart';
import '../../../viewmodels/favourite_view_model.dart';
import '../../../viewmodels/interested_view_model.dart';


/// Port of the RN tab pill row (`tabContainer` / `tab` / `activeTab` /
/// `tabText` / `activeTabText` styles).
class FavouriteTabBar extends StatelessWidget {
  final FavouriteTab activeTab;
  final ValueChanged<FavouriteTab> onTabSelected;
  const FavouriteTabBar({
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
        children: FavouriteTab.values
            .map((tab) => Expanded(child: _buildTab(tab)))
            .toList(),
      ),
    );
  }

  Widget _buildTab(FavouriteTab tab) {
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
