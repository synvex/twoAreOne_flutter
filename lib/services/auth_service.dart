import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:two_are_one/services/Api_Helper/api_manager.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl = 'https://twoareone.love/api';
  final ApiManager _api = ApiManager();
  Future<Map<String, dynamic>> checkPhoneExists({required String phoneNo}) async {
    try {
      final url = Uri.parse('https://twoareone.love/api/auth/verify-phone-no.php');
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
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};
    }
  }
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async
  {
    print("Initiating Firebase Phone Auth for: $phoneNumber");
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        print("Firebase Error: ${e.code} - ${e.message}");
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
      // We create a map and ensure no values are null
      final Map<String, String> bodyData = {
        'full_name': fullName,
        'email': email,
        'password': password,
        'age': age.toString(),
        'phone_no': phoneNo,
        'gender': gender ?? "",
        'location': location ?? "",
        'latitude': latitude ?? "",
        'longitude': longitude ?? "",
        'device_id': deviceId ?? "",
        'device_token': deviceToken ?? "",
        'country': country ?? "",
        'state': state ?? "",
        'city': city ?? "",
      };
      final response = await http.post(
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        url,
        body:bodyData,
      ).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};
    }
  }
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async
  {
    try {
      final url = Uri.parse('$baseUrl/auth/verify-otp.php');

      print("--- VERIFY EMAIL OTP ---");
      print("URL: $url");
      print("Email: $email, OTP: $otp");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': email, 'otp': otp}),
      ).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};    }
  }
  Future<Map<String, dynamic>> updateIntroduce({
    required String genderId,
    required String sexualityId,
  }) async
  {
    try {
      // 1. Updated to the correct endpoint path
      final url = Uri.parse('$baseUrl/user/update-user-profile.php');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? "0";
      final token  = prefs.getString('auth_token') ?? "";
      // 2. Swapped to application/json encoding configuration
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Accept': 'application/json',
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
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};    }
  }
  Future<Map<String, dynamic>> checkEmailExists({required String email}) async
  {
    try {
      // Replace with your actual endpoint for checking email existence
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
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};
      // return {'success': false, 'error': "Connection error: $e"};
    }
  }
  Future<Map<String, dynamic>> verifyEmailWithToken({required String otp, required String token}) async {
    try {
      final url = Uri.parse('$baseUrl/user/otp-verify-email.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // The Bearer token from Postman
        },
        body: jsonEncode({'otp': otp}),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};
      // return {'success': false, 'error': "Connection error: $e"};
    }
  }
  Future<Map<String, dynamic>> resendEmailOtp({required String email}) async {
    try {
      // Note: Adjust the URL path if your backend uses a different endpoint for resending
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
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};
      // return {'success': false, 'error': "Connection error: $e"};
    }
  }
  // Future<Map<String, dynamic>> login({
  //   required String email,
  //   required String password,
  // }) async
  // {
  //
  //   try {
  //     final url = Uri.parse('$baseUrl/auth/login.php');
  //
  //     // We use a Map for the body to match x-www-form-urlencoded
  //     final Map<String, String> credentials = {
  //       'email': email,
  //       'password': password,
  //     };
  //
  //     print("--- DEBUG LOGIN ---");
  //     print("Payload: $credentials");
  //     print("URL: $url");
  //     print("Email value: '$email'");
  //     print("Password value: '$password'");
  //     print("Email empty: ${email.isEmpty}");
  //     print("Password empty: ${password.isEmpty}");
  //
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json',
  //         'X-Requested-With': 'XMLHttpRequest', // Helps PHP identify AJAX requests
  //       },
  //       body: jsonEncode(credentials),
  //     ).timeout(const Duration(seconds: 60)); // 30s is usually enough
  //
  //     // Use a strict handler to check if PHP actually liked the password
  //     final result = _handleResponse(response);
  //
  //     if (result['success'] == true) {
  //       final responseBody = result['data'];      // full response body
  //       final userData = responseBody['data'];    // nested 'data' object inside
  //
  //       final token = userData?['api_token']?.toString() ??
  //           userData?['token']?.toString();
  //
  //       if (token != null) {
  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setString('auth_token', token);
  //         ApiManager.setUpRequestToken(token);
  //
  //         print("✅ Session Saved and ApiManager updated. Token Saved: $token");
  //
  //         final userId = userData?['user_id']?.toString();
  //         if (userId != null) {
  //           await prefs.setString('user_id', userId);
  //         }
  //
  //         print("✅ Session Saved: Token and ID stored.");
  //       } else {
  //         print("❌ Token not found in response.");
  //       }
  //     }
  //     // if (result['success'] == true) {
  //     //   final data = result['data'];
  //     //
  //     //   // Ensure the keys match exactly what your PHP returns
  //     //   // If your PHP returns 'api_token' change 'token' to 'api_token'
  //     //   if (data != null && data['token'] != null) {
  //     //     final prefs = await SharedPreferences.getInstance();
  //     //     await prefs.setString('auth_token', data['token'].toString());
  //     //
  //     //     // Save user_id (checking if it's 'id' or 'user_id' in your JSON)
  //     //     final userId = data['id'] ?? data['user_id'];
  //     //     if (userId != null) {
  //     //       await prefs.setString('user_id', userId.toString());
  //     //     }
  //     //
  //     //     print("✅ Session Saved: Token and ID stored.");
  //     //   }
  //     // }
  //
  //     return result;
  //   } catch (e) {
  //     if (e is SocketException) {
  //       return {'success': false, 'error': "no_internet"};
  //     } else if (e is TimeoutException) {
  //       return {'success': false, 'error': "timeout"};
  //     }
  //     return {'success': false, 'error': "something_went_wrong"};
  //     // print("❌ Connection Exception: $e");
  //     // return {'success': false, 'error': "Connection error: $e"};
  //   }
  // }

  // ✅ FIX 1: Login Data Nesting
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await _api.fetch(
      Api(url: "auth/login.php", method: "POST"),
      {'email': email, 'password': password},
    );

    if (res['success'] == true) {
      final userData = res['data']; // In your log, data is the object containing user info
      final token = userData['api_token']?.toString();

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_id', userData['user_id'].toString());
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
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};
      // return {'success': false, 'error': "Connection error: $e"};
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
      if (e is SocketException) {
        return {'success': false, 'error': "no_internet"};
      } else if (e is TimeoutException) {
        return {'success': false, 'error': "timeout"};
      }
      return {'success': false, 'error': "something_went_wrong"};
      // return {'success': false, 'error': "Connection error: $e"};
    }
  }

  // lib/services/auth_service.dart

  Future<Map<String, dynamic>> uploadFullProfile({
    required String height,
    required String weight,
    required String work,
    required String bio,
    required String gender,
    required String sexuality,
    File? profileImage,
    List<File> extraImages = const [],
    List<File> extraVideos = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? "0";

    // Create FormData (Multipart)
    final formData = FormData.fromMap({
      'user_id': userId,
      'screen_type': '2', // Crucial for backend routing
      'height': height,
      'weight': weight,
      'work': work,
      'bio': bio,
      'gender': gender,
      'sexuality': sexuality,
    });

    // ✅ FIX 1: Main Profile Picture Key
    if (profileImage != null) {
      formData.files.add(MapEntry(
        'profile_picture', // Must be this exact key
        await MultipartFile.fromFile(profileImage.path, filename: 'avatar.jpg'),
      ));
    }

    // ✅ FIX 2: Additional Images (image1, image2, image3...)
    for (int i = 0; i < extraImages.length; i++) {
      formData.files.add(MapEntry(
        'image${i + 1}',
        await MultipartFile.fromFile(extraImages[i].path, filename: 'extra_$i.jpg'),
      ));
    }

    // ✅ FIX 3: Video Key
    if (extraVideos.isNotEmpty) {
      formData.files.add(MapEntry(
        'video',
        await MultipartFile.fromFile(extraVideos[0].path, filename: 'intro_video.mp4'),
      ));
    }

    // Use fetchMultipart from your ApiManager
    return await _api.fetchMultipart(
        Api(url: "user/upload-user-info.php", method: "POST"),
        formData
    );
  }

  // Future<Map<String, dynamic>> uploadFullProfile({
  //   required String height,
  //   required String weight,
  //   required String work,
  //   required String bio,
  //   required String gender,
  //   required String sexuality,
  //   File? profileImage,
  //   List<File> extraImages = const [],
  // }) async
  // {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString('user_id') ?? "0";
  //
  //   final formData = FormData.fromMap({
  //     'user_id': userId,
  //     'screen_type': '2',
  //     'height': height,
  //     'weight': weight,
  //     'work': work,
  //     'bio': bio,
  //     'gender': gender,
  //     'sexuality': sexuality,
  //   });
  //
  //   // ✅ CRITICAL FIX: Match React Native key 'profile_picture'
  //   if (profileImage != null) {
  //     formData.files.add(MapEntry(
  //       'profile_picture',
  //       await MultipartFile.fromFile(profileImage.path, filename: 'profile.jpg'),
  //     ));
  //   }
  //   // ✅ Match RN keys: image1, image2...
  //   for (int i = 0; i < extraImages.length; i++) {
  //     formData.files.add(MapEntry(
  //       'image${i + 1}',
  //       await MultipartFile.fromFile(extraImages[i].path, filename: 'extra_$i.jpg'),
  //     ));
  //   }
  //   // Use ApiManager to handle the request
  //   return await _api.fetchMultipart(
  //       Api(url: "user/upload-user-info.php", method: "POST"),
  //       formData
  //   );
  // }
  Future<Map<String, dynamic>> updateProfileSetup({
    required String height,
    required String weight,
    required String work,
    required String bio,
    required String gender,      // ADD
    required String sexuality,   // ADD
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
          'Authorization': 'Bearer $token',
          'x-api-key': token,
        },
        body: json.encode({
          'user_id': userId,
          'height': height,
          'weight': weight,
          'work': work,
          'bio': bio,
          'gender': gender,        // ADD
          'sexuality': sexuality,  // ADD
          'screen_type': '2',
        }),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Future<Map<String, dynamic>> uploadProfileMedia({
    File? profileImage,
    List<File> additionalImages = const [],
    List<File> additionalVideos = const [],
  }) async
  {
    try {
      final url = Uri.parse('$baseUrl/user/update-user-profile.php');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? "0";
      final token  = prefs.getString('auth_token') ?? "";

      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['user_id']     = userId
        ..fields['screen_type'] = '2';   // same profile step, adds media

      // Main profile photo ──────────────────────────────────────────────────
      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',   // field name expected by the server
          // 'profile_picture',
          profileImage.path,
        ));
      }

      // Additional photos ───────────────────────────────────────────────────
      for (int i = 0; i < additionalImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'additional_images[$i]',  // server should accept array notation
          additionalImages[i].path,
        ));
      }

      // Videos ──────────────────────────────────────────────────────────────
      for (int i = 0; i < additionalVideos.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'videos[$i]',
          additionalVideos[i].path,
        ));
      }

      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 60)); // longer timeout for uploads
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _catchError(e);
    }
  }
  Map<String, dynamic> _catchError(Object e) {
    if (e is SocketException)  return {'success': false, 'error': "no_internet"};
    if (e is TimeoutException) return {'success': false, 'error': "timeout"};
    return {'success': false, 'error': "something_went_wrong"};
  }
