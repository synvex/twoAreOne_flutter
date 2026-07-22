import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
/// Port of the RN `SkeletonCard` (shimmering placeholder row) and its
/// `skeletonStyles`. Same 900ms opacity pulse (`0.35 -> 0.75`) driven by an
/// `AnimationController` instead of RN's `Animated.loop`.
class SkeletonUserCard extends StatefulWidget {
  const SkeletonUserCard({super.key});

  @override
  State<SkeletonUserCard> createState() => _SkeletonUserCardState();
}

class _SkeletonUserCardState extends State<SkeletonUserCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 0.75).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.skeletonCardBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.skeletonBase,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.skeletonBase,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            const SizedBox(width: 32),
            Container(
              width: 24,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.skeletonBase,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Port of `SkeletonFooter` - renders [AppConstants.skeletonCount] rows.
class SkeletonFooterList extends StatelessWidget {
  const SkeletonFooterList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        AppConstants.skeletonCount,
        (_) => const SkeletonUserCard(),
      ),
    );
  }
}
