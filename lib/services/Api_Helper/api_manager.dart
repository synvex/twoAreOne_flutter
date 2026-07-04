import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

// We use a NavigatorKey to show Alerts/Dialogs without a BuildContext
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Api {
  final String url;
  final String method;
  final Map<String, dynamic>? headers;

  Api({required this.url, required this.method, this.headers});
}
class ApiManager {
  static const String baseUrl = "https://www.twoareone.love/api/";

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
  ));

  static void setUpRequestToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
    _dio.options.headers["x-api-key"] = token;
  }
  // ✅ FIX: Clear headers AND local storage
  static Future<void> logout() async {
    _dio.options.headers.remove("Authorization");
    _dio.options.headers.remove("x-api-key");
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  // lib/services/Api_Helper/api_manager.dart

  Future<Map<String, dynamic>> fetch(Api api, dynamic parameters) async {
    try {
      Response response = await _dio.request(
        api.url,
        data: api.method == "POST" ? parameters : null,
        queryParameters: api.method == "GET" ? parameters : null,
        options: Options(method: api.method),
      );

      final res = response.data;
      debugPrint("RAW API RESPONSE [${api.url}]: $res");

      // ✅ SENIOR FIX: More robust success detection
      // Match API doesn't always send "error: false", so we check for the presence of data
      bool isErrorExplicit = res['error'] == true || res['success'] == false;
      bool hasData = res['data'] != null;
      bool success = hasData && !isErrorExplicit;

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
        "error": res['message'] // Pass the server message as the error text
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }
  // Future<Map<String, dynamic>> fetch(Api api, dynamic parameters) async {
  //   try {
  //     Response response = await _dio.request(
  //       api.url,
  //       data: api.method == "POST" ? parameters : null,
  //       queryParameters: api.method == "GET" ? parameters : null,
  //       options: Options(method: api.method),
  //     );
  //
  //     final res = response.data;
  //     // Senior Fix: Backend sends 'error: false' for success
  //     bool success = res['error'] == false || res['success'] == true;
  //
  //     return {
  //       "success": success,
  //       "data": res['data'],
  //       "total_count": res['total_count'],
  //       "per_page": res['per_page'],
  //       "message": res['message'],
  //     };
  //   } on DioException catch (e) {
  //     return _handleDioError(e);
  //   }
  // }

  // Use this for the profile setup images
  Future<Map<String, dynamic>> fetchMultipart(Api api, FormData formData) async {
    try {
      Response response = await _dio.post(api.url, data: formData);
      return {"success": response.data['error'] == false,
        "data": response.data['data'],
        "message": response.data['message']
      };
    } on DioException catch (e) { return _handleDioError(e); }
  }

  Map<String, dynamic> _handleDioError(DioException error) {
    if (error.response?.statusCode == 401) {
      _showSessionExpiredDialog();
      logout();
    }
    return {"success": false, "error": error.response?.data?['message'] ?? "Network Error"};
  }
  void _showSessionExpiredDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false, // User must click OK
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Session Expired"),
          content: const Text("Your session has timed out. Please login again to continue."),
          actions: [
            TextButton(
              onPressed: () {
                // 1. Close dialog
                Navigator.of(context).pop();

                // 2. Clear token from Dio and SharedPreferences
                ApiManager.removeRequestToken(); // You should have this method

                // 3. Redirect to Login Screen (Match your route name)
                // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text("OK", style: TextStyle(color: Color(0xFF77153C), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  static void removeRequestToken() {
    _dio.options.headers.remove("Authorization");
    _dio.options.headers.remove("x-api-key");
  }
}
