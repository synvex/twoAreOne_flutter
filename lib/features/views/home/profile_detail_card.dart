import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/placeholder.dart';

class ProfileDetailCard extends StatelessWidget {
  final String imageUrl;
  final bool blocked;
  final VoidCallback? onPress;
  final VoidCallback? onLike;
  final VoidCallback? onStar;
  final VoidCallback? onDislike;
  final VoidCallback? onChat;
  final bool isFavorite;
  final bool isInterested;
  final bool heartLoading;
  final bool starLoading;
  final bool blockLoading;

  const ProfileDetailCard({
    super.key,
    required this.imageUrl,
    this.blocked = false,
    this.onPress,
    this.onLike,
    this.onStar,
    this.onDislike,
    this.onChat,
    this.isFavorite = false,
    this.isInterested = false,
    this.heartLoading = false,
    this.starLoading = false,
    this.blockLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isValidUrl = imageUrl.trim().isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.endsWith('/uploads/');

    return GestureDetector(
      onTap: onPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              isValidUrl
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const PlaceholderImage(height: 180, width: 140, size: 22),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              )
                  : const PlaceholderImage(height: 180, width: 140, size: 22),

              // Bottom frosted-glass action bar — hidden entirely when the
              // profile is blocked (RN: `{!blocked && <View style={styles.overlay}>`).
              if (!blocked)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 82,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        color: Colors.white.withOpacity(0.18),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(width: 50,),
                            // 1. Heart (Interested) — same asset pair as ProfileCard
                            _ActionBumpIcon(
                              loading: heartLoading,
                              onTap: onLike,
                              child: Images(
                                imageStr: isInterested
                                    ? "assets/svg_images/fiiled_like.svg"
                                    : "assets/svg_images/heart_unfill.svg",
                                height: 30,
                                width: 30,
                              ),
                            ),
                            // 2. Star (Favorite) — same asset pair as ProfileCard
                            _ActionBumpIcon(
                              loading: starLoading,
                              onTap: onStar,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Images(
                                  imageStr: isFavorite
                                      ? "assets/svg_images/filled_star.svg"
                                      : "assets/svg_images/unfill_star.svg",
                                  // height: 28,
                                  // width: 30,
                                ),
                              ),
                            ),
                            // 3. Block — same asset as ProfileCard
                            _ActionBumpIcon(
                              loading: blockLoading,
                              onTap: onDislike,
                              delayBeforeCallback: const Duration(milliseconds: 300),
                              child: const Images(
                                imageStr: "assets/svg_images/block.svg",
                                height: 30,
                                width: 30,
                              ),
                            ),
                            // 4. Chat / request-send — same asset ProfileCard uses
                            // for its "friend request send" icon.
                            _ActionBumpIcon(
                              onTap: onChat,
                              child: const Images(
                                imageStr: "assets/svg_images/interested.svg",
                                height: 30,
                                width: 30,
                              ),
                            ),
                            SizedBox(width: 50,),
                          ],
                        ),
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
}

class _ActionBumpIcon extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final bool loading;
  final Duration delayBeforeCallback;

  const _ActionBumpIcon({
    required this.onTap,
    required this.child,
    this.loading = false,
    this.delayBeforeCallback = Duration.zero,
  });

  @override
  State<_ActionBumpIcon> createState() => _ActionBumpIconState();
}

class _ActionBumpIconState extends State<_ActionBumpIcon> {
  double _scale = 1;

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;
    setState(() => _scale = 1.3);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _scale = 1);

    if (widget.delayBeforeCallback > Duration.zero) {
      await Future.delayed(widget.delayBeforeCallback);
      if (!mounted) return;
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Center(
          child: widget.loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 120),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