Future<Map<String, String>> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  String deviceId = "";
  String deviceToken = ""; // Can be any unique identifier

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // Unique Android ID
      deviceToken = androidInfo.id; // Use same ID as token
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? const Uuid().v4();
      deviceToken = deviceId;
    }
  } catch (e) {
// Fallback: Generate random UUID

    deviceId = const Uuid().v4();
    deviceToken = deviceId;
  }

  return {
    'device_id': deviceId,
    'device_token': deviceToken,
  };
}
  Map<String, dynamic> _handleResponse(http.Response response) {
    print("=== SERVER RESPONSE ===");
    print("Status: ${response.statusCode}");
    print("SERVER BODY: ${response.body}"); // <--- ADD THIS
    print("Body: ${response.body}");
    dynamic responseData;

    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': "Invalid server response format."
      };
    }

    // 1. Check for standard Success codes
    if (response.statusCode == 200 || response.statusCode == 201) {

      // 2. CRITICAL: Check the JSON body for failure flags
      // We check for every possible way the backend might say "Invalid"
      if (responseData is Map) {
        final isError = responseData['error'] == true ||
            responseData['success'] == false ||
            responseData['status'] == 'failed' ||
            responseData['status'] == 'error';

        if (isError) {
          return {
            'success': false,
            'error': responseData['message'] ?? responseData['error_msg'] ?? "Invalid credentials"
          };
        }

        // If it's a map and no error flag found, it's a success
        return {'success': true, 'data': responseData};
      }

      return {'success': true, 'data': responseData};
    } else
    {
      // 3. Handle 400, 401, 500 etc
      String errorMsg = "Server Error";
      if (responseData is Map && responseData.containsKey('message')) {
        errorMsg = responseData['message'];
      }
      return {'success': false, 'error': errorMsg};
    }
  }
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    // await prefs.setString('user_id',token)
  }
}
