import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/back_button.dart';
import 'package:two_are_one/data/services/interested_services.dart';
import 'package:two_are_one/features/views/Interested/widgets/interested_action_sheet.dart';
import 'package:two_are_one/features/views/Interested/widgets/interested_tab_bar.dart';
import 'package:two_are_one/features/views/Interested/widgets/skeleton_user_card.dart';
import 'package:two_are_one/features/views/Interested/widgets/user_list_tile.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/routes.dart';
import '../../../data/models/interested_model.dart';
import '../../../data/viewmodels/interested_view_model.dart';

class InterestedUserScreen extends StatelessWidget {
  const InterestedUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InterestedViewModel>(
      create: (_) =>
          InterestedViewModel(repository: InterestedServices())..init(),
      child: const _InterestedUserView(),
    );
  }
}

class _InterestedUserView extends StatefulWidget {
  const _InterestedUserView();

  @override
  State<_InterestedUserView> createState() => _InterestedUserViewState();
}

class _InterestedUserViewState extends State<_InterestedUserView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // RN: `onEndReached={loadMore} onEndReachedThreshold={0.2}`
    _scrollController.addListener(() {
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent * 0.8) {
        context.read<InterestedViewModel>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showErrorIfAny(BuildContext context, InterestedViewModel vm) {
    if (vm.errorMessage != null) {
      final message = vm.errorMessage!;
      vm.consumeError();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      });
    }
  }

  void _openActionSheet(BuildContext context, InterestedUserModel item) {
    final vm = context.read<InterestedViewModel>();
    vm.selectItem(item);
    AppBottomSheet.show(
      context,
      sheetHeight: 350,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: vm,
        child: InterestedActionSheet(
          onViewProfile: () {
            Navigator.of(ctx).pop();
            vm.closeBottomSheet();
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.profileDetail, arguments: item);
          },
        ),
      ),
    ).whenComplete(() => vm.closeBottomSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InterestedViewModel>(
      builder: (context, vm, _) {
        _showErrorIfAny(context, vm);
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  AppHeaderWidget(
                    title: 'Interested',
                    isTrailing: false,
                    titleStyle: GoogleFonts.poltawskiNowy(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),
                  InterestedTabBar(
                    activeTab: vm.activeTab,
                    onTabSelected: (tab) => vm.switchTab(tab),
                  ),

                  Expanded(child: _buildBody(context, vm)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, InterestedViewModel vm) {
    // RN: full-screen loader only on the very first page load.
    if (vm.showInitialLoader) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: CircularProgressIndicator(color: AppColors.black)),
      );
    }

    return RefreshIndicator(
      color: AppColors.black,
      onRefresh: vm.refresh,
      child: vm.showEmptyState
          ? _buildEmptyState(vm)
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  vm.currentItems.length + (vm.showSkeletonFooter ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= vm.currentItems.length) {
                  return const SkeletonFooterList();
                }
                final item = vm.currentItems[index];
                return UserListTile(
                  user: item,
                  resolvedImageUrl: vm.resolveImageUrl(item.profilePicture),
                  initials: vm.initialsFor(item.fullName),
                  displayName: vm.capitalize(item.fullName),
                  onMenuPressed: () => _openActionSheet(context, item),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(InterestedViewModel vm) {
    return ListView(
      // Wrapped in a scrollable so RefreshIndicator still works when empty,
      // same as RN's `ListEmptyComponent` inside a refreshable `FlatList`.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Text(
              vm.emptyMessage,
              style: const TextStyle(fontSize: 16, color: AppColors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    double sheetHeight = 420,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        return SizedBox(
          width: width,
          height: sheetHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Curved white background (ported SVG path).
              CustomPaint(
                size: Size(width, sheetHeight),
                painter: CurveBackgroundPainter(),
              ),
              // Drag handle ("curve" style in RN).
              Positioned(
                top: 0,
                child: Container(
                  width: 55,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Content.
              Positioned(
                top: 48,
                left: 0,
                right: 0,
                bottom: 24,
                child: builder(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CurveBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    double w = size.width;
    double h = size.height;

    path.moveTo(45, 0);
    path.lineTo(w * 0.35, 0);
    path.cubicTo(w * 0.42, 0, w * 0.41, 36, w * 0.5, 36);
    path.cubicTo(w * 0.59, 36, w * 0.56, 0, w * 0.65, 0);
    path.lineTo(w - 45, 0);
    path.quadraticBezierTo(w, 0, w, 45);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.lineTo(0, 45);
    path.quadraticBezierTo(0, 0, 45, 0);
    path.close();

    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
