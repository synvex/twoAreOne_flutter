// import 'package:flutter/material.dart';
// import 'package:two_are_one/core/widgets/image.dart';
// import 'package:two_are_one/core/widgets/placeholder.dart';
// import 'package:two_are_one/core/widgets/texts.dart';
// import 'package:two_are_one/data/models/user_match_model.dart';
// import 'package:two_are_one/core/widgets/containers.dart';
//
// class ProfileCard extends StatelessWidget {
//   final FilterMatchModel user;
//   final VoidCallback? onStar;
//   final VoidCallback? onHeart;
//   final VoidCallback? onDislike;
//   final VoidCallback? onRequestSend;
//   final VoidCallback? onPress;
//   final bool isStarLoading;
//   final bool isHeartLoading;
//   final bool isBlockLoading;
//
//   const ProfileCard({
//     super.key,
//     required this.user,
//     this.onStar,
//     this.onHeart,
//     this.onDislike,
//     this.onPress,
//     this.isStarLoading = false,
//     this.isHeartLoading = false,
//     this.isBlockLoading = false,
//     this.onRequestSend,
//   });
//
//   Widget _buildGradientIcon(
//     String imgStr,
//     bool isActive, {
//     Color fallbackColor = Colors.white,
//   }) {
//     if (!isActive) {
//       return Images(
//         imageStr: imgStr,
//         height: 16,
//         width: 16,
//         color: fallbackColor,
//       );
//     }
//
//     return ShaderMask(
//       shaderCallback: (bounds) => const LinearGradient(
//         colors: [Color(0xFF477CB6), Color(0xFF8B4DAB), Color(0xFFDD276F)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ).createShader(bounds),
//       child: SizedBox(
//         height: 16,
//         width: 16,
//         child: Images(imageStr: imgStr, color: Colors.white),
//       ), // Must be white for ShaderMask
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = user.imagePath.trim();
//     final bool isValidUrl =
//         imageUrl.isNotEmpty &&
//         imageUrl.startsWith('http') &&
//         imageUrl != "https://www.twoareone.love/uploads/";
//
//     return GestureDetector(
//       onTap: onPress,
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: Stack(
//             children: [
//               // Background Image
//               Positioned.fill(
//                 child: isValidUrl
//                     ? Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             _buildPlaceholder(),
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return const Center(
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           );
//                         },
//                       )
//                     : _buildPlaceholder(),
//               ),
//               // Online Indicator
//               Positioned(
//                 top: 15,
//                 right: 15,
//                 child: user.isOnline
//                     ? Containers(
//                         wWidth: 12,
//                         wHeight: 12,
//                         hexValue: 0xFF2E7D32,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white, width: 2),
//                       )
//                     : const SizedBox.shrink(),
//               ),
//               // Bottom Info & Icons
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: ClipRRect(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     color: Colors.black.withValues(
//                       alpha: 0.3,
//                     ), // Increased opacity for readability
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Name and Age Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Text(
//                                 user.name,
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   overflow: TextOverflow.ellipsis,
//                                   color: Color(0xFFFFFFFF),
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             Texts(
//                               text: "Age ${user.age}",
//                               size: 11,
//                               colorHexValue: 0xFFFFFFFF,
//                             ),
//                           ],
//                         ),
//                         // Location and Match Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Texts(
//                                 text: user.location,
//                                 size: 9,
//                                 colorHexValue: 0xFFFFFFFF,
//                               ),
//                             ),
//                             Texts(
//                               text: user.matchPercent,
//                               size: 9,
//                               colorHexValue: 0xFFFFFFFF,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         // Action Icons Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             // 1. Heart (Interested) - Toggle between filled and border
//                             _smallIcon(
//                               onHeart,
//                               Images(
//                                 imageStr: user.isInterested
//                                     ? "assets/svg_images/fiiled_like.svg"
//                                     : "assets/svg_images/heart_unfill.svg",
//                               ),
//                               _buildGradientIcon(
//                                 user.isInterested
//                                     ? "assets/svg_images/fiiled_like.svg"
//                                     : "assets/svg_images/heart_unfill.svg",
//                                 user.isInterested,
//                               ),
//                             ),
//                             // 2. Star (Favorite) - Toggle between filled and border
//                             _smallIcon(
//                               onStar,
//                               Images(
//                                 imageStr: user.isFavorite
//                                     ? "assets/svg_images/filled_star.svg"
//                                     : "assets/svg_images/unfill_star.svg",
//                                 width: 16,
//                                 height: 16,
//                               ),
//                               _buildGradientIcon(
//                                 user.isFavorite
//                                     ? "assets/svg_images/filled_star.svg"
//                                     : "assets/svg_images/unfill_star.svg",
//                                 user.isFavorite,
//                               ),
//                             ),
//                             // 3.  Block
//                             _smallIcon(
//                               onDislike,
//                               Images(
//                                 imageStr: user.isDislike
//                                     ? "assets/svg_images/block.svg"
//                                     : "assets/svg_images/block.svg",
//                                 width: 16,
//                                 height: 16,
//                               ),
//                               _buildGradientIcon(
//                                 user.isDislike
//                                     ? "assets/svg_images/block.svg"
//                                     : "assets/svg_images/block.svg",
//                                 false,
//                                 fallbackColor: Colors.redAccent,
//                               ),
//                             ),
//                             //Friend request send
//                             _smallIcon(
//                               onRequestSend,
//                               Images(
//                                 imageStr: "assets/svg_images/interested.svg",
//                               ),
//                               _buildGradientIcon(
//                                 user.isInterested
//                                     ? "assets/svg_images/interested"
//                                     : "assets/svg_images/interested.svg",
//                                 false,
//                                 fallbackColor: Colors.redAccent,
//                               ),
//                               // _buildGradientIcon(Icons.chat_bubble_outline, false)
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceholder() {
//     return PlaceholderImage(height: 135, width: 140, size: 22);
//   }
//
//   Widget _smallIcon(
//     VoidCallback? onTap,
//     Images iconWidget,
//     Widget buildGradientIcon,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Containers(
//         padding: const EdgeInsets.all(4),
//         hexValue: 0x33FFFFFF, // Semi-transparent white background
//         radius: BorderRadius.circular(30),
//         child: SizedBox(height: 20, width: 20, child: iconWidget),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/placeholder.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/models/user_match_model.dart';
import 'package:two_are_one/core/widgets/containers.dart';

class ProfileCard extends StatelessWidget {
  final FilterMatchModel user;
  final VoidCallback? onStar;
  final VoidCallback? onHeart;
  final VoidCallback? onDislike;
  final VoidCallback? onRequestSend;
  final VoidCallback? onPress;
  final bool isStarLoading;
  final bool isHeartLoading;
  final bool isBlockLoading;

  const ProfileCard({
    super.key,
    required this.user,
    this.onStar,
    this.onHeart,
    this.onDislike,
    this.onPress,
    this.isStarLoading = false,
    this.isHeartLoading = false,
    this.isBlockLoading = false,
    this.onRequestSend,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = user.imagePath.trim();
    final bool isValidUrl =
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        imageUrl != "https://www.twoareone.love/uploads/";

    return GestureDetector(
      onTap: onPress,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: isValidUrl
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      )
                    : _buildPlaceholder(),
              ),
              // Online Indicator
              Positioned(
                top: 15,
                right: 15,
                child: user.isOnline
                    ? Containers(
                        wWidth: 12,
                        wHeight: 12,
                        hexValue: 0xFF2E7D32,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      )
                    : const SizedBox.shrink(),
              ),
              // Bottom Info & Icons
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Age Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  overflow: TextOverflow.ellipsis,
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Texts(
                              text: "Age ${user.age}",
                              size: 11,
                              colorHexValue: 0xFFFFFFFF,
                            ),
                          ],
                        ),
                        // Location and Match Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Texts(
                                text: user.location,
                                size: 9,
                                colorHexValue: 0xFFFFFFFF,
                              ),
                            ),
                            Texts(
                              text: user.matchPercent,
                              size: 9,
                              colorHexValue: 0xFFFFFFFF,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Action Icons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // 1. Heart (Interested) -> calls onHeart (home screen: _handleInterest)
                            Expanded(
                              child: _smallIcon(
                                onHeart,
                                user.isInterested
                                    ? "assets/svg_images/fiiled_like.svg"
                                    : "assets/svg_images/heart_unfill.svg",
                              ),
                            ),
                            // 2. Star (Favorite) -> calls onStar (home screen: _handleFavorite)
                            Expanded(
                              child: _smallIcon(
                                onStar,
                                user.isFavorite
                                    ? "assets/svg_images/filled_star.svg"
                                    : "assets/svg_images/unfill_star.svg",
                                iconSize: user.isFavorite ? 17 : 12,
                                padding: user.isFavorite ? 3 : 4,
                              ),
                            ),
                            // 3. Block -> calls onDislike (home screen: _handleBlock)
                            Expanded(
                              child: _smallIcon(
                                onDislike,
                                "assets/svg_images/block.svg",
                              ),
                            ),
                            // 4. Friend request send -> calls onRequestSend (home screen: _handleSilentChat)
                            Expanded(
                              child: _smallIcon(
                                onRequestSend,
                                "assets/svg_images/interested.svg",
                                padding: 2,
                                iconSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return PlaceholderImage(height: 135, width: 140, size: 22);
  }

  Widget _smallIcon(
    VoidCallback? onTap,
    String imageStr, {
    double iconSize = 16,
    double padding = 3,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Containers(
        alignment: Alignment.center,
        padding: EdgeInsets.all(padding),
        hexValue: 0x33FFFFFF, // Semi-transparent white background
        shape: BoxShape.circle,
        child: SizedBox(
          height: iconSize + 4,
          width: iconSize + 4,
          child: Images(imageStr: imageStr, height: iconSize, width: iconSize),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:two_are_one/core/widgets/image.dart';
// import 'package:two_are_one/core/widgets/placeholder.dart';
// import 'package:two_are_one/core/widgets/texts.dart';
// import 'package:two_are_one/data/models/user_match_model.dart';
// import 'package:two_are_one/core/widgets/containers.dart';
//
// class ProfileCard extends StatelessWidget {
//   final FilterMatchModel user;
//   final VoidCallback? onStar;
//   final VoidCallback? onHeart;
//   final VoidCallback? onDislike;
//   final VoidCallback? onRequestSend;
//   final VoidCallback? onPress;
//   final bool isStarLoading;
//   final bool isHeartLoading;
//   final bool isBlockLoading;
//
//   const ProfileCard({
//     super.key,
//     required this.user,
//     this.onStar,
//     this.onHeart,
//     this.onDislike,
//     this.onPress,
//     this.isStarLoading = false,
//     this.isHeartLoading = false,
//     this.isBlockLoading = false,
//     this.onRequestSend,
//   });
//
//   // Helper to apply the ShaderMask Gradient
//   // Widget _buildGradientIcon(
//   //   String imgStr,
//   //   bool isActive, {
//   //   Color fallbackColor = Colors.white,
//   // }) {
//   //   if (!isActive) {
//   //     return Images(
//   //       imageStr: imgStr,
//   //       height: 16,
//   //       width: 16,
//   //       color: fallbackColor,
//   //     );
//   //   }
//   //
//   //   return ShaderMask(
//   //     shaderCallback: (bounds) => const LinearGradient(
//   //       colors: [Color(0xFF477CB6), Color(0xFF8B4DAB), Color(0xFFDD276F)],
//   //       begin: Alignment.topLeft,
//   //       end: Alignment.bottomRight,
//   //     ).createShader(bounds),
//   //     child: SizedBox(
//   //       height: 14,
//   //       width: 16,
//   //       child: Images(imageStr: imgStr, color: Colors.white),
//   //     ), // Must be white for ShaderMask
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = user.imagePath.trim();
//     final bool isValidUrl =
//         imageUrl.isNotEmpty &&
//             imageUrl.startsWith('http') &&
//             imageUrl != "https://www.twoareone.love/uploads/";
//
//     return GestureDetector(
//       onTap: onPress,
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: Stack(
//             children: [
//               // Background Image
//               Positioned.fill(
//                 child: isValidUrl
//                     ? Image.network(
//                   imageUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) =>
//                       _buildPlaceholder(),
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return const Center(
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     );
//                   },
//                 )
//                     : _buildPlaceholder(),
//               ),
//               // Online Indicator
//               Positioned(
//                 top: 15,
//                 right: 15,
//                 child: user.isOnline
//                     ? Containers(
//                   wWidth: 12,
//                   wHeight: 12,
//                   hexValue: 0xFF2E7D32,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 2),
//                 )
//                     : const SizedBox.shrink(),
//               ),
//               // Bottom Info & Icons
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: ClipRRect(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     color: Colors.black.withValues(
//                       alpha: 0.3,
//                     ), // Increased opacity for readability
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Name and Age Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Text(
//                                 user.name,
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   overflow: TextOverflow.ellipsis,
//                                   color: Color(0xFFFFFFFF),
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             Texts(
//                               text: "Age ${user.age}",
//                               size: 11,
//                               colorHexValue: 0xFFFFFFFF,
//                             ),
//                           ],
//                         ),
//                         // Location and Match Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Texts(
//                                 text: user.location,
//                                 size: 9,
//                                 colorHexValue: 0xFFFFFFFF,
//                               ),
//                             ),
//                             Texts(
//                               text: user.matchPercent,
//                               size: 9,
//                               colorHexValue: 0xFFFFFFFF,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         // Action Icons Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             // 1. Heart (Interested) - Toggle between filled and border
//                             CircleAvatar(radius: 13.r,
//                               backgroundColor: Colors.white,
//                               child: Center(
//                                 child: SvgPicture.asset(user.isInterested
//                                     ? "assets/svg_images/fiiled_like.svg"
//                                     : "assets/svg_images/heart_unfill.svg",
//                                 ),
//                               ),
//                             ),
//                             CircleAvatar(radius: 13.r,
//                               backgroundColor: Colors.white,
//                               child: Center(
//                                 child: SvgPicture.asset(user.isFavorite
//                                     ? "assets/svg_images/filled_star.svg"
//                                     : "assets/svg_images/unfill_star.svg",
//                                 ),
//                               ),
//                             ),
//                             CircleAvatar(radius: 13.r,
//                               backgroundColor: Colors.white,
//                               child: Center(
//                                 child: SvgPicture.asset(user.isDislike
//                                     ? "assets/svg_images/block.svg"
//                                     : "assets/svg_images/block.svg",
//                                 ),
//                               ),
//                             ),
//                             CircleAvatar(radius: 13.r,
//                               backgroundColor: Colors.white,
//                               child: Center(
//                                 child: SvgPicture.asset(user.isInterested
//                                     ? "assets/svg_images/interested"
//                                     : "assets/svg_images/interested.svg",
//                                 ),
//                               ),
//                             ),
//                             // _smallIcon(
//                             //   onHeart,
//                             //   Images(
//                             //     imageStr: user.isInterested
//                             //         ? "assets/svg_images/fiiled_like.svg"
//                             //         : "assets/svg_images/heart_unfill.svg",
//                             //   ),
//                             //   // _buildGradientIcon(
//                             //   //   user.isInterested
//                             //   //       ? "assets/svg_images/fiiled_like.svg"
//                             //   //       : "assets/svg_images/heart_unfill.svg",
//                             //   //   user.isInterested,
//                             //   // ),
//                             // ),
//                             // // 2. Star (Favorite) - Toggle between filled and border
//                             // _smallIcon(
//                             //   onStar,
//                             //   Images(
//                             //     imageStr: user.isFavorite
//                             //         ? "assets/svg_images/filled_star.svg"
//                             //         : "assets/svg_images/unfill_star.svg",
//                             //     width: 16,
//                             //     height: 16,
//                             //   ),
//                             //   _buildGradientIcon(
//                             //     user.isFavorite
//                             //         ? "assets/svg_images/filled_star.svg"
//                             //         : "assets/svg_images/unfill_star.svg",
//                             //     user.isFavorite,
//                             //   ),
//                             // ),
//                             // // 3.  Block
//                             // _smallIcon(
//                             //   onDislike,
//                             //   Images(
//                             //     imageStr: user.isDislike
//                             //         ? "assets/svg_images/block.svg"
//                             //         : "assets/svg_images/block.svg",
//                             //     width: 16,
//                             //     height: 16,
//                             //   ),
//                             //   _buildGradientIcon(
//                             //     user.isDislike
//                             //         ? "assets/svg_images/block.svg"
//                             //         : "assets/svg_images/block.svg",
//                             //     false,
//                             //     fallbackColor: Colors.redAccent,
//                             //   ),
//                             // ),
//                             // //Friend request send
//                             // _smallIcon(
//                             //   onRequestSend,
//                             //   Images(
//                             //     imageStr: "assets/svg_images/interested.svg",
//                             //   ),
//                             //   _buildGradientIcon(
//                             //     user.isInterested
//                             //         ? "assets/svg_images/interested"
//                             //         : "assets/svg_images/interested.svg",
//                             //     false,
//                             //     fallbackColor: Colors.redAccent,
//                             //   ),
//                             // _buildGradientIcon(Icons.chat_bubble_outline, false)
//                             // ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceholder() {
//     return PlaceholderImage(height: 135, width: 140, size: 22);
//   }
//
//   Widget _smallIcon(
//       VoidCallback? onTap,
//       Images iconWidget,
//       Widget buildGradientIcon,
//       ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Containers(
//         padding: const EdgeInsets.all(4),
//         hexValue: 0x33FFFFFF, // Semi-transparent white background
//         radius: BorderRadius.circular(30),
//         child: SizedBox(height: 20, width: 20, child: iconWidget),
//       ),
//     );
//   }
// }
