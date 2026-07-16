// lib/data/models/settings_user_info.dart
//
// Lightweight model for the fields the Settings screen actually needs
// (RN reads these straight off the `user` redux object via `authUser`):
//   - user?.email     -> "Change Email" sub-value
//   - user?.phone_no  -> "Change Number" sub-value
//
// Kept separate from `UserFullProfile` (used by ProfileScreen/EditProfileScreen)
// on purpose: each feature owns the slice of the user-info response it needs,
// per the feature-first architecture requested. Both models are populated
// from the same `GET user/user-info.php` endpoint.

class SettingsUserInfo {
  final String email;
  final String phoneNo;

  const SettingsUserInfo({
    this.email = '',
    this.phoneNo = '',
  });

  factory SettingsUserInfo.fromJson(Map<String, dynamic> json) {
    return SettingsUserInfo(
      email: json['email']?.toString() ?? '',
      // Some endpoints in this backend use `phone_no`, keep a fallback to
      // `phone` just in case a particular response shape differs.
      phoneNo: (json['phone_no'] ?? json['phone'])?.toString() ?? '',
    );
  }

  SettingsUserInfo copyWith({String? email, String? phoneNo}) {
    return SettingsUserInfo(
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
    );
  }
}