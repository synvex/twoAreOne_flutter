import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_alert.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_text_field.dart';

import '../../../core/Error/api_error.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/widgets/back_button_header.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/api_endpoints.dart';
import '../../../data/repo/settings_Api_services.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _phone = TextEditingController();
  final PhoneAuthService _phoneAuth = createPhoneAuthService();
  String? _error;
  bool _loading = false;

  void _goToSettings() =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.settingScreen);

  Future<void> _onContinue() async {
    final phone = _phone.text.trim();
    if (phone.length < 8) {
      setState(() => _error = 'Please enter a valid phone number');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // RN checks with the backend first (this number isn't already linked
      // to another account) before ever attempting Firebase phone auth.
      await ApiService.request(ApiEndpoints.verifyPhone, {'phone_no': phone});
      final confirmation = await _phoneAuth.sendCode(phone);
      if (!mounted) return;
      if (confirmation != null) {
        Navigator.of(context).pushNamed(
          AppRoutes.changeOtpScreen,
          arguments: {
            'phone': phone,
            'endTime': DateTime.now().add(const Duration(seconds: 60)),
          },
        );
      }
    } on ApiError catch (e) {
      setState(
        () => _error = e.message.isNotEmpty
            ? e.message
            : 'This Number is already linked to another account. Please use a different number',
      );
    } catch (_) {
      if (mounted)
        await CustomAlert.showMessage(
          context,
          title: 'Error',
          message: 'Failed to send OTP. Please try again.',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToSettings();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeaderWidget(title: 'Add New Phone', isTrailing: false),

                const SizedBox(height: 16),
                Text(
                  'Add Your New Phone Number',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the new phone number you want to use. We will send an OTP for verification.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.grey2,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phone,
                  hint: '+1 234 567 8900',
                  keyboardType: TextInputType.phone,
                  errorText: _error,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  title: 'Send OTP',
                  loading: _loading,
                  onPress: _onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
