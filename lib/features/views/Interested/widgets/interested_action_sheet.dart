import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/constants/app_icons.dart';
import '../../../../data/viewmodels/interested_view_model.dart';
import 'bottom_sheet_menu_item.dart';

class InterestedActionSheet extends StatelessWidget {
  final VoidCallback onViewProfile;

  const InterestedActionSheet({super.key, required this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    return Consumer<InterestedViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomSheetMenuItem(
                icon: SvgPicture.asset(AppIcons.profileIcon),
                label: 'View Profile',
                onPressed: onViewProfile,
              ),
              const SizedBox(height: 10),
              BottomSheetMenuItem(
                icon: const Icon(Icons.block, size: 24),
                label: 'Block Profile',
                isLoading: vm.blockUserLoading,
                onPressed: vm.blockSelectedUser,
              ),
              const SizedBox(height: 10),
              BottomSheetMenuItem(
                icon: const Icon(Icons.close, size: 24),
                label: 'Remove from Interested',
                isLoading: vm.removeLoading,
                onPressed: vm.removeSelected,
              ),
            ],
          ),
        );
      },
    );
  }
}
