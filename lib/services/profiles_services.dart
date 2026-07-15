

import 'dart:io';
import 'package:dio/dio.dart';
import 'Api_Helper/api_manager.dart';

class ProfileService {
  final ApiManager _api = ApiManager();

  // ── GET user/user-info.php (RN: GetUserInfoService) ─────────────────────
  Future<Map<String, dynamic>> getUserInfo() async {
    return await _api.fetch(
      Api(url: "user/user-info.php", method: "GET"),
      <String, dynamic>{},
    );
  }

  // ── POST user/update-profile-photo.php (RN: uploadUserProfilePictureService) ──
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

  // ── POST user/user-update-photos.php (RN: updateUserPhotoService) ───────
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

  // ── POST user/remove-photo.php (RN: removeUserPhotoService) ──────────────
  Future<bool> removeUserPhoto(int imageId) async {
    final res = await _api.fetch(
      Api(url: "user/remove-photo.php", method: "POST"),
      {"image_id": imageId},
    );
    return res['success'] == true;
  }

  // ── POST user/user-update-video.php (RN: updateUserVideoService) ────────
  Future<Map<String, dynamic>> addUserVideo(File file) async {
    final formData = FormData();
    formData.files.add(MapEntry(
      'video', // matches RN's formData.append("video", ...)
      await MultipartFile.fromFile(file.path),
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

//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
//
// import '../helpers/async_helpers.dart';
// import '../helpers/user_api.dart';
//
// class ProfileService {
//   // ── user/user-info.php ──────────────────────────────────────────────
//   Future<Map<String, dynamic>> getUserInfo() {
//     return ApiManager.fetch(UserApi.getUserInfo);
//   }
//
//   // ── user/update-profile-photo.php ───────────────────────────────────
//   Future<Map<String, dynamic>> uploadProfilePicture(File file) {
//     return ApiManager.uploadFile(
//       UserApi.uploadProfilePicture,
//       fieldName: 'profile_picture', // matches RN's formData key
//       file: file,
//     );
//   }
//
//   // ── user/user-update-photos.php ─────────────────────────────────────
//   Future<Map<String, dynamic>> addUserPhoto(File file) {
//     return ApiManager.uploadFile(
//       UserApi.addUserPhoto,
//       fieldName: 'image1', // matches RN's formData.append("image1", ...)
//       file: file,
//     );
//   }
//
//   // ── user/remove-photo.php ───────────────────────────────────────────
//   Future<bool> removeUserPhoto(int imageId) async {
//     final res = await ApiManager.fetch(
//       UserApi.removeUserPhoto,
//       parameters: {'image_id': imageId},
//     );
//     return res['success'] == true;
//   }
//
//   // ── user/user-update-video.php ──────────────────────────────────────
//   Future<Map<String, dynamic>> addUserVideo(File file) {
//     return ApiManager.uploadFile(
//       UserApi.addUserVideo,
//       fieldName: 'video', // matches RN's formData.append("video", ...)
//       file: file,
//     );
//   }
//
//   // ── user/remove-video.php ───────────────────────────────────────────
//   Future<bool> removeUserVideo(int videoId) async {
//     final res = await ApiManager.fetch(
//       UserApi.removeUserVideo,
//       parameters: {'video_id': videoId},
//     );
//     return res['success'] == true;
//   }
//
//   // ── user/update-profile-user.php ────────────────────────────────────
//   Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> payload) {
//     return ApiManager.fetch(UserApi.updateUserProfile, parameters: payload);
//   }
//
//   // ── user/delete-account.php ─────────────────────────────────────────
//   Future<bool> deleteAccount() async {
//     final res = await ApiManager.fetch(UserApi.deleteUser);
//     return res['success'] == true;
//   }
//
//   Future<void> logout() async {
//     try {
//       await ApiManager.fetch(AuthApi.logout);
//     } catch (_) {
//       // RN doesn't block clearing local session state on this succeeding.
//     }
//   }
// }
//
//
//
//
//
//
// class ApiManager {
//   ApiManager._();
//
//   // Matches RN's NetworkContants.js `ApiURL`.
//   static const String baseUrl = 'https://www.twoareone.love/api/';
//
//   static final http.Client _client = http.Client();
//
//   static void Function()? onSessionExpired;
//
//   // ── token ────────────────────────────────────────────────────────────
//
//   static Future<String?> getToken() => AsyncManager.fetch(AsyncKeys.accessToken);
//
//   /// Mirrors RN's `setUpRequestTokenAxios`.
//   static Future<void> setToken(String token) => AsyncManager.saveValue(AsyncKeys.accessToken, token);
//
//   /// Mirrors RN's `removeRequestTokenAxios` + `AsyncManager.clearAll()`,
//   /// which is what RN actually calls together on logout / session expiry.
//   static Future<void> removeToken() => AsyncManager.remove(AsyncKeys.accessToken);
//   static Future<void> logout() => AsyncManager.clearAll();
//
//   // ── requests ─────────────────────────────────────────────────────────
//
//   static Future<Map<String, String>> _headers({bool json = true}) async {
//     final token = await getToken();
//     return {
//       if (json) 'Content-Type': 'application/json',
//       if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
//       if (token != null && token.isNotEmpty) 'x-api-key': token,
//     };
//   }
//
//   static Future<Map<String, dynamic>> fetch(
//       ApiEndpoint api, {
//         Map<String, dynamic> parameters = const {},
//       }) async {
//     try {
//       final isGet = api.method == 'get';
//       final uri = Uri.parse('$baseUrl${api.path}').replace(
//         queryParameters: isGet && parameters.isNotEmpty
//             ? parameters.map((k, v) => MapEntry(k, '$v'))
//             : null,
//       );
//       final headers = await _headers();
//
//       final http.Response res = isGet
//           ? await _client.get(uri, headers: headers).timeout(const Duration(seconds: 30))
//           : await _client
//           .post(uri, headers: headers, body: jsonEncode(parameters))
//           .timeout(const Duration(seconds: 30));
//
//       return _handleResponse(res);
//     } on TimeoutException {
//       return const {'success': false, 'error': 'No response from server'};
//     } on SocketException {
//       return const {'success': false, 'error': 'Please check your internet connection'};
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//
//   /// Multipart upload — used by the profile-picture / photo / video
//   /// endpoints, which RN sends as `multipart/form-data` via FormData.
//   static Future<Map<String, dynamic>> uploadFile(
//       ApiEndpoint api, {
//         required String fieldName,
//         required File file,
//         Map<String, String> extraFields = const {},
//       }) async {
//     try {
//       final headers = await _headers(json: false);
//       final request = http.MultipartRequest('POST', Uri.parse('$baseUrl${api.path}'))
//         ..headers.addAll(headers)
//         ..fields.addAll(extraFields)
//         ..files.add(await http.MultipartFile.fromPath(fieldName, file.path));
//
//       final streamed = await request.send().timeout(const Duration(seconds: 30));
//       final res = await http.Response.fromStream(streamed);
//       return _handleResponse(res);
//     } on TimeoutException {
//       return const {'success': false, 'error': 'No response from server'};
//     } on SocketException {
//       return const {'success': false, 'error': 'Please check your internet connection'};
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//
//   static Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
//     Map<String, dynamic> body = const {};
//     try {
//       final parsed = jsonDecode(res.body);
//       if (parsed is Map) body = parsed.cast<String, dynamic>();
//     } catch (_) {
//       // Non-JSON body — treated as an empty envelope below.
//     }
//
//     final message = body['message']?.toString();
//
//     // Same condition RN's `handleApiError` checks before force-logging out.
//     final sessionExpired = res.statusCode == 401 ||
//         message == 'Invalid or expired token' ||
//         message == 'Invalid or expired token.' ||
//         message == 'Unauthorized';
//
//     if (sessionExpired) {
//       await removeToken();
//       await AsyncManager.clearAll();
//       onSessionExpired?.call();
//       return const {
//         'success': false,
//         'error': 'Session Expired. Please login again to continue.',
//         'sessionExpired': true,
//       };
//     }
//
//     final ok = res.statusCode >= 200 && res.statusCode < 300;
//     if (ok) {
//       return {'success': true, 'data': body['data'] ?? body};
//     }
//     return {'success': false, 'error': message ?? 'Something went wrong'};
//   }
// }
//
//
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:http_parser/http_parser.dart';
// //
// // // Matches RN's NetworkContants.js
// // const String kApiBaseUrl = "https://www.twoareone.love/api/";
// // const String kAccessTokenStorageKey = "ACCESS_TOKEN";
// //
// // class ProfileService {
// //   final http.Client _client;
// //   final FlutterSecureStorage _storage;
// //
// //   ProfileService({http.Client? client, FlutterSecureStorage? storage})
// //       : _client = client ?? http.Client(),
// //         _storage = storage ?? const FlutterSecureStorage();
// //
// //   Future<Map<String, String>> _authHeaders({bool json = true}) async {
// //     final token = await _storage.read(key: kAccessTokenStorageKey);
// //     return {
// //       if (json) 'Content-Type': 'application/json',
// //       'Cache-Control': 'no-cache',
// //       if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
// //       if (token != null && token.isNotEmpty) 'x-api-key': token,
// //     };
// //   }
// //
// //   Map<String, dynamic> _decode(http.Response res) {
// //     Map<String, dynamic> body = const {};
// //     try {
// //       final parsed = jsonDecode(res.body);
// //       if (parsed is Map) body = parsed.cast<String, dynamic>();
// //     } catch (_) {
// //       // Non-JSON body — fall through with an empty map.
// //     }
// //
// //     final ok = res.statusCode >= 200 && res.statusCode < 300;
// //     if (ok) {
// //       return {
// //         'success': true,
// //         'data': body['data'] ?? body,
// //       };
// //     }
// //     return {
// //       'success': false,
// //       'error': body['message']?.toString() ?? 'Something went wrong (${res.statusCode})',
// //     };
// //   }
// //
// //   Map<String, dynamic> _networkError(Object e) {
// //     return {
// //       'success': false,
// //       'error': 'Please check your internet connection',
// //     };
// //   }
// //
// //   // ── user/user-info.php ──────────────────────────────────────────────
// //   Future<Map<String, dynamic>> getUserInfo() async {
// //     try {
// //       final headers = await _authHeaders();
// //       final res = await _client
// //           .get(Uri.parse('${kApiBaseUrl}user/user-info.php'), headers: headers)
// //           .timeout(const Duration(seconds: 30));
// //       return _decode(res);
// //     } catch (e) {
// //       return _networkError(e);
// //     }
// //   }
// //
// //   // ── user/update-profile-photo.php ───────────────────────────────────
// //   Future<Map<String, dynamic>> uploadProfilePicture(File file) async {
// //     return _uploadFile(
// //       url: '${kApiBaseUrl}user/update-profile-photo.php',
// //       fieldName: 'profile_picture',
// //       file: file,
// //     );
// //   }
// //
// //   // ── user/user-update-photos.php ─────────────────────────────────────
// //   Future<Map<String, dynamic>> addUserPhoto(File file) async {
// //     return _uploadFile(
// //       url: '${kApiBaseUrl}user/user-update-photos.php',
// //       fieldName: 'image1', // matches RN's formData.append("image1", ...)
// //       file: file,
// //     );
// //   }
// //
// //   // ── user/user-update-video.php ──────────────────────────────────────
// //   Future<Map<String, dynamic>> addUserVideo(File file) async {
// //     return _uploadFile(
// //       url: '${kApiBaseUrl}user/user-update-video.php',
// //       fieldName: 'video',
// //       file: file,
// //     );
// //   }
// //
// //   Future<Map<String, dynamic>> _uploadFile({
// //     required String url,
// //     required String fieldName,
// //     required File file,
// //   }) async {
// //     try {
// //       final headers = await _authHeaders(json: false);
// //       final request = http.MultipartRequest('POST', Uri.parse(url))
// //         ..headers.addAll(headers)
// //         ..files.add(await http.MultipartFile.fromPath(
// //           fieldName,
// //           file.path,
// //           contentType: MediaType('image', 'jpeg'),
// //         ));
// //       final streamed = await request.send().timeout(const Duration(seconds: 30));
// //       final res = await http.Response.fromStream(streamed);
// //       return _decode(res);
// //     } catch (e) {
// //       return _networkError(e);
// //     }
// //   }
// //
// //   // ── user/remove-photo.php ───────────────────────────────────────────
// //   Future<bool> removeUserPhoto(int imageId) async {
// //     final res = await _postJson(
// //       url: '${kApiBaseUrl}user/remove-photo.php',
// //       body: {'image_id': imageId},
// //     );
// //     return res['success'] == true;
// //   }
// //
// //   // ── user/remove-video.php ───────────────────────────────────────────
// //   Future<bool> removeUserVideo(int videoId) async {
// //     final res = await _postJson(
// //       url: '${kApiBaseUrl}user/remove-video.php',
// //       body: {'video_id': videoId},
// //     );
// //     return res['success'] == true;
// //   }
// //
// //   // ── user/update-profile-user.php ────────────────────────────────────
// //   Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> payload) async {
// //     return _postJson(
// //       url: '${kApiBaseUrl}user/update-profile-user.php',
// //       body: payload,
// //     );
// //   }
// //
// //   // ── user/delete-account.php ─────────────────────────────────────────
// //   Future<bool> deleteAccount() async {
// //     final res = await _postJson(url: '${kApiBaseUrl}user/delete-account.php', body: const {});
// //     return res['success'] == true;
// //   }
// //
// //   // ── auth/logout.php ─────────────────────────────────────────────────
// //   // Note: this only hits the remote endpoint, same as RN's `LogoutService`
// //   // call inside `handleLogout`. Clearing the locally-stored session/token
// //   // is done separately by `ApiManager.logout()` in the screen, exactly
// //   // like RN calls `AsyncManager.clearAll()` + `dispatch(LogOut())`
// //   // alongside this request rather than inside it.
// //   Future<void> logout() async {
// //     try {
// //       await _postJson(url: '${kApiBaseUrl}auth/logout.php', body: const {});
// //     } catch (_) {
// //       // RN ignores logout failures for the purpose of clearing local
// //       // session state too — best-effort only.
// //     }
// //   }
// //
// //   Future<Map<String, dynamic>> _postJson({
// //     required String url,
// //     required Map<String, dynamic> body,
// //   }) async {
// //     try {
// //       final headers = await _authHeaders();
// //       final res = await _client
// //           .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
// //           .timeout(const Duration(seconds: 30));
// //       return _decode(res);
// //     } catch (e) {
// //       return _networkError(e);
// //     }
// //   }
// // }