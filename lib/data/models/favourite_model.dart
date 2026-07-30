/// A single row in either the "Favourite You" or "Your Favourite" list.
class FavouriteUserModel {
  final int id;
  final String fullName;
  final String? profilePicture;

  const FavouriteUserModel({
    required this.id,
    required this.fullName,
    this.profilePicture,
  });

  factory FavouriteUserModel.fromJson(Map<String, dynamic> json) {
    // Different endpoints key the id differently — check all known variants.
    final rawId = json['id'] ?? json['user_id'] ?? json['viewer_id'];

    return FavouriteUserModel(
      id: int.tryParse(rawId?.toString() ?? '') ?? 0,
      fullName: (json['full_name'] ?? json['fullName'] ?? '').toString().trim(),
      profilePicture: (json['profile_picture'] ?? json['profilePicture'])?.toString(),
    );
  }

  static List<FavouriteUserModel> listFromJson(List<dynamic> data) => data
      .whereType<Map>()
      .map((e) => FavouriteUserModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}
