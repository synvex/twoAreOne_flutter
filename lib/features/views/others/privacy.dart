import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/error_view.dart';
import 'package:two_are_one/core/widgets/loading_indicator.dart';
import 'package:two_are_one/data/viewmodels/privacy_model.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrivacyPolicyViewModel()..load(),
      child: const _PrivacyPolicyView(),
    );
  }
}

class _PrivacyPolicyView extends StatelessWidget {
  const _PrivacyPolicyView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PrivacyPolicyViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: AppHeaderWidget(
                title: 'Privacy Policy',
                isTrailing: false,
              ),
            ),
            SizedBox(height: 10.h),
            Divider(),
            Expanded(child: _buildBody(context, viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PrivacyPolicyViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingIndicator();
    }

    if (viewModel.hasError) {
      return ErrorView(
        message: viewModel.error?.message ?? 'Error loading content.',
        onRetry: () => viewModel.load(),
      );
    }

    final html = viewModel.data?.pagesContent ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Html(
        data: html,
        style: {
          'p': Style(
            fontSize: FontSize(14),
            color: AppColors.primaryText,
            margin: Margins.only(bottom: 10),
          ),
          'strong': Style(fontWeight: FontWeight.bold),
          'a': Style(color: AppColors.link),
          'ul': Style(
            padding: HtmlPaddings.only(left: 20),
            margin: Margins.only(bottom: 10),
          ),
          'li': Style(margin: Margins.only(bottom: 6)),
        },
      ),
    );
  }
}
