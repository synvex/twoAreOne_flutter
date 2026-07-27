import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_alert.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_bottom_sheet.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_text_field.dart';
import '../../../core/Error/api_error.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes.dart';
import '../../../core/widgets/back_button_header.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/api_endpoints.dart';
import '../../../data/repo/settings_Api_services.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _o1 = true, _o2 = true, _o3 = true, _loading = false;
  String? _oldError, _newError, _confirmError;

  bool _validate() {
    setState(() {
      _oldError = _oldPassword.text.trim().isEmpty
          ? 'Current password is required'
          : null;
      _newError = _newPassword.text.trim().isEmpty
          ? 'New password is required'
          : (!AppRegex.validate(_newPassword.text.trim(), AppRegex.password)
                ? 'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character'
                : null);
      _confirmError = _newPassword.text.trim() != _confirmPassword.text.trim()
          ? 'Password mismatch'
          : null;
    });
    return _oldError == null && _newError == null && _confirmError == null;
  }

  Future<void> _onSubmit() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.request(ApiEndpoints.changeUserPassword, {
        'old_password': _oldPassword.text,
        'new_password': _newPassword.text,
      });
      if (!mounted) return;
      await CustomBottomSheet.show(
        context,
        sheetHeight: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/Settings/passwordChngeDone.svg',
              height: 90,
            ),
            const SizedBox(height: 12),
            Text(
              'Your Password Changed',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.grey2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your password has been successfully updated.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.grey2),
            ),
            const SizedBox(height: 20),
            CustomButton(
              title: 'Done',
              onPress: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil(
                  (r) =>
                      r.settings.name == AppRoutes.settingScreen || r.isFirst,
                );
              },
            ),
          ],
        ),
      );
    } on ApiError catch (e) {
      if (mounted) await CustomAlert.showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeaderWidget(title: 'Password Change', isTrailing: false),
              SizedBox(height: 20.h),
              Text(
                'Create New Password',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Set a new password and you're all set to explore new connections",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.grey2,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Current Password',
                hint: 'Enter current password',
                controller: _oldPassword,
                obscureText: _o1,
                errorText: _oldError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _o1 ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _o1 = !_o1),
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: _newPassword,
                obscureText: _o2,
                errorText: _newError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _o2 ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _o2 = !_o2),
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Confirm New Password',
                hint: 'Re-enter new password',
                controller: _confirmPassword,
                obscureText: _o3,
                errorText: _confirmError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _o3 ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _o3 = !_o3),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                title: 'Submit',
                loading: _loading,
                onPress: _onSubmit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
