import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/error_view.dart';
import 'package:two_are_one/core/widgets/header.dart';
import 'package:two_are_one/core/widgets/loading_indicator.dart';
import 'package:two_are_one/data/end_points.dart';
import 'package:two_are_one/data/models/t_and_c_model.dart';
import 'package:two_are_one/data/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/data/viewmodels/base_fetch_view_model.dart';

class TermsViewModel extends BaseFetchViewModel<PageContentModel> {
  @override
  Future<PageContentModel> fetchData() async {
    final response = await Api_Manager.instance.fetch(
      ApiEndpoints.termsAndConditions,
    );
    final json = response.data['data'] as Map<String, dynamic>;
    return PageContentModel.fromJson(json);
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TermsViewModel()..load(),
      child: const _TermsView(),
    );
  }
}

class _TermsView extends StatelessWidget {
  const _TermsView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TermsViewModel>();
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
            Expanded(
              child: viewModel.isLoading
                  ? const LoadingIndicator()
                  : viewModel.hasError
                  ? ErrorView(
                      message:
                          viewModel.error?.message ?? 'Error loading content.',
                      onRetry: () => viewModel.load(),
                    )
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Html(data: viewModel.data?.pagesContent ?? ''),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
