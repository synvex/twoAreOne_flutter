import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/Error/api_error.dart';
import '../../end_points.dart';
import '../../repo/socket_service.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class Api {
  final String url;
  final String method;
  final Map<String, dynamic>? headers;

  Api({required this.url, required this.method, this.headers});
}

class ApiManager {
  static const String baseUrl = "https://www.----.--/api/";
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
    SocketService.instance.updateToken(token);
  }
  static Future<void> logout() async {
    _dio.options.headers.remove("Authorization");
    _dio.options.headers.remove("x-api-key");
    SocketService.instance.updateToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  static void removeRequestToken() {
    _dio.options.headers.remove("Authorization");
    _dio.options.headers.remove("x-api-key");
  }
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
      Api api, FormData formData, {
        void Function(int sent, int total)? onSendProgress, // NEW — optional
      }) async
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
        onSendProgress: onSendProgress,
      );

      return _parseSuccessResponse(response.data);
    } on DioException catch (e) {
      return _handleDioError(e, api, formData);
    }
  }

  Map<String, dynamic> _parseSuccessResponse(dynamic res) {
    if (res is! Map) {
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
    if (res.containsKey('success')) {
      success = res['success'] == true;
    } else if (res.containsKey('error')) {
      final err = res['error'];
      success = err == false || err == null || err == 0 || err == '';
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

    if (!isAuthRequest) {
      if (status == 401 || status == 403 ||
          message == "Invalid or expired token" ||
          message == "Invalid or expired token." ||
          message == "Unauthorized") {
        ApiManager.handleUnauthorized();
        return {
          "success": false,
          "error": null,
        };
      }
    }

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
    if (_sessionDialogShowing) return;
    final context = navigatorKey.currentContext;
    if (context == null) return;
    _sessionDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Future.delayed(const Duration(seconds: 3), () {
        //
        // });
        _sessionDialogShowing = false;
        // Navigator.of(dialogContext).pop();
        Navigator.of(dialogContext).pushNamedAndRemoveUntil(
          '/login',
              (route) => false,
        );
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

class Api_Manager {
  Api_Manager._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  static final Api_Manager instance = Api_Manager._internal();
  final String _baseUrl = 'https://www.twoareone.love/api/';
  late final Dio _dio;
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _dio.options.headers['x-api-key'] = token;
  }
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    _dio.options.headers.remove('x-api-key');
  }
  Future<Response<dynamic>> fetch(
      ApiRequest request, {
        Map<String, dynamic>? parameters,
      }) async
  {
    try {
      final response = await _dio.request(
        request.url,
        data: request.method != ApiMethod.get ? parameters : null,
        queryParameters: request.method == ApiMethod.get ? parameters : null,
        options: Options(
          method: request.method.name.toUpperCase(),
          headers: request.headers,
        ),
      );
      return response;
    } on DioException catch (error) {
      throw await _mapError(error, request, parameters);
    }
  }
  Future<ApiError> _mapError(
      DioException error,
      ApiRequest request,
      Map<String, dynamic>? parameters,
      ) async
  {
    final status = error.response?.statusCode;
    final message = error.response?.data is Map
        ? error.response?.data['message']?.toString()
        : null;

    // ── Token expired / invalid ────────────────────────────────────────
    if (status == 401 ||
        message == 'Invalid or expired token' ||
        message == 'Invalid or expired token.' ||
        message == 'Unauthorized') {
      await _handleSessionExpired();
      return ApiError(
        title: 'Session Expired',
        message: 'Please login again to continue.',
        response: error.response,
      );
    }
    // ── Network error ──────────────────────────────────────────────────
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return ApiError(
        title: 'No internet',
        message: 'Please check your internet connection',
        isNetworkError: true,
        response: error.response,
        retryAction: () => fetch(request, parameters: parameters),
        alertActionButton: 'Retry',
      );
    }
    return ApiError(
      title: 'Server response',
      message: message ?? error.message ?? 'Something went wrong',
      response: error.response,
      alertActionButton: 'Ok',
    );
  }

  Future<void> _handleSessionExpired() async {
    clearAuthToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // AuthSessionManager.instance.notifySessionExpired();
  }
}