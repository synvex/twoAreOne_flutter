import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'Api_Helper/api_manager.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl = 'https://www.twoareone.love/api';
  final ApiManager _api = ApiManager();
  Future<Map<String, dynamic>> checkPhoneExists({required String phoneNo}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/verify-phone-no.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'phone_no': phoneNo}),
      ).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async
  {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        debugPrint("Firebase Error: ${e.code} - ${e.message}");
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 120),
    );
  }
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
    required int age,
    required String phoneNo,
    String? gender,
    required String location,
    String? latitude,
    String? longitude,
    String? deviceId,
    String? deviceToken,
    String? country,
    String? state,
    String? city,
  }) async
  {
    try {
      final url = Uri.parse('$baseUrl/auth/register.php');
      final Map<String, String> bodyData = {
        'full_name': fullName,
        'email': email,
        'password': password,
        'age': age.toString(),
        'phone_no': phoneNo,
        'gender': gender ?? "",
        'location': location,
        'latitude': latitude ?? "",
        'longitude': longitude ?? "",
        'device_id': deviceId ?? "",
        'device_token': deviceToken ?? "",
        'country': country ?? "",
        'state': state ?? "",
        'city': city ?? "",
      };
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: bodyData,
      ).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
    required bool isFromForget,
  }) async
  {
    try {
      final url = Uri.parse('$baseUrl/auth/verify-otp.php');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': email, 'otp': otp}),
      ).timeout(const Duration(seconds: 60));

      final result = _handleResponse(response);

      if (result['success'] == true) {
        // Server response is nested: result['data']['data'] holds the
        // actual user payload.
        final responseBody = result['data'];
        final actualData = responseBody is Map ? responseBody['data'] : null;

        if (actualData != null) {
          final token = actualData['api_token']?.toString();
          final userId = actualData['user_id']?.toString();

          if (token != null && token.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            if(isFromForget== false){
              await prefs.setString('auth_token', token);
            }

            if (userId != null) {
              await prefs.setString('user_id', userId);
            }

            ApiManager.setUpRequestToken(token);
          }
        }
      }

      return result;
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> updateIntroduce({
    required String genderId,
    required String sexualityId,
  }) async
  {
    try {
      final url = Uri.parse('$baseUrl/user/update-user-profile.php');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? "0";
      final token = prefs.getString('auth_token') ?? "";

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': token,
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': userId,
          'gender': genderId,
          'sexuality': sexualityId,
          'age_from': '18',
          'age_to': '70',
          'screen_type': '1',
        }),
      ).timeout(const Duration(seconds: 35));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> checkEmailExists({required String email}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/verify-email.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> verifyEmailWithToken({
    required String otp,
    required String token,
  }) async
  {
    try {
      final url = Uri.parse('$baseUrl/user/otp-verify-email.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otp': otp}),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> resendEmailOtp({required String email}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/resend-otp.php');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async
  {
    final res = await _api.fetch(
      Api(url: "auth/login.php", method: "POST"),
      {'email': email, 'password': password},
    );

    if (res['success'] == true) {
      final userData = res['data'];
      final token = userData is Map ? userData['api_token']?.toString() : null;

      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (userData['user_id'] != null) {
          await prefs.setString('user_id', userData['user_id'].toString());
        }
        ApiManager.setUpRequestToken(token);
      }
    }
    return res;
  }
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/forgotpassword.php');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async
  {
    try {
      final url = Uri.parse('$baseUrl/auth/reset-password.php');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          'email': email,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      ).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> uploadFullProfile({
    required String height,
    required String weight,
    required String work,
    required String bio,
    String? gender,
    String? sexuality,
    File? profileImage,
    List<File> extraImages = const [],
    List<File> extraVideos = const [],
  }) async
  {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? "0";
    final token = prefs.getString('auth_token') ?? "";

    if (token.isEmpty) {
      return {
        'success': false,
        'error': 'API Token not found. Please log in again.'
      };
    }

    final formData = FormData.fromMap({
      'user_id': userId,
      'screen_type': '2', // Crucial for backend routing
      'height': height,
      'weight': weight,
      'work': work,
      'bio': bio,
    });

    if (profileImage != null) {
      formData.files.add(MapEntry(
        'profile_picture', // FIX: must match RN's field name exactly
        await MultipartFile.fromFile(profileImage.path, filename: 'avatar.jpg'),
      ));
    }

    for (int i = 0; i < extraImages.length; i++) {
      formData.files.add(MapEntry(
        'image${i + 1}', // FIX: image1..image6, matches RN
        await MultipartFile.fromFile(extraImages[i].path,
            filename: 'extra_$i.jpg'),
      ));
    }

    if (extraVideos.isNotEmpty) {
      formData.files.add(MapEntry(
        'video', // FIX: matches RN's single "video" field
        await MultipartFile.fromFile(extraVideos[0].path,
            filename: 'intro_video.mp4'),
      ));
    }

    return await _api.fetchMultipart(
      Api(
        url: "user/upload-user-info.php", // FIX: was update-user-profile.php in a duplicate/dead method; this is the correct, single upload path now.
        method: "POST",
        headers: {
          'Authorization': 'Bearer $token',
          'x-api-key': token,
        },
      ),
      formData,
    );
  }
  Map<String, dynamic> _catchError(Object e) {
    if (e is SocketException) return {'success': false, 'error': "no_internet"};
    if (e is TimeoutException) return {'success': false, 'error': "timeout"};
    return {'success': false, 'error': "something_went_wrong"};
  }
  Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    String deviceId = "";
    String deviceToken = "";

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceToken = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? const Uuid().v4();
        deviceToken = deviceId;
      }
    } catch (e) {
      deviceId = const Uuid().v4();
      deviceToken = deviceId;
    }

    return {
      'device_id': deviceId,
      'device_token': deviceToken,
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      debugPrint("=== SERVER RESPONSE (${response.request?.url}) ===");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
    }

    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': "Invalid server response format."};
    }

    if (response.statusCode == 401) {
      ApiManager.handleUnauthorized();
      return {
        'success': false,
        'error': 'Session expired. Please login again.',
        'isSessionExpired': true,
      };
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData is Map) {
        final isError = responseData['error'] == true ||
            responseData['success'] == false ||
            responseData['status'] == 'failed' ||
            responseData['status'] == 'error';

        if (isError) {
          return {
            'success': false,
            'error': responseData['message'] ??
                responseData['error_msg'] ??
                "Invalid credentials"
          };
        }
        return {'success': true, 'data': responseData};
      }
      return {'success': true, 'data': responseData};
    } else {
      String errorMsg = "Server Error";
      if (responseData is Map && responseData.containsKey('message')) {
        errorMsg = responseData['message'];
      }
      return {'success': false, 'error': errorMsg};
    }
  }
}
