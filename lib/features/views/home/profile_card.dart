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
                           Expanded (child: _smallIcon(
                              onHeart,
                              user.isInterested
                                  ? "assets/svg_images/fiiled_like.svg"
                                  : "assets/svg_images/heart_unfill.svg",
                            ),),
                            Expanded(
                              child: _smallIcon(
                                onStar,
                                user.isFavorite
                                    ? "assets/svg_images/filled_star.svg"
                                    : "assets/svg_images/unfill_star.svg",
                                iconSize: user.isFavorite? 18:13.2,
                                padding: user.isFavorite?2:3.5
                              ),
                            ),
                            Expanded(
                              child: _smallIcon(
                                onDislike,
                                "assets/svg_images/block.svg",
                              ),
                            ),
                            Expanded(
                              child: _smallIcon(
                                onRequestSend,
                                "assets/svg_images/interested.svg",
                                padding: 2,
                                iconSize: 18
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

  Widget _smallIcon(VoidCallback? onTap, String imageStr,
      {double iconSize = 16, double padding = 3}) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child:Ink(
        decoration: const BoxDecoration(
          color: Color(0x33FFFFFF),
          shape: BoxShape.circle,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          splashColor: Colors.blue,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: SizedBox(
              height: iconSize + 4,
              width: iconSize + 4,
              child: Images(
                imageStr: imageStr,
                height: iconSize,
                width: iconSize,
              ),
            ),
          ),
        ),
      )
      // InkWell(
      //   splashColor: Colors.blue.withOpacity(0.3),
      //   highlightColor: Colors.blue.withOpacity(0.9),
      //   hoverColor: Colors.blue.withOpacity(0.95),
      //   customBorder: const CircleBorder(),
      //   onTap: onTap,
      //   child: Containers(
      //     alignment: Alignment.center,
      //     padding: EdgeInsets.all(padding),
      //     hexValue: 0x33FFFFFF, // Semi-transparent white background
      //     shape: BoxShape.circle,
      //     child: SizedBox(
      //       height: iconSize+4,
      //       width: iconSize+4,
      //       child: Images(imageStr: imageStr, height: iconSize, width:  iconSize),
      //     ),
      //   ),
      // ),
    );
  }
}
