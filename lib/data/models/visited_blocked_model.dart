
class VisitedBlockedUserModel {
  final int profileId;
  final String fullName;
  final String? profilePicture;
  VisitedBlockedUserModel({
    required this.profileId,
    required this.fullName,
    this.profilePicture,
  });
  factory VisitedBlockedUserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['profile_id'] ??
        json['id'] ??
        json['user_id'] ??
        json['visited_user_id'] ??
        0;
    return VisitedBlockedUserModel(
      profileId: int.tryParse(rawId.toString()) ?? 0,
      fullName: (json['full_name'] ?? '').toString(),
      profilePicture: json['profile_picture']?.toString(),
    );
  }
  bool get hasImage =>
      profilePicture != null &&
          profilePicture!.trim().isNotEmpty &&
          profilePicture != "null";
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// class VisitedBlockedUserModel {
//   final int profileId;
//   final String fullName;
//   final String? profilePicture;
//
//   VisitedBlockedUserModel({
//     required this.profileId,
//     required this.fullName,
//     this.profilePicture,
//   });
//
//   factory VisitedBlockedUserModel.fromJson(Map<String, dynamic> json) {
//     return VisitedBlockedUserModel(
//       profileId: int.tryParse((
//           json['profile_id'] ??
//               json['id']).toString()) ??
//           json['id'] ??
//           json['visited_user_id'] ??
//           0,
//       fullName: (json['full_name'] ?? '').toString(),
//       profilePicture: json['profile_picture']?.toString(),
//     );
//   }
//
//   bool get hasImage =>
//       profilePicture != null &&
//           profilePicture!.trim().isNotEmpty &&
//           profilePicture != "null";
//
//   String get initials {
//     final parts = fullName.trim().split(RegExp(r'\s+'));
//     if (parts.isEmpty || parts.first.isEmpty) return '';
//     if (parts.length == 1) return parts.first[0].toUpperCase();
//     return (parts[0][0] + parts[1][0]).toUpperCase();
//   }
// }