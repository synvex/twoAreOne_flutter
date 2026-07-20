// lib/models/user_full_profile_model.dart
// Model for the logged-in user's own profile data, returned by
// GET user/user-info.php (RN: GetUserInfoService).
//
// Used by:
//  - ProfileScreen (header card: name/email/avatar + favorites/interested/
//    blocks stat counters) — original fields, untouched.
//  - EditProfileScreen (RN: EditProfileScreen/index.js) — the additional
//    fields below (bio, gender, age, height, weight, work, location,
//    photos, video, categories) mirror exactly what RN reads off its
//    `user` redux selector (`authUser`).

import 'details_screen_model.dart' show ProfileCategory;

/// One entry in `all_images` (RN: `user.all_images`, each `{ id, url }`).
/// Needed (unlike ProfileDetailModel's plain `List<String> images`)
/// because EditProfileScreen must send the numeric `id` back to
/// `remove-photo.php` (RN: `removeUserPhotoService` payload `{ image_id }`).
class ProfileMediaImage {
  final int id;
  final String url;

  ProfileMediaImage({required this.id, required this.url});

  factory ProfileMediaImage.fromJson(Map<String, dynamic> json) {
    return ProfileMediaImage(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      url: (json['url'] ?? json['image'] ?? '').toString(),
    );
  }
}
class ProfileMediaVideo {
  final int id;
  final String url;

  ProfileMediaVideo({required this.id, required this.url});

  factory ProfileMediaVideo.fromJson(Map<String, dynamic> json) {
    return ProfileMediaVideo(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      url: (json['url'] ?? json['video'] ?? '').toString(),
    );
  }
}

class UserFullProfile {
  final int id;
  final String fullName;
  final String email;
  final String profilePicture;
  final int totalFavorites;
  final int totalInterested;
  final int totalBlocks;

  final String bio;
  final String gender;
  final String age;
  final String height;
  final String weight;
  final String work;
  final String country;
  final String state;
  final String city;
  final List<ProfileMediaImage> allImages;
  final ProfileMediaVideo? userVideo;
  final List<ProfileCategory> categories;

  UserFullProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.profilePicture,
    required this.totalFavorites,
    required this.totalInterested,
    required this.totalBlocks,
    this.bio = '',
    this.gender = '',
    this.age = '',
    this.height = '',
    this.weight = '',
    this.work = '',
    this.country = '',
    this.state = '',
    this.city = '',
    this.allImages = const [],
    this.userVideo,
    this.categories = const [],
  });

  factory UserFullProfile.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawImages = (json['all_images'] as List?) ?? [];
    final dynamic rawVideo = json['user_video'];
    final List<dynamic> rawCategories = (json['categories'] as List?) ?? [];

    return UserFullProfile(
      // id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      id: int.tryParse((json['id'] ?? json['user_id'])?.toString() ?? '0') ?? 0,
      fullName: (json['full_name'] ?? json['name'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      // RN stores just the raw filename/path here too (Upload_Images is
      // prepended in the UI, same as ProfileScreen._fullUrl does below).
      profilePicture: json['profile_picture']?.toString() ?? '',
      totalFavorites:
      int.tryParse(json['total_favorites']?.toString() ?? '0') ?? 0,
      totalInterested:
      int.tryParse(json['total_interested']?.toString() ?? '0') ?? 0,
      totalBlocks:
      int.tryParse(json['total_blocks']?.toString() ?? '0') ?? 0,
      bio: json['bio']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      height: json['height']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      work: json['work']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      allImages: rawImages
          .whereType<Map>()
          .map((e) => ProfileMediaImage.fromJson(e.cast<String, dynamic>()))
          .toList(),
      userVideo: (rawVideo is Map)
          ? ProfileMediaVideo.fromJson(rawVideo.cast<String, dynamic>())
          : null,
      categories: rawCategories
          .whereType<Map>()
          .map((e) => ProfileCategory.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

// class UserFullProfile {
//   final int id;
//   final String fullName;
//   final String email;
//   final String profilePicture;
//   final int totalFavorites;
//   final int totalInterested;
//   final int totalBlocks;
//
//   UserFullProfile({
//     required this.id,
//     required this.fullName,
//     required this.email,
//     required this.profilePicture,
//     required this.totalFavorites,
//     required this.totalInterested,
//     required this.totalBlocks,
//   });
//
//   factory UserFullProfile.fromJson(Map<String, dynamic> json) {
//     return UserFullProfile(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       fullName: (json['full_name'] ?? json['name'])?.toString() ?? '',
//       email: json['email']?.toString() ?? '',
//       // RN stores just the raw filename/path here too (Upload_Images is
//       // prepended in the UI, same as ProfileScreen._fullUrl does below).
//       profilePicture: json['profile_picture']?.toString() ?? '',
//       totalFavorites:
//       int.tryParse(json['total_favorites']?.toString() ?? '0') ?? 0,
//       totalInterested:
//       int.tryParse(json['total_interested']?.toString() ?? '0') ?? 0,
//       totalBlocks:
//       int.tryParse(json['total_blocks']?.toString() ?? '0') ?? 0,
//     );
//   }
// }