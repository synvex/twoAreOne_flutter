import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_alert.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_text_field.dart';
import '../../../core/Error/api_error.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes.dart';
import '../../../core/widgets/back_button_header.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/api_endpoints.dart';
import '../../../data/repo/settings_Api_services.dart';
import '../../../data/viewmodels/settings_view_model.dart';

class AddNewEmailScreen extends StatefulWidget {
  const AddNewEmailScreen({super.key});

  @override
  State<AddNewEmailScreen> createState() => _AddNewEmailScreenState();
}

class _AddNewEmailScreenState extends State<AddNewEmailScreen> {
  final _email = TextEditingController();
  final _vm = SettingsViewModel(); // reused only to read current user's email
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _vm.loadUserInfo();
  }

  @override
  void dispose() {
    _email.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Email is required');
      return;
    }
    if (!AppRegex.validate(email, AppRegex.email)) {
      setState(() => _error = 'Email is invalid');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService.request(ApiEndpoints.updateUserEmailOtpSent, {
        'old_email': _vm.user.email,
        'new_email': email,
        'type': 'new',
      });
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        SettingsRoutes.changeEmailOtp,
        arguments: {
          'email': email,
          'isCurrent': false,
          'endTime': DateTime.now().add(const Duration(seconds: 60)),
        },
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButtonHeader(title: 'Change Email', noIcon: true),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFFF0EFEF), shape: BoxShape.circle),
                      child: const Icon(Icons.email_outlined, color: AppColors.mehroon),
                    ),
                    const SizedBox(height: 16),
                    Text('Add Your New Email', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      "Enter the new email you'd like to use. We'll send a code to verify it.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _email,
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                errorText: _error,
              ),
              const SizedBox(height: 24),
              CustomButton(title: 'Send OTP', loading: _loading, onPress: _onSend),
            ],
          ),
        ),
      ),
    );
  }
}