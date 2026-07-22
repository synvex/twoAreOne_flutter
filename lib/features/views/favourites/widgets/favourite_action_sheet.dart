import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/widgets/image.dart';
import '../../../../data/viewmodels/favourite_view_model.dart';
import 'bottom_sheet_menu_item.dart';

class FavouriteActionSheet extends StatelessWidget {
  final VoidCallback onViewProfile;

  const FavouriteActionSheet({super.key, required this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouriteViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomSheetMenuItem(
                icon: const Images(imageStr: 'assets/svg_images/Profile/view_profile.svg'),
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
                label: 'Remove from Favourite',
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