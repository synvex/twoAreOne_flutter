import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportViewModel with ChangeNotifier {
  String message = '';
  bool isLoading = false;

  final Dio _dio = Dio();

  Future<bool> submitReport(int reportId, String reason, String comment) async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      print('Token: $token');

      final response = await _dio.post(
        'https://twoareone.love/api/user/report_user.php',
        data: {
          'reported_user_id': reportId.toString(),
          'reason': reason,
          'comment': comment,
        },
        options: Options(headers: {'x-api-key': token}),
      );

      print("Status Code: ${response.statusCode}");
      print("Response: ${response.data}");

      final data = response.data;

      message = data['message'] ?? 'Unknown response';

      notifyListeners();

      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response != null) {
        print("Status Code: ${e.response?.statusCode}");
        print("Response: ${e.response?.data}");

        message = e.response?.data['message'] ?? 'Something went wrong';
      } else {
        message = e.message ?? 'Network Error';
      }

      notifyListeners();
      return false;
    } catch (e) {
      message = e.toString();
      notifyListeners();
      print(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
