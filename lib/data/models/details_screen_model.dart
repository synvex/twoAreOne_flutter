
class ProfileCategory {
  final int categoryId;
  final String categoryName;

  ProfileCategory({required this.categoryId, required this.categoryName});

  factory ProfileCategory.fromJson(Map<String, dynamic> json) {
    return ProfileCategory(
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
    );
  }
}

class ProfileDetailModel {
  final int userId;
  final String fullName;
  final String? bio;
  final String? work;
  final String gender;
  final String height;
  final String weight;
  final String age;
  final String city;
  final String country;
  final String profilePicture;
  final List<String> images;
  final String? video;
  final String percentMatch;
  final bool isFavorite;
  final bool isInterested;
  final List<ProfileCategory> categories;

  ProfileDetailModel({
    required this.userId,
    required this.fullName,
    this.bio,
    this.work,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.city,
    required this.country,
    required this.profilePicture,
    required this.images,
    this.video,
    required this.percentMatch,
    required this.isFavorite,
    required this.isInterested,
    required this.categories,
  });

  factory ProfileDetailModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userDetails =
        (json['user_details'] as Map?)?.cast<String, dynamic>() ?? {};

    final List<dynamic> rawImages = (json['images'] as List?) ?? [];
    dynamic rawVideo = json['videos'] ?? json['video'] ?? json['user_video'];
    if (rawVideo is List && rawVideo.isNotEmpty) rawVideo = rawVideo.first;

    video: (rawVideo is Map)
        ? (rawVideo['url'] ?? rawVideo['video'] ?? '').toString()
        : rawVideo?.toString();
    final List<dynamic> rawCategories = (json['categories'] as List?) ?? [];

    return ProfileDetailModel(
      userId: int.tryParse(
          (userDetails['user_id'] ?? userDetails['id'])?.toString() ??
              '0') ??
          0,
      fullName:
      (userDetails['full_name'] ?? userDetails['name'])?.toString() ??
          '',
      bio: userDetails['bio']?.toString(),
      work: userDetails['work']?.toString(),
      gender: userDetails['gender']?.toString() ?? '',
      height: userDetails['height']?.toString() ?? '',
      weight: userDetails['weight']?.toString() ?? '',
      age: userDetails['age']?.toString() ?? '',
      city: userDetails['city']?.toString() ?? '',
      country: userDetails['country']?.toString() ?? '',
      profilePicture:
      (userDetails['profile_picture'] ?? userDetails['image'])
          ?.toString() ??
          '',
      images: rawImages.map((e) => e.toString()).toList(),
      video: (rawVideo == null || rawVideo.toString().isEmpty)
          ? null
          : rawVideo.toString(),
      percentMatch: (json['percent_match'] ?? '0').toString(),
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      isInterested:
      json['is_interested'] == true || json['is_interested'] == 1,
      categories: rawCategories
          .map((e) => ProfileCategory.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  ProfileDetailModel copyWith({
    bool? isFavorite,
    bool? isInterested,
  }) {
    return ProfileDetailModel(
      userId: userId,
      fullName: fullName,
      bio: bio,
      work: work,
      gender: gender,
      height: height,
      weight: weight,
      age: age,
      city: city,
      country: country,
      profilePicture: profilePicture,
      images: images,
      video: video,
      percentMatch: percentMatch,
      isFavorite: isFavorite ?? this.isFavorite,
      isInterested: isInterested ?? this.isInterested,
      categories: categories,
    );
  }
}