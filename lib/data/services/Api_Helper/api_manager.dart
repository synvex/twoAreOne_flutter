import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Api {
  final String url;
  final String method;
  final Map<String, dynamic>? headers;

  Api({required this.url, required this.method, this.headers});
}

class ApiManager {
  static const String baseUrl = "https://www.twoareone.love/api/";

  static bool _sessionDialogShowing = false;

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.181 Mobile Safari/537.36',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    },
  ));

  static void setUpRequestToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
    _dio.options.headers["x-api-key"] = token;
  }
  static Future<void> logout() async {
    _dio.options.headers.remove("Authorization");
    _dio.options.headers.remove("x-api-key");
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static void removeRequestToken() {
    _dio.options.headers.remove("Authorization");
    _dio.options.headers.remove("x-api-key");
  }

  /// Normalizes a path so it never produces a double slash when combined
  /// with [baseUrl] (which already ends in "/"). Fixes endpoints that were
  /// written with a leading "/" (e.g. "/user/user-add-block-profile.php").
  static String _normalize(String url) =>
      url.startsWith('/') ? url.substring(1) : url;

  Future<Map<String, dynamic>> fetch(Api api, dynamic parameters) async {
    try {
      final Response response = await _dio.request(
        ApiManager._normalize(api.url),
        data: api.method.toUpperCase() == "GET" ? null : parameters,
        queryParameters: api.method.toUpperCase() == "GET" ? parameters : null,
        options: Options(method: api.method, headers: api.headers,
          contentType: api.headers?['Content-Type'] ?? 'application/json',
        ),
      );
      return _parseSuccessResponse(response.data);
    } on DioException catch (e) {
      return _handleDioError(e, api, parameters);
    }
  }

  Future<Map<String, dynamic>> fetchMultipart(
      Api api, FormData formData) async
  {
    try {
      final options = Options(
        method: api.method,
        headers: {
          ..._dio.options.headers,
          if (api.headers != null) ...api.headers!,
          "Content-Type": "multipart/form-data",
        },
      );

      final Response response = await _dio.request(
        ApiManager._normalize(api.url),
        data: formData,
        options: options,
      );

      return _parseSuccessResponse(response.data);
    } on DioException catch (e) {
      return _handleDioError(e, api, formData);
    }
  }
  Map<String, dynamic> _parseSuccessResponse(dynamic res) {
    if (res is! Map) {
      // Defensive: some endpoints could return a bare list/string.
      return {
        "success": res != null,
        "data": res,
        "total_count": 0,
        "per_page": 20,
        "message": "",
        "error": null,
      };
    }

    bool success;
    if (res.containsKey('error')) {
      success = res['error'] == false;
    } else if (res.containsKey('success')) {
      success = res['success'] == true;
    } else {
      success = res['data'] != null;
    }

    dynamic processedData = res['data'];
    if (processedData is Map && processedData.containsKey('data')) {
      processedData = processedData['data'];
    }

    return {
      "success": success,
      "data": processedData,
      "total_count": res['total_count'] ?? 0,
      "per_page": res['per_page'] ?? 20,
      "message": res['message'] ?? "",
      "error": res['message'],
    };
  }

  Map<String, dynamic> _handleDioError(
      DioException error, Api api, dynamic parameters)
  {
    final status = error.response?.statusCode;
    final message = error.response?.data is Map
        ? error.response?.data['message']
        : null;
    final isAuthRequest = api.url.contains("auth/") ||
        api.url.contains("login") ||
        api.url.contains("register") ||
        api.url.contains("verify-otp") ||
        api.url.contains("forgotpassword") ||
        api.url.contains("reset-password") ||
        api.url.contains("otp-verify");

    // final isAuthRequest = api.url.contains("login.php") ||
    //
    //     api.url.contains("register.php") ||
    //     api.url.contains("verify-otp.php");
    // ✅ TOKEN EXPIRED / INVALID (mirrors RN's handleApiError 401 branch)

    if (!isAuthRequest) {
      if (status == 401 || status == 403 ||
        message == "Invalid or expired token" ||
        message == "Invalid or expired token." ||
        message == "Unauthorized") {
      ApiManager.handleUnauthorized();
      return {
        "success": false,
        "error": "Session expired. Please login again.",
        "isSessionExpired": true,
      };
    }}

    // ✅ NETWORK ERROR (no internet / can't reach server) — mirrors RN's
    // isNetworkError + retryAction so screens can offer a "Retry" button.
    final isNetworkError = error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.unknown;

    if (isNetworkError) {
      return {
        "success": false,
        "error": "Please check your internet connection",
        "isNetworkError": true,
        "title": "No internet",
      };
    }

    // ✅ OTHER SERVER ERRORS
    return {
      "success": false,
      "error": message ?? error.message ?? "Something went wrong",
      "isNetworkError": false,
    };
  }
  static void handleUnauthorized() {
    _showSessionExpiredDialogStatic();

    logout();
  }

  static void _showSessionExpiredDialogStatic() {
    // Guard against multiple 401s firing at once (e.g. several parallel
    // requests all expiring together) which used to stack dialogs and
    // trigger navigation twice.
    if (_sessionDialogShowing) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    _sessionDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Session Expired"),
          content: const Text(
              "Your session has timed out. Please login again to continue."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _sessionDialogShowing = false;
                Navigator.of(dialogContext).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                "OK",
                style: TextStyle(
                    color: Color(0xFF77153C), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      _sessionDialogShowing = false;
    });

  }
}
