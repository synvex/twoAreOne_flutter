// lib/features/viewmodels/settings_view_model.dart
//
// ViewModel for SettingsScreen (strict MVVM: this class owns ALL state and
// business logic; the View only reads from it and calls its methods).
//
// Built on `ChangeNotifier` (part of the Flutter SDK, no extra package
// needed) so the View can rebuild with a plain `AnimatedBuilder` /
// `ListenableBuilder`.
//
// Maps 1:1 onto the RN screen's local state
// (`Screens/AppScreens/SettingsScreen/index.js`):
//
//   RN useState                Flutter field
//   ------------------------------------------------
//   loader                      logoutLoading
//   showLogoutModal             showLogoutModal
//   phoneVisible                showPhoneConfirm
//   deleteLoader                deleteLoading
//   phoneLoader                 phoneLoading
//   showDeleteModal             showDeleteModal
//   emailVisible                showEmailConfirm
//   emailLoader                 emailLoading
//   on (notification toggle)    notificationsOn
//
// Navigation and Firebase phone-verification results are surfaced to the
// View via callback parameters passed into the relevant method (rather
// than the ViewModel importing BuildContext/Navigator), keeping this class
// UI-framework-free and easily testable.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:two_are_one/features/views/Settings/change_email_otp_screen.dart';

import '../../data/models/user_info.dart';
import '../../data/services/setting.dart';
import '../../data/services/auth_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    SettingsService? settingsService,
    AuthService? authService,
  })  : _settingsService = settingsService ?? SettingsService(),
        _authService = authService ?? AuthService();

  final SettingsService _settingsService;
  final AuthService _authService;

  // ── User info (populates "Change Email" / "Change Number" sub-values) ──
  bool isLoadingUser = true;
  SettingsUserInfo user = const SettingsUserInfo();

  // ── Notification toggle ─────────────────────────────────────────────
  // RN never persists this anywhere (no API call in the RN source) —
  // it's purely local UI state, replicated exactly here.
  bool notificationsOn = false;

  // ── Logout ───────────────────────────────────────────────────────────
  bool showLogoutModal = false;
  bool logoutLoading = false;

  // ── Delete account ───────────────────────────────────────────────────
  bool showDeleteModal = false;
  bool deleteLoading = false;

  // ── Change Number confirmation ───────────────────────────────────────
  bool showPhoneConfirm = false;
  bool phoneLoading = false;

  // ── Change Email confirmation ────────────────────────────────────────
  bool showEmailConfirm = false;
  bool emailLoading = false;

  // ── Load user info ───────────────────────────────────────────────────
  Future<void> loadUserInfo() async {
    isLoadingUser = true;
    notifyListeners();

    final res = await _settingsService.getUserInfo();

    if (res['success'] == true && res['data'] is Map) {
      user = SettingsUserInfo.fromJson(
        (res['data'] as Map).cast<String, dynamic>(),
      );
    }
    isLoadingUser = false;
    notifyListeners();
  }

  // ── Notification toggle ──────────────────────────────────────────────
  void setNotificationsOn(bool value) {
    notificationsOn = value;
    notifyListeners();
  }

  // ── Logout flow ───────────────────────────────────────────────────────
  void openLogoutModal() {
    showLogoutModal = true;
    notifyListeners();
  }

  void closeLogoutModal() {
    if (logoutLoading) return; // RN disables cancel while its loader spins
    showLogoutModal = false;
    notifyListeners();
  }

  /// RN: `handleLogout`.
  Future<void> confirmLogout({
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async
  {
    logoutLoading = true;
    notifyListeners();

    final res = await _settingsService.logout();

    if (res['success'] == true) {
      logoutLoading = false;
      showLogoutModal = false;
      notifyListeners();
      onSuccess();
    } else {
      logoutLoading = false;
      notifyListeners();
      onError(res['error']?.toString() ?? 'Something went wrong');
    }
  }

  // ── Delete account flow ─────────────────────────────────────────────
  void openDeleteModal() {
    showDeleteModal = true;
    notifyListeners();
  }

  void closeDeleteModal() {
    if (deleteLoading) return;
    showDeleteModal = false;
    notifyListeners();
  }

  /// RN: `handleDeleteAccount`.
  Future<void> confirmDeleteAccount({
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    deleteLoading = true;
    notifyListeners();

    final res = await _settingsService.deleteAccount();

    if (res['success'] == true) {
      deleteLoading = false;
      showDeleteModal = false;
      notifyListeners();
      onSuccess();
    } else {
      deleteLoading = false;
      notifyListeners();
      onError(res['error']?.toString() ?? 'Account deletion failed');
    }
  }

  // ── Change Number flow ───────────────────────────────────────────────
  void openPhoneConfirm() {
    showPhoneConfirm = true;
    notifyListeners();
  }

  void closePhoneConfirm() {
    showPhoneConfirm = false;
    notifyListeners();
  }

  Future<void> confirmPhoneChange({
    required void Function(String verificationId, String phone, int endTime)
    onCodeSent,
    required ValueChanged<String> onError,
  }) async
  {
    final phone = user.phoneNo;
    if (phone.isEmpty) {
      onError('Phone number not found.');
      return;
    }

    phoneLoading = true;
    notifyListeners();

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phone,
        onCodeSent: (verificationId) {
          phoneLoading = false;
          showPhoneConfirm = false;
          notifyListeners();
          final endTime = DateTime.now().millisecondsSinceEpoch + 60000;
          onCodeSent(verificationId, phone, endTime);
        },
        onVerificationFailed: (e) {
          phoneLoading = false;
          notifyListeners();
          onError('Failed to send OTP. Please try again.');
        },
      );
    } catch (_) {
      phoneLoading = false;
      notifyListeners();
      onError('Failed to send OTP. Please try again.');
    }
  }

  // ── Change Email flow ────────────────────────────────────────────────
  void openEmailConfirm() {
    showEmailConfirm = true;
       notifyListeners();
  }

  void closeEmailConfirm() {
    showEmailConfirm = false;
    notifyListeners();
  }

  /// RN: `onEmailContinuePress`.
  Future<void> confirmEmailChange({
    required void Function(String email, int endTime) onSent,
    required ValueChanged<String> onError,
  }) async
  {
    emailLoading = true;
    notifyListeners();

    final res = await _settingsService.sendEmailChangeOtp(
        oldEmail: user.email);

    if (res['success'] == true) {
      emailLoading = false;
      showEmailConfirm = false;
      notifyListeners();
      final endTime = DateTime.now().millisecondsSinceEpoch + 60000;
      onSent(user.email, endTime);
    } else {
      emailLoading = false;
      notifyListeners();
      onError(res['error']?.toString() ?? 'Something went wrong');
    }
  }
}