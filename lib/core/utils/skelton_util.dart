// skeleton_effect.dart
//
// Single static utility class for skeleton/shimmer loading UI in Flutter.
// Built to match:
//   1) Profile card grid (rounded photo card, name/age, match %, icon row)
//   2) Chat list tile (circle avatar, name, last message, timestamp)
//
// USAGE
// -----
//   isLoading
//     ? SkeletonEffect.profileGrid(itemCount: 6)
//     : ProfileGrid(items: data)
//
//   isLoading
//     ? SkeletonEffect.chatList(itemCount: 8)
//     : ChatList(items: chats)
//
//   // Single pieces, if you're composing your own layout:
//   SkeletonEffect.card()
//   SkeletonEffect.chatTile()
//   SkeletonEffect.box(width: 100, height: 12)
//   SkeletonEffect.circle(diameter: 48)
//
// Drop this file into lib/utils/skeleton_effect.dart

import 'package:flutter/material.dart';

class SkeletonEffect {
  SkeletonEffect._(); // no instances — pure static utility

  // Tweak these once, applies everywhere.
  static Color baseColor = const Color(0xFFE0E0E3);
  static Color highlightColor = const Color(0xFFF6F6F8);
  static Duration duration = const Duration(milliseconds: 1400);

  // -------------------------------------------------------------------------
  // SHIMMER WRAPPER
  // -------------------------------------------------------------------------

  /// Wraps [child] with an animated shimmer sweep. Use this if you're
  /// building a fully custom skeleton layout out of [box] / [circle].
  static Widget shimmer(Widget child, {bool enabled = true}) {
    return _Shimmer(
      enabled: enabled,
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  // -------------------------------------------------------------------------
  // PRIMITIVES
  // -------------------------------------------------------------------------

  /// A rectangular placeholder block (text line, image block, etc).
  static Widget box({
    double width = double.infinity,
    double height = 12,
    double radius = 6,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? baseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// A circular placeholder (avatar, icon dot, etc).
  static Widget circle({double diameter = 48, Color? color}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color ?? baseColor,
        shape: BoxShape.circle,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PROFILE CARD (matches Charlotte / Sophia / Isabella / Olivia grid)
  // -------------------------------------------------------------------------

  /// A single skeleton profile card: full-bleed photo block, name/age lines,
  /// and a row of 4 icon circles.
  static Widget card({double? width, double? height}) {
    return shimmer(
      AspectRatio(
        aspectRatio: 0.78,
        child: Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // Image Placeholder
                Positioned.fill(child: Container(color: baseColor)),

                // Online indicator
                Positioned(top: 15, right: 15, child: circle(diameter: 12)),

                // Bottom overlay
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 115,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: highlightColor.withOpacity(.25),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  box(width: 120, height: 18, radius: 4),
                                  const SizedBox(height: 8),
                                  box(width: 80, height: 11, radius: 4),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                box(width: 55, height: 14, radius: 4),
                                const SizedBox(height: 8),
                                box(width: 60, height: 11, radius: 4),
                              ],
                            ),
                          ],
                        ),

                        const Spacer(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            4,
                            (_) => Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: highlightColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Grid of skeleton [card]s — drop-in replacement while real profile
  /// grid data is loading.
  static Widget profileGrid({
    int itemCount = 4,
    int crossAxisCount = 2,
    double spacing = 14,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return GridView.builder(
      padding: padding,
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemBuilder: (context, index) => card(),
    );
  }

  // -------------------------------------------------------------------------
  // CHAT LIST TILE (matches Olivia / Kim / Keilla list)
  // -------------------------------------------------------------------------

  /// A single skeleton chat row: avatar circle, name line, message-preview
  /// line, timestamp line, and a trailing unread dot.
  static Widget chatTile({
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
  }) {
    return shimmer(
      Padding(
        padding: padding,
        child: Row(
          children: [
            circle(diameter: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: 100, height: 13, radius: 4),
                  const SizedBox(height: 8),
                  box(width: 160, height: 11, radius: 4),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                box(width: 36, height: 10, radius: 4),
                const SizedBox(height: 10),
                circle(diameter: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// List of skeleton [chatTile]s — drop-in replacement while real
  /// conversation list data is loading.
  static Widget chatList({int itemCount = 6, bool showDivider = true}) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => showDivider
          ? const Divider(height: 1, indent: 76)
          : const SizedBox.shrink(),
      itemBuilder: (context, index) => chatTile(),
    );
  }
}

// ---------------------------------------------------------------------------
// INTERNAL SHIMMER ANIMATION (private — accessed only via SkeletonEffect.shimmer)
// ---------------------------------------------------------------------------

class _Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;
  final bool enabled;

  const _Shimmer({
    required this.child,
    required this.duration,
    required this.baseColor,
    required this.highlightColor,
    required this.enabled,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double slide = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 - slide * 2, 0),
              end: Alignment(1 + slide * 2, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// EXAMPLE USAGE (delete or keep as reference)
// ---------------------------------------------------------------------------

class SkeletonDemoPage extends StatelessWidget {
  const SkeletonDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skeleton Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profile Grid'),
              Tab(text: 'Chat List'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: SkeletonEffect.profileGrid(itemCount: 6),
            ),
            SkeletonEffect.chatList(itemCount: 8),
          ],
        ),
      ),
    );
  }
}
