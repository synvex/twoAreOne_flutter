import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/Error/api_error.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/data/viewmodels/user_stats_view_model.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_alert.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/api_endpoints.dart';
import '../../../data/repo/settings_Api_services.dart';

class ChangeEmailOtpScreen extends StatefulWidget {
  final String email;
  final bool isCurrent;
  final DateTime endTime;

  const ChangeEmailOtpScreen({
    super.key,
    required this.email,
    required this.isCurrent,
    required this.endTime,
  });

  @override
  State<ChangeEmailOtpScreen> createState() => _ChangeEmailOtpScreenState();
}
class _ChangeEmailOtpScreenState extends State<ChangeEmailOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  Timer? _timer;
  int _remaining = 60;
  bool _loading = false;
  bool _resendLoading = false;
  String? _error;

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _tick() {
    final diff = widget.endTime.difference(DateTime.now()).inSeconds;
    setState(() => _remaining = diff > 0 ? diff : 0);
  }

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Invalid otp');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.isCurrent) {
        await ApiService.request(ApiEndpoints.currentEmailVerifyOtp, {
          'otp': _code,
        });
        if (!mounted) return;
        // Navigator.of(context).pushReplacementNamed(AuthRoutes.verifiedScreen);
        Navigator.of(context).pushReplacementNamed(SettingsRoutes.addNewEmail);
      } else {
        await ApiService.request(ApiEndpoints.updateEmailVerifyOtp, {
          'new_email': widget.email,
          'otp': _code,
        });
        if (!mounted) return;
        // ✅ Real-time fix: push the new email straight into the shared
        // UserStatsViewModel so the Home banner (and drawer) shows it
        // immediately - previously nothing updated Home after this screen
        // popped, so the old email lingered until the app was restarted.
        context.read<UserStatsViewModel>().setEmail(widget.email);
        await CustomAlert.showMessage(
          context,
          title: 'Success',
          message: 'Your email address has been changed',
        );
        if (mounted) {
          Navigator.of(context).popUntil(
                (r) => r.settings.name == AppRoutes.settingScreen || r.isFirst,
          );
        }
      }
    } on ApiError catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Invalid code.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resendLoading = true);
    try {
      await ApiService.request(ApiEndpoints.updateEmailResendOtp, {
        'email': widget.email,
      });
      if (!mounted) return;
      setState(() => _remaining = 60);
      await CustomAlert.showMessage(
        context,
        title: 'OTP sent',
        message: 'Otp sent to ${widget.email}',
      );
    } on ApiError catch (e) {
      if (mounted) await CustomAlert.showError(context, e);
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  String get _timerLabel {
    final s = _remaining;
    return '00:${s < 10 ? '0$s' : '$s'}';
  }

  @override
  Widget build(BuildContext context) {
    //final poppins = AppFonts.poppins.family;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeaderWidget(title: 'Change Email', isTrailing: false),

              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0EFEF),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        'assets/Settings/emailIcon.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'OTP VERIFICATION',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.grey2,
                        ),
                        children: [
                          const TextSpan(
                            text: "We've sent a 6-digit code to your ",
                          ),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter the code below to confirm it's really you",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.grey2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: 44,
                          height: 52,
                          child: TextField(
                            controller: _controllers[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              setState(() {});
                              if (v.isNotEmpty && i < 5) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _timerLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.grey2,
                      ),
                    ),
                    if (_remaining == 0)
                      TextButton(
                        onPressed: _resendLoading ? null : _resend,
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.grey2,
                            ),
                            children: [
                              const TextSpan(text: "Didn't receive OTP? "),
                              TextSpan(
                                text: 'Send OTP',
                                style: const TextStyle(
                                  color: AppColors.mehroon,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                title: 'Verify',
                loading: _loading,
                onPress: _verify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


