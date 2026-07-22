import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/back_button.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/features/views/Settings/widgets/dialog.dart';
import 'package:two_are_one/features/views/Settings/widgets/editable_items.dart';
import 'package:two_are_one/features/views/Settings/widgets/items.dart';
import 'package:two_are_one/features/views/bottom_nav/profile_screen.dart';
import 'package:two_are_one/core/widgets/confirmation_dialogue.dart';
import 'package:two_are_one/core/routes/routes.dart';
import 'package:two_are_one/core/widgets/top_toast.dart';
import 'package:two_are_one/data/viewmodels/settings_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SettingsViewModel();
    _vm.loadUserInfo();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────

  Future<void> _navigateOrComingSoon(
      String routeName, {
        Object? arguments,
      }) async
  {
    try {
      await Navigator.of(context).pushNamed(
          routeName, arguments: arguments);
    } catch (_) {
      if (mounted) {
        TopToast.show(context, title: "Coming soon", type: ToastType.info);
      }
    }
  }

  void _goBack() {
    Navigator.of(context).pop(true);
  }

  // ── Action handlers ──────────────────────────────────────────────────

  void _handleLogoutConfirm() {
    _vm.confirmLogout(
      onSuccess: () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      },
      onError: (message) {
        if (!mounted) return;
        TopToast.show(context, title: message, type: ToastType.error);
      },
    );
  }

  void _handleDeleteConfirm() {
    _vm.confirmDeleteAccount(
      onSuccess: () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      },
      onError: (message) {
        if (!mounted) return;
        TopToast.show(context, title: message, type: ToastType.error);
      },
    );
  }

  void _handlePhoneConfirm() {
    _vm.confirmPhoneChange(
      onCodeSent: (verificationId, phone, endTime) {
        if (!mounted) return;
        _navigateOrComingSoon(
          SettingsRoutes.changeOtp,
          arguments: {
            'verificationId': verificationId,
            'phone': phone,
            'isCurrent': true,
            'endTime': endTime,
          },
        );
      },
      onError: (message) {
        if (!mounted) return;
        TopToast.show(context, title: message, type: ToastType.error);
      },
    );
  }

  void _handleEmailConfirm() {
    _vm.confirmEmailChange(
      onSent: (email, endTime) {
        if (!mounted) return;
        _navigateOrComingSoon(
          SettingsRoutes.changeEmailOtp,
          arguments: {
            'email': email,
            'isCurrent': true,
            'endTime': endTime,
          },
        );
      },
      onError: (message) {
        if (!mounted) return;
        TopToast.show(context, title: message, type: ToastType.error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 30, top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHelpAndTermsSection(),
                              const SizedBox(height: 25),
                              _buildNotificationSection(),
                              const SizedBox(height: 25),
                              _buildAccountSecuritySection(),
                              const SizedBox(height: 30),
                              _buildActionButtons(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Modals ─────────────────────────────────────────────
              if (_vm.showLogoutModal)
                LogoutConfirmationDialog(
                  loading: _vm.logoutLoading,
                  onClose: _vm.closeLogoutModal,
                  onConfirm: _handleLogoutConfirm,
                ),
              if (_vm.showDeleteModal)
                DeleteConfirmationDialog(
                  loading: _vm.deleteLoading,
                  onClose: _vm.closeDeleteModal,
                  onConfirm: _handleDeleteConfirm,
                ),
              if (_vm.showPhoneConfirm)
                ChangeConfirmationDialog(
                  message: 'Are you sure you want to change your Number?',
                  loading: _vm.phoneLoading,
                  onCancel: _vm.closePhoneConfirm,
                  onContinue: _handlePhoneConfirm,
                ),
              if (_vm.showEmailConfirm)
                ChangeConfirmationDialog(
                  message: 'Are you sure you want to change your email?',
                  loading: _vm.emailLoading,
                  onCancel: _vm.closeEmailConfirm,
                  onContinue: _handleEmailConfirm,
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // GestureDetector(
        //   onTap: _goBack,
        //   child: Container(
        //     width: 50,
        //     height: 50,
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       border: Border.all(color: const Color(0xFFD9D9D9)),
        //     ),
        //     alignment: Alignment.center,
        //     child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
        //   ),
        // ),
        Back_Button(onTap: ()=>Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(),))),
        const Texts(text:
          'Settings',
          size: 24,
            fontWeight: FontWeight.w500,
            colorHexValue: 0xFF000000,
        ),
        const SizedBox(width: 50), // balances the back button (RN: empty View)
      ],
    );
  }

  // ── Section: Help and Terms of Use ──────────────────────────────────

  Widget _buildHelpAndTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('assets/Settings/helpIcon.svg', 'HELP AND TERMS OF USE'),
        const SizedBox(height: 20),
        _card(
          child: Column(
            children: [
              SettingsItem(
                icon: const Images(imageStr: 'assets/Settings/privacyIcon.svg'),
                label: 'Privacy Policy',
                onPressed: () =>
                    _navigateOrComingSoon(SettingsRoutes.privacyPolicy),
              ),
              SettingsItem(
                icon: const Images(
                    imageStr: 'assets/Settings/termUse.svg',
                  height: 20,width: 20,color: Colors.black,),
                label: 'Terms of Use',
                isLast: true,
                onPressed: () =>
                    _navigateOrComingSoon(SettingsRoutes.termsOfUse),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section: Notification Setting ───────────────────────────────────

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('assets/Settings/notificationSetting.svg',
            'Notification Setting'),
        const SizedBox(height: 10),
        _card(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          radius: 999,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Texts(
                text: 'App Notification',
                size: 14,
                  fontWeight: FontWeight.w400,
                  colorHexValue: 0xFF000000,
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _vm.notificationsOn,
                  onChanged: _vm.setNotificationsOn,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF477CB6),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.red,
                   trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // ── Section: Account Security & Information ─────────────────────────

  Widget _buildAccountSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("assets/Settings/secuirtyIcon.svg", 'Account Security & Information'),
        const SizedBox(height: 10),
        _card(
          child: _vm.isLoadingUser
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
              : Column(
            children: [
              EditableItem(
                icon: const Icon(Icons.email_outlined, size: 20),
                value: 'Change Email',
                subValue: _vm.user.email,
                onPressed: _vm.openEmailConfirm,
              ),
              EditableItem(
                icon: const Icon(Icons.lock_open, size: 20),
                value: 'Change Password',
                subValue: '*************',
                secure: true,
                onPressed: () =>
                    _navigateOrComingSoon(SettingsRoutes.resetPassword),
              ),
              EditableItem(
                icon: const Icon(CupertinoIcons.phone, size: 20),
                value: 'Change Number',
                subValue: _vm.user.phoneNo,
                isLast: true,
                onPressed: _vm.openPhoneConfirm,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Actions: Delete Account / Logout ─────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _vm.openDeleteModal,
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0x0D000000),
              side: const BorderSide(color: Color(0x4D000000)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(
                color: Color(0xFFD00000),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _vm.openLogoutModal,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x4D000000)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ── Small shared pieces ──────────────────────────────────────────────

  Widget _sectionHeader(String icon, String title) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x1A000000)),
          bottom: BorderSide(color: Color(0x1A000000)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Images(imageStr: icon, height: 20, width: 20),
          const SizedBox(width: 10),
          Texts(
            text: title,
            size: 14,
              fontWeight: FontWeight.w500,
              colorHexValue: 0xFF000000,
            ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double radius = 12,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x03000000),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0x33B9B9B9)),
      ),
      child: child,
    );
  }
}
