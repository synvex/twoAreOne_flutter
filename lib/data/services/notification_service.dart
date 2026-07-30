import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/data/models/notification_model.dart';

class NotificationService {
  final String baseUrl = "https://www.twoareone.love/api";
  final Dio _dio = Dio();

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await _dio.get(
        "$baseUrl/user/all-notifications.php",
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "x-api-key": token,
            "Authorization": "Bearer $token",
          },
        ),
      );

      print("******************************");
      print("Notifications Response: ${response.data}");
      print("******************************");

      if (response.statusCode == 200) {
        final data = response.data;
        print("✅ Fetched ${data['data'].length} chat members successfully.");
        print("✅ Fetched chat history for receiverId $data");

        return (data['data'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      } else {
        print("**************************");
        throw Exception(
          "Failed to fetch Notifications: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("fetch Notifications Error in service file: $e");
      rethrow;
    }
  }
}
