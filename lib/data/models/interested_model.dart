/// A single row in either the "Interested You" or "Your Interested" list.
class InterestedUserModel {
  final int id;
  final String fullName;
  final String? profilePicture;

  const InterestedUserModel({
    required this.id,
    required this.fullName,
    this.profilePicture,
  });

  factory InterestedUserModel.fromJson(Map<String, dynamic> json) {
    // Different endpoints key the id differently — check all known variants.
    final rawId = json['id'] ?? json['user_id'] ?? json['viewer_id'];

    return InterestedUserModel(
      id: int.tryParse(rawId?.toString() ?? '') ?? 0,
      fullName: (json['full_name'] ?? json['fullName'] ?? '').toString().trim(),
      profilePicture: (json['profile_picture'] ?? json['profilePicture'])?.toString(),
    );
  }

  static List<InterestedUserModel> listFromJson(List<dynamic> data) => data
      .whereType<Map>()
      .map((e) => InterestedUserModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}


// class InterestedUserModel {
//   final int id;
//   final String fullName;
//   final String? profilePicture;
//
//   const InterestedUserModel({
//     required this.id,
//     required this.fullName,
//     this.profilePicture,
//   });
//
//   factory InterestedUserModel.fromJson(Map<String, dynamic> json) {
//     return InterestedUserModel(
//       id: int.tryParse(json['id'].toString()) ?? 0,
//       fullName: (json['full_name'] ?? '').toString(),
//       profilePicture: json['profile_picture']?.toString(),
//     );
//   }
//
//   static List<InterestedUserModel> listFromJson(List<dynamic> data) =>
//       data.map((e) => InterestedUserModel.fromJson(e as Map<String, dynamic>)).toList();
// }