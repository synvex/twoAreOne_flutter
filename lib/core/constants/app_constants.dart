/// Global constants ported from the RN `global/constants.js`.
class AppConstants {
  AppConstants._();

  /// Base host used to resolve API endpoints. Update to match your real
  /// backend host (RN's axios instance base URL was configured elsewhere
  /// and wasn't part of the provided files).
  static const String baseUrl = 'https://www.twoareone.love/';
  /// Ported 1:1 from RN `constants.js` -> `Upload_Images`.
  static const String uploadImagesUrl = 'https://www.twoareone.love/uploads/';

  static const int perPage = 10;
  static const int skeletonCount = 2;
}

