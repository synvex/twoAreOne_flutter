//
// import 'package:flutter/material.dart';
//
// import '../../core/texts.dart';
// import '../../models/user_match_model.dart';
//
// class ProfileCard extends StatelessWidget {
//   final FilterMatchModel user;
//   final VoidCallback? onStar;
//   final VoidCallback? onHeart;
//   final VoidCallback? onDislike;
//   final VoidCallback? onPress;
//   final VoidCallback? onChat;
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
//     this.onChat,
//     this.isStarLoading = false,
//     this.isHeartLoading = false,
//     this.isBlockLoading = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Logic to prevent the "uploads/" folder-only image crash
//     final String imageUrl = user.imagePath.trim();
//     final bool isValidUrl = imageUrl.isNotEmpty &&
//         imageUrl.startsWith('http') &&
//         imageUrl != "https://www.twoareone.love/uploads/";
//
//     return GestureDetector(
//       onTap: onPress,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20), // Matched Card 1 radius
//         child: Container(
//           height: 260, // Matched Card 1 height
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//           ),
//           child: Stack(
//             children: [
//               // 1. Background Image
//               Positioned.fill(
//                 child: isValidUrl
//                     ? Image.network(
//                   imageUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
//                 )
//                     : _buildPlaceholder(),
//               ),
//
//               // 2. Gradient Overlay (Matched Card 1 for better text readability)
//               Positioned.fill(
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colors: [Colors.black.withOpacity(0.8), Colors.transparent],
//                     ),
//                   ),
//                 ),
//               ),
//
//               // 3. Online Indicator (Keep this!)
//               Positioned(
//                 top: 12,
//                 right: 12,
//                 child: user.isOnline
//                     ? Container(
//                   width: 12, height: 12,
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                 )
//                     : const SizedBox.shrink(),
//               ),
//
//               // 4. Content (Name, Age, Icons)
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Top part: Match Percentage (Matched Card 1)
//                     const Spacer(),
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.8),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Texts(
//                           text: user.matchPercent, // e.g. "95%"
//                           size: 10,
//                           fontWeight: FontWeight.bold,
//                           colorHexValue: 0xFF000000,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//
//                     // Bottom part: User Info
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Texts(
//                             text: user.name,
//                             size: 18,
//                             colorHexValue: 0xFFFFFFFF,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Texts(
//                           text: user.age.toString(),
//                           size: 16,
//                           colorHexValue: 0xFFFFFFFF,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ],
//                     ),
//                     Texts(
//                       text: user.location,
//                       size: 12,
//                       colorHexValue: 0xFFE0E0E0,
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Action Icons (Matched Card 1 behavior)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _smallIcon(onHeart, user.isInterested ? Icons.favorite : Icons.favorite_border,
//                             user.isInterested ? const Color(0xFFDD276F) : Colors.white, isHeartLoading),
//
//                         _smallIcon(onStar, user.isFavorite ? Icons.star : Icons.star_border,
//                             user.isFavorite ? Colors.amber : Colors.white, isStarLoading),
//
//                         _smallIcon(onChat, Icons.chat_bubble_outline, Colors.white, false),
//
//                         _smallIcon(onDislike, Icons.block, Colors.redAccent, isBlockLoading),
//                       ],
//                     )
//                   ],
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
//     return Image.asset('assets/images/failed.png', fit: BoxFit.cover);
//   }
//
//   Widget _smallIcon(VoidCallback? onTap, IconData icon, Color color, bool isLoading) {
//     return GestureDetector(
//       onTap: isLoading ? null : onTap,
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: Colors.black26, // Semi-transparent circle like Card 1
//           shape: BoxShape.circle,
//         ),
//         child: isLoading
//             ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: color))
//             : Icon(icon, size: 18, color: color),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/models/user_match_model.dart';
import '../../core/texts.dart';
// class ProfileCard extends StatelessWidget {
//   final FilterMatchModel user;
//   final VoidCallback? onStar;
//   final VoidCallback? onHeart;
//   final VoidCallback? onDislike;
//   final VoidCallback? onPress;
//   final VoidCallback? onChat;
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
//     this.isBlockLoading = false, this.onChat,
//   });
//   @override
//   Widget build(BuildContext context) {
//     // ✅ FIX: Strict validation of the URL
//     final String imageUrl = user.imagePath.trim();
//     final bool isValidUrl = imageUrl.isNotEmpty &&
//         imageUrl.startsWith('http') &&
//         imageUrl != "https://www.twoareone.love/uploads/";
//     return GestureDetector(
//       onTap: onPress,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(30),
//         child: Stack(
//           children: [
//             // Background Image
//             Positioned.fill(
//               child: isValidUrl
//                   ? Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return const Center(child: CircularProgressIndicator(strokeWidth: 2));
//                 },
//               )
//                   : _buildPlaceholder(),
//             ),
//             Positioned(
//               top: 15,
//               right: 15,
//               child: user.isOnline
//                   ? Containers(
//                 wWidth: 12, wHeight: 12,
//                 hexValue: 0xFF2E7D32,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 2),
//               )
//                   : const SizedBox.shrink(),
//             ),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: ClipRRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     color: Colors.black.withOpacity(0.03), // Darker for better text visibility
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Texts(
//                                 text: user.name,
//                                 size: 15,
//                                 colorHexValue: 0xFFFFFFFF,
//                                 fontWeight: FontWeight.bold,
//                                 // overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Texts(
//                               text: "Age ${user.age}",
//                               size: 11,
//                               colorHexValue: 0xFFFFFFFF,
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Texts(
//                                 text: user.location,
//                                 size: 9,
//                                 colorHexValue: 0xFFFFFFFF,
//                                 // overflow: TextOverflow.ellipsis,
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
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             // Heart / Interested Icon
//                             _smallIcon(
//                               onHeart,
//                               user.isInterested ? Icons.favorite : Icons.favorite_border,
//                               user.isInterested ? const Color(0xFFDD276F) : Colors.black,
//                               isHeartLoading,
//                             ),
//                             // Star / Favorite Icon
//                             _smallIcon(
//                               onStar,
//                               user.isFavorite ? Icons.star : Icons.star_border,
//                               user.isFavorite ? Colors.amber : Colors.black,
//                               isStarLoading,
//                             ),
//                             // Person / Chat Icon
//                             _smallIcon(onChat, Icons.person_off_outlined, Colors.black, false),
//                             // Shield / Block Icon
//                             _smallIcon(
//                               onDislike,
//                               Icons.block,
//                               Colors.redAccent,
//                               isBlockLoading,
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildPlaceholder() {
//     return Images(
//       imageStr: 'assets/images/failed.png',
//     );
//   }
//   Widget _smallIcon(VoidCallback? onTap, IconData icon, Color color, bool isLoading) {
//     return GestureDetector(
//       onTap: isLoading ? null : onTap,
//       child: Containers(
//         padding: const EdgeInsets.all(5),
//         hexValue: 0x33FFFFFF, // Semi-transparent background
//         radius: BorderRadius.circular(30),
//         child: isLoading
//             ? SizedBox(
//           width: 14,
//           height: 14,
//           child: CircularProgressIndicator(strokeWidth: 2, color: color),
//         )
//             : MyIcons(iconData: icon, size: 14, color: color),
//       ),
//     );
//   }
// }

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
//   Widget _buildGradientIcon(String imgStr, bool isActive, {double size = 16}) {
//     if (!isActive) {
//       // White outline for inactive state
//       return Images(imageStr: imgStr, height: size, width: size, color: Colors.white);
//     }
//
//     return ShaderMask(
//       shaderCallback: (bounds) => const LinearGradient(
//         colors: [Color(0xFF477CB6), Color(0xFF8B4DAB), Color(0xFFDD276F)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ).createShader(bounds),
//       child: Images(imageStr: imgStr, height: size, width: size, color: Colors.white),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = user.imagePath.trim();
//     final bool isValidUrl = imageUrl.isNotEmpty && imageUrl.startsWith('http');
//
//     return GestureDetector(
//       onTap: onPress,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(30),
//         child: Stack(
//           children: [
//             // Background Image
//             Positioned.fill(
//               child: isValidUrl
//                   ? Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 errorBuilder: (c, e, s) => _buildPlaceholder(),
//               )
//                   : _buildPlaceholder(),
//             ),
//
//             // Online Indicator
//             Positioned(
//               top: 15,
//               right: 15,
//               child: user.isOnline
//                   ? Containers(
//                 wWidth: 12,
//                 wHeight: 12,
//                 hexValue: 0xFF2E7D32,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 2),
//               )
//                   : const SizedBox.shrink(),
//             ),
//
//             // Bottom Info Overlay
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 color: Colors.black.withOpacity(0.4),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Name and Age
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Texts(
//                               text: user.name,
//                               size: 15,
//                               colorHexValue: 0xFFFFFFFF,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         Texts(text: "Age ${user.age}", size: 11, colorHexValue: 0xFFFFFFFF),
//                       ],
//                     ),
//                     // Location and Match %
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Texts(text: user.location, size: 9, colorHexValue: 0xFFFFFFFF),
//                         ),
//                         Texts(text: user.matchPercent, size: 9, colorHexValue: 0xFFFFFFFF),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     // Action Row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         // Heart (Interested)
//                         _smallIcon(
//                           onTap: onHeart,
//                           isLoading: isHeartLoading,
//                           icon: _buildGradientIcon(
//                             user.isInterested
//                                 ? "assets/svg_images/heart.svg"
//                                 : "assets/svg_images/unfill_heart.svg",
//                             user.isInterested,
//                             size: 20,
//                           ),
//                         ),
//                         // Star (Favorite)
//                         _smallIcon(
//                           onTap: onStar,
//                           isLoading: isStarLoading,
//                           icon: _buildGradientIcon(
//                             user.isFavorite
//                                 ? "assets/svg_images/star.svg"
//                                 : "assets/svg_images/unfill_star.svg",
//                             user.isFavorite,
//                           ),
//                         ),
//                         // Block
//                         _smallIcon(
//                           onTap: onDislike,
//                           isLoading: isBlockLoading,
//                           icon: const Images(
//                             imageStr: "assets/svg_images/block.svg",
//                             width: 16,
//                             height: 16,
//                             color: Colors.redAccent,
//                           ),
//                         ),
//                         // Request / Chat
//                         _smallIcon(
//                           onTap: onRequestSend,
//                           isLoading: false,
//                           icon: const Images(
//                             imageStr: "assets/svg_images/chat.svg",
//                             width: 16,
//                             height: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceholder() => Images(imageStr: 'assets/images/failed.png');
//
//   Widget _smallIcon({
//     required VoidCallback? onTap,
//     required bool isLoading,
//     required Widget icon,
//   }) {
//     return GestureDetector(
//       // Disable taps while loading, but don't show the spinner
//       onTap: isLoading ? null : onTap,
//       child: Containers(
//         padding: const EdgeInsets.all(6),
//         hexValue: 0x33FFFFFF, // Semi-transparent circle
//         radius: BorderRadius.circular(30),
//         child: icon, // Always show icon, logic handles the SVG switch
//       ),
//     );
//   }
// }

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

  // Helper to apply the ShaderMask Gradient
  Widget _buildGradientIcon(String imgStr, bool isActive, {Color fallbackColor = Colors.white}) {
    if (!isActive) {
      return Images(
          imageStr: imgStr,height: 16, width:  16,
          color: fallbackColor );
    }

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF477CB6),
          Color(0xFF8B4DAB),
          Color(0xFFDD276F),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: SizedBox(
          height: 16,width: 16,
          child: Images(
              imageStr: imgStr,
              color: Colors.white)), // Must be white for ShaderMask
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = user.imagePath.trim();
    final bool isValidUrl = imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        imageUrl != "https://www.twoareone.love/uploads/";

    return GestureDetector(
      onTap: onPress,
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
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
                wWidth: 12, wHeight: 12,
                hexValue: 0xFF2E7D32,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              )
                  : const SizedBox.shrink(),
            ),
            // Bottom Info & Icons
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: ClipRRect(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black.withOpacity(0.3), // Increased opacity for readability
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Age Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Texts(text: user.name, size: 15, colorHexValue: 0xFFFFFFFF, fontWeight: FontWeight.bold)),
                          Texts(text: "Age ${user.age}", size: 11, colorHexValue: 0xFFFFFFFF),
                        ],
                      ),
                      // Location and Match Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Texts(text: user.location, size: 9, colorHexValue: 0xFFFFFFFF)),
                          Texts(text: user.matchPercent, size: 9, colorHexValue: 0xFFFFFFFF),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Action Icons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // 1. Heart (Interested) - Toggle between filled and border
                          _smallIcon(
                            onHeart,
                            Images(imageStr:user.isInterested ? "assets/svg_images/fiiled_like.svg":
                                "assets/svg_images/heart_unfill.svg",),
                            _buildGradientIcon(
                                user.isInterested ?
                                "assets/svg_images/fiiled_like.svg":
                                "assets/svg_images/heart_unfill.svg",
                                user.isInterested
                            ),
                          ),
                          // 2. Star (Favorite) - Toggle between filled and border
                _smallIcon(
                onStar,
                Images(imageStr:user.isFavorite ? "assets/svg_images/filled_star.svg" :
                    "assets/svg_images/unfill_star.svg",
                    width: 16, height: 16),
                            _buildGradientIcon(
                                user.isFavorite ? "assets/svg_images/filled_star.svg" :
                                "assets/svg_images/unfill_star.svg",
                                user.isFavorite
                            ),
                          ),
                          // 3.  Block
                    _smallIcon(
                    onDislike,
                    Images(
                        imageStr: user.isDislike ? "assets/svg_images/block.svg" :
                        "assets/svg_images/block.svg", width: 16, height: 16),
                    _buildGradientIcon(user.isDislike ? "assets/svg_images/block.svg" :
    "assets/svg_images/block.svg",
    false, fallbackColor: Colors.redAccent),
                    ),
                          //Friend request send
                    _smallIcon(onRequestSend,
                        Images(imageStr: "assets/svg_images/interested.svg",),
                    _buildGradientIcon(user.isInterested ?
                    "assets/svg_images/interested": "assets/svg_images/interested.svg",
                        false,fallbackColor: Colors.redAccent )
                    // _buildGradientIcon(Icons.chat_bubble_outline, false)
                    ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Images(imageStr: 'assets/images/failed.png');
  }

  // Simplified _smallIcon without the CircularProgressIndicator
  Widget _smallIcon(VoidCallback? onTap, Images iconWidget, Widget buildGradientIcon) {
    return GestureDetector(
      onTap: onTap,
      child: Containers(
        padding: const EdgeInsets.all(6),
        hexValue: 0x33FFFFFF, // Semi-transparent white background
        radius: BorderRadius.circular(30),
        child: SizedBox(height: 16,width: 16, child: iconWidget),
      ),
    );
  }
}