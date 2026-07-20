import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/interested_view_model.dart';
import 'bottom_sheet_menu_item.dart';

/// Port of the `<View style={styles.menuContainer}>` block rendered inside
/// `CustomBottomSheet` - the three actions: View Profile / Block Profile /
/// Remove from Interested.
///
/// Icons: swap the placeholder `Icon(...)` widgets below for
/// `SvgPicture.asset('assets/icons/viewProfile.svg')` etc. (flutter_svg)
/// once you've copied over `blockProfile.svg`, `remove.svg` and
/// `viewProfile.svg` into `assets/icons/`.
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
                icon: const Icon(Icons.person_outline, size: 24),
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
