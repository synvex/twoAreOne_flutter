// lib/data/services/settings_service.dart
//
// Service layer for the Settings feature. Mirrors the RN services used by
// `Screens/AppScreens/SettingsScreen/index.js`:
//
//   RN service                          -> endpoint
//   ------------------------------------------------------------------
//   GetUserInfoService                  -> GET  user/user-info.php
//   LogoutService                       -> POST auth/logout.php
//   deleteUserService                   -> POST user/delete-account.php
//   updateUserEmailOtpSentService       -> POST user/update-email-otp-send.php
//
// Uses the app's existing `ApiManager` (lib/data/services/Api_Helper/
// api_manager.dart) so error handling (network errors, 401 session
// expiry, etc.) stays centralized and consistent with the rest of the app.
//
// NOTE: `logout()` / `deleteAccount()` intentionally re-declare endpoints
// that already exist in `ProfileService` (used by ProfileScreen). This is
// deliberate: each feature module owns its own service in this
// feature-first structure, so the Settings feature doesn't reach into
// ProfileScreen's service. Both simply call the same backend endpoint.

import 'Api_Helper/api_manager.dart';

class SettingsService {
  final ApiManager _api = ApiManager();

  /// GET user/user-info.php (RN: `GetUserInfoService`)
  /// Used to populate the email / phone number shown on this screen.
  Future<Map<String, dynamic>> getUserInfo() {
    return _api.fetch(
      Api(url: "user/user-info.php", method: "GET"),
      <String, dynamic>{},
    );
  }

  /// POST auth/logout.php (RN: `LogoutService`)
  Future<Map<String, dynamic>> logout() {
    return _api.fetch(Api(url: "auth/logout.php", method: "POST"), {});
  }

  /// POST user/delete-account.php (RN: `deleteUserService`)
  Future<Map<String, dynamic>> deleteAccount() {
    return _api.fetch(
      Api(url: "user/delete-account.php", method: "POST"),
      {},
    );
  }

  Future<Map<String, dynamic>> sendEmailChangeOtp({
    required String oldEmail,
  }) {
    return _api.fetch(
      Api(url: "user/update-email-otp-send.php", method: "POST"),
      {
        "old_email": oldEmail,
        "new_email": "",
        "type": "old",
      },
    );
  }
}