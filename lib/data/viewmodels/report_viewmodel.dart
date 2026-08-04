import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportViewModel with ChangeNotifier {
  String message = '';

  Future<bool> submitReport(int reportId, String reason, String comment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      print('Token: $token');

      final response = await http.post(
        Uri.parse('https://twoareone.love/api/user/report_user.php'),
        headers: {'x-api-key': token},
        body: jsonEncode({
          'reported_user_id': reportId.toString(),
          'reason': reason,
          'comment': comment,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}");

      final data = jsonDecode(response.body);

      message = data['message'] ?? 'Unknown response';

      notifyListeners();

      return response.statusCode == 200;
    } catch (e) {
      message = e.toString();
      notifyListeners();
      print(e);
      return false;
    }
  }
}
