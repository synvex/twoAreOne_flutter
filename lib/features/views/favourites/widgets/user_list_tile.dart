import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/font.dart';
//
// class FavUserListTile extends StatelessWidget {
//   // final FavouriteUserModel user;
//   final String? resolvedImageUrl;
//   final String initials;
//   final String displayName;
//   final VoidCallback onMenuPressed;
//
//   const FavUserListTile({
//     super.key,
//     // required this.user,
//     required this.resolvedImageUrl,
//     required this.initials,
//     required this.displayName,
//     required this.onMenuPressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF6F6F6),
//         borderRadius: BorderRadius.circular(100),
//         border: Border.all(color: const Color(0xFFF0F0F0)),
//       ),
//       child: Row(
//         children: [
//           _buildAvatar(),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               displayName,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontFamily: AppFonts.poppinsMedium,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.black,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           GestureDetector(
//             onTap: onMenuPressed,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: Text(
//                 '⋯',
//                 style: TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.menuGray,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAvatar() {
//     if (resolvedImageUrl != null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(25),
//         child: Image.network(
//           resolvedImageUrl!,
//           width: 50,
//           height: 50,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => _initialsAvatar(),
//         ),
//       );
//     }
//     return _initialsAvatar();
//   }
//   Widget _initialsAvatar() {
//     return Container(
//       width: 50,
//       height: 50,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: AppColors.darkPink,
//         shape: BoxShape.circle,
//       ),
//       child: Text(
//         initials,
//         style: const TextStyle(
//           fontSize: 14,
//           fontFamily: AppFonts.poppinsBold,
//           fontWeight: FontWeight.bold,
//           color: AppColors.white,
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/widgets/font.dart';

class FavUserListTile extends StatelessWidget {
  final String? resolvedImageUrl;
  final String initials;
  final String displayName;
  final VoidCallback onMenuPressed;

  const FavUserListTile({
    super.key,
    required this.resolvedImageUrl,
    required this.initials,
    required this.displayName,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: AppFonts.poppinsMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onMenuPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '⋯',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.menuGray,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (resolvedImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          resolvedImageUrl!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.darkPink,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: AppFonts.poppinsBold,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }
}