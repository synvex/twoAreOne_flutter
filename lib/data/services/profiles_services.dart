import 'dart:io';
import 'package:dio/dio.dart';
import 'Api_Helper/api_manager.dart';

class ProfileService {
  final ApiManager _api = ApiManager();

  Future<Map<String, dynamic>> getUserInfo() async {
    return await _api.fetch(
      Api(url: "user/user-info.php", method: "GET"),
      <String, dynamic>{},
    );
  }

  Future<Map<String, dynamic>> uploadProfilePicture(File file) async {
    final formData = FormData();
    formData.files.add(MapEntry(
      'profile_picture', // matches RN's formData.append("profile_picture", ...)
      await MultipartFile.fromFile(file.path),
    ));
    return await _api.fetchMultipart(
      Api(url: "user/update-profile-photo.php", method: "POST"),
      formData,
    );
  }

  Future<Map<String, dynamic>> addUserPhoto(File file) async {
    final formData = FormData();
    formData.files.add(MapEntry(
      'image1', // matches RN's formData.append("image1", ...)
      await MultipartFile.fromFile(file.path),
    ));
    return await _api.fetchMultipart(
      Api(url: "user/user-update-photos.php", method: "POST"),
      formData,
    );
  }

  Future<bool> removeUserPhoto(int imageId) async {
    final res = await _api.fetch(
      Api(url: "user/remove-photo.php", method: "POST"),
      {"image_id": imageId},
    );
    return res['success'] == true;
  }

  Future<Map<String, dynamic>> addUserVideo(File file) async {
    final formData = FormData();
    formData.files.add(MapEntry(
      'video', // matches RN's formData.append("video", ...)
      await MultipartFile.fromFile(file.path,
        filename: file.path.split('/').last,),
    ));
    return await _api.fetchMultipart(
      Api(url: "user/user-update-video.php", method: "POST"),
      formData,
    );
  }

  // ── POST user/remove-video.php (RN: removeUserVideoService) ─────────────
  Future<bool> removeUserVideo(int videoId) async {
    final res = await _api.fetch(
      Api(url: "user/remove-video.php", method: "POST"),
      {"video_id": videoId},
    );
    return res['success'] == true;
  }

  // ── POST user/update-profile-user.php (RN: updateUserProfileService) ────
  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> payload) async {
    return await _api.fetch(
      Api(url: "user/update-profile-user.php", method: "POST"),
      payload,
    );
  }

  // ── POST user/delete-account.php (RN: deleteUserService) ────────────────
  Future<bool> deleteAccount() async {
    final res = await _api.fetch(
      Api(url: "user/delete-account.php", method: "POST"),
      {},
    );
    return res['success'] == true;
  }

  Future<void> logout() async {
    try {
      await _api.fetch(Api(url: "auth/logout.php", method: "POST"), {});
    } catch (_) {
      // Ignored on purpose — see note above.
    }
  }
}