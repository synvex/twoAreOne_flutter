import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api_Helper/api_manager.dart';

class HomeService {
  final ApiManager _api = ApiManager();
  static Future<void> restoreTokenOnBoot() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      ApiManager.setUpRequestToken(token);
    }
  }
  Future<Map<String, dynamic>> getMatchProfiles(int page) async {
    return await _api.fetch(
      Api(url: "user/user-profile-match.php?page=$page&per_page=20", method: "POST"),
      {},
    );
  }
  Future<Map<String, dynamic>> getMatchProfilesWithFilter(
      Map<String, dynamic> body) async
  {
    return await _api.fetch(
      Api(url: "user/user-profile-match.php?page=1&per_page=20", method: "POST"),
      body,
    );
  }
  Future<bool> toggleFavorite(int id, bool currentlyFav) async {
    final endpoint = currentlyFav
        ? 'user/user-unfavourite.php'
        : 'user/user-add-favourite.php';
    final res = await _api.fetch(
      Api(url: endpoint, method: "POST"),
      {"profile_user_id": id},
    );
    return res['success'] == true;
  }
  Future<bool> toggleInterest(int id, bool currentlyInterested) async {
    final endpoint = currentlyInterested
        ? 'user/user-uninterest.php'
        : 'user/user-add-interest.php';
    final res = await _api.fetch(
      Api(url: endpoint, method: "POST"),
      {"profile_user_id": id},
    );
    return res['success'] == true;
  }

  Future<bool> blockUser(int id) async {
    final res = await _api.fetch(
      Api(url: "user/user-add-block-profile.php", method: "POST"), // ✅ was user-block.php
      {"profile_user_id": id},
    );
    return res['success'] == true;
  }
  Future<Map<String, dynamic>> getUserInfo() async {
    return await _api.fetch(
      Api(url: "user/user-info.php", method: "POST"),
      {},
    );
  }
  Future<Map<String, dynamic>> getUserDetail(int userId) async {
    return await _api.fetch(
      Api(url: "user/detail.php", method: "GET"),
      {"user_id": userId},
    );
  }
  // Matches RN AddUserVisitedService: POST user/visited/add.php
  Future<Map<String, dynamic>> addVisitedUser(int userId) async {
    return await _api.fetch(
      Api(url: "user/visited/add.php", method: "POST"),
      {"visited_user_id": userId},
    );
  }
  Future<Map<String, dynamic>> uploadProfileMedia({
    required String userId,
    required String height,
    required String weight,
    required String work,
    required String bio,
    String? profilePicturePath,
    String? videoPath,
    List<String> imagePaths = const [],
  }) async
  {
    final formData = FormData();
    formData.fields.addAll([
      MapEntry('screen_type', '2'),
      MapEntry('user_id', userId),
      MapEntry('height', height),
      MapEntry('weight', weight),
      MapEntry('work', work),
      MapEntry('bio', bio),
    ]);

    if (profilePicturePath != null)   {
      formData.files.add(MapEntry(
        'profile_picture', // ✅ must match RN field name
        await MultipartFile.fromFile(profilePicturePath),
      ));
    }

    if (videoPath != null) {
      formData.files.add(MapEntry(
        'video',
        await MultipartFile.fromFile(videoPath),
      ));
    }

    for (int i = 0; i < imagePaths.length; i++) {
      formData.files.add(MapEntry(
        'image${i + 1}', // ✅ image1..image6 to match RN
        await MultipartFile.fromFile(imagePaths[i]),
      ));
    }

    return await _api.fetchMultipart(
      Api(url: "user/upload-user-info.php", method: "POST"),
      formData,
    );
  }
}
