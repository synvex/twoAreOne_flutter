/// Lightweight model for a row in the Blocked / Visited user lists.
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
    return VisitedBlockedUserModel(
      profileId: int.tryParse((json['profile_id'] ?? json['id']).toString()) ?? 0,
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