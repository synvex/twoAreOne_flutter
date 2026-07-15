// models/user_profile_model.dart
// Central model that accumulates all user data across screens.
// This is the single source of truth passed between screens and sent to the API.

import 'dart:io';

class UserProfileModel {
  // --- Screen 1: MainScreen (Gender/Sexuality Preferences) ---
  String? gender;       // e.g. "male" / "female"
  String? sexuality;    // e.g. "male" / "female"

  // --- Screen 2: ProfileSetupScreen ---
  File? profileImage;
  List<File> additionalImages;
  List<File> additionalVideos;
  String? height;       // e.g. "5'9"
  String? weight;       // e.g. "150 lbs"
  String? work;
  String? bio;

  // --- Cached server data (populated after successful API calls) ---
  // Stored here so downstream screens can read it without re-fetching.
  String? location;     // filled by a location screen later

  UserProfileModel({
    this.gender,
    this.sexuality,
    this.profileImage,
    List<File>? additionalImages,
    List<File>? additionalVideos,
    this.height,
    this.weight,
    this.work,
    this.bio,
    this.location,
  })  : additionalImages = additionalImages ?? [],
        additionalVideos = additionalVideos ?? [];

  /// Returns a copy of this model with the given fields overridden.
  UserProfileModel copyWith({
    String? gender,
    String? sexuality,
    File? profileImage,
    List<File>? additionalImages,
    List<File>? additionalVideos,
    String? height,
    String? weight,
    String? work,
    String? bio,
    String? location,
  }) {
    return UserProfileModel(
      gender: gender ?? this.gender,
      sexuality: sexuality ?? this.sexuality,
      profileImage: profileImage ?? this.profileImage,
      additionalImages: additionalImages ?? this.additionalImages,
      additionalVideos: additionalVideos ?? this.additionalVideos,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      work: work ?? this.work,
      bio: bio ?? this.bio,
      location: location ?? this.location,
    );
  }

  @override
  String toString() => 'UserProfileModel('
      'gender: $gender, sexuality: $sexuality, '
      'height: $height, weight: $weight, '
      'work: $work, bio: $bio, '
      'images: ${additionalImages.length}, videos: ${additionalVideos.length})';
}