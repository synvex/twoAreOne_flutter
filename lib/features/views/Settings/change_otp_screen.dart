import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/features/views/Settings/widgets/custom_alert.dart';

import '../../../core/Error/api_error.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/widgets/back_button_header.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/font.dart';
import '../../../data/api_endpoints.dart';
import '../../../data/repo/settings_Api_services.dart';
import '../../../data/viewmodels/setting_auth_view_model.dart';

class ChangeOtpScreen extends StatefulWidget {
  final String phone;
  final bool isCurrent;
  final DateTime endTime;

  const ChangeOtpScreen({super.key, required this.phone, this.isCurrent = false, required this.endTime});

  @override
  State<ChangeOtpScreen> createState() => _ChangeOtpScreenState();
}

class _ChangeOtpScreenState extends State<ChangeOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final PhoneAuthService _phoneAuth = createPhoneAuthService();
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
      final confirmed = await _phoneAuth.confirmCode(widget.phone, _code);
      if (!confirmed) {
        setState(() => _error = 'Invalid code.');
        return;
      }
      if (!widget.isCurrent) {
        await ApiService.request(ApiEndpoints.updateUserPhone, {'new_phone_no': widget.phone});
        if (!mounted) return;
        final authVm = context.read<AuthViewModel>();
        authVm.setRefreshProfile(!authVm.refreshProfile);
        await CustomAlert.showMessage(context, title: 'Success', message: 'Your phone number has been changed');
        if (mounted) {
          Navigator.of(context).popUntil((r) => r.settings.name == AppRoutes.settingScreen || r.isFirst);
        }
      } else {
        // This step only verifies ownership of the *current* number - the
        // actual change happens after entering the new one.
        if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.changePhoneScreen);
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
      await _phoneAuth.sendCode(widget.phone);
      if (!mounted) return;
      setState(() => _remaining = 60);
      await CustomAlert.showMessage(context, title: 'OTP resent', message: 'A new code has been sent to ${widget.phone}');
    } catch (_) {
      if (mounted) await CustomAlert.showMessage(context, title: 'Error', message: 'Failed to resend OTP.');
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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackButtonHeader(title: widget.isCurrent ? 'Verify Number' : 'Add New Phone', noIcon: true),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.textBackground, shape: BoxShape.circle),
                      child: SvgPicture.asset('assets/Settings/changeNumber.svg', width: 30, height: 30),
                    ),
                    const SizedBox(height: 16),
                    Text(widget.isCurrent ? 'Verify Current Number' : 'Add Your New Phone Number',
                        textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey2),
                          children: [
                          const TextSpan(text: "We've sent a 6-digit code to your "),
                          TextSpan(text: widget.phone, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("Enter the code below to confirm it's really you",
                        textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey2)),
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
                            decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
                            onChanged: (v) {
                              setState(() {});
                              if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
                            },
                          ),
                        );
                      }),
                    ),
                    if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(
                        color: AppColors.red,  fontSize: 12))),
                    const SizedBox(height: 16),
                    Text(_timerLabel, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.grey2), ),
                    if (_remaining == 0)
                      TextButton(
                        onPressed: _resendLoading ? null : _resend,
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey2),
                            children: [
                              const TextSpan(text: "Didn't receive OTP? "),
                              TextSpan(text: 'Send OTP', style: const TextStyle(color: AppColors.mehroon, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(title: 'Update Number', loading: _loading, onPress: _verify),
            ],
          ),
        ),
      ),
    );
  }
}
