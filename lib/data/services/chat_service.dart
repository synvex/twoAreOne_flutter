import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:two_are_one/data/models/chat_history_model.dart';
import 'package:two_are_one/data/models/chat_member_model.dart';

class ChatService {
  final String baseUrl = "https://www.twoareone.love/api";
  final Dio _dio = Dio();

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "x-api-key": token,
      "Authorization": "Bearer $token",
    };
  }

  Future<List<ChatHistoryModel>> fetchChatHistory({
    required int receiverId,
  }) async {
    try {
      final response = await _dio.get(
        "$baseUrl/user/messages/one-to-one-chat-histories.php",
        queryParameters: {"receiver_id": receiverId},
        options: Options(headers: await _headers()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print("✅ Fetched ${data['data'].length} chat members successfully.");
        print("✅ Fetched chat history for receiverId $data");

        return (data['data'] as List)
            .map((e) => ChatHistoryModel.fromJson(e))
            .toList();
      } else {
        print("**************************");
        throw Exception("Failed to fetch chat members: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("fetchChatMembers Error: $e");
      rethrow;
    }
  }

  // ============================================================
  // GET CHAT MEMBERS
  // ============================================================

  Future<List<ChatMemberModel>> fetchChatMembers() async {
    try {
      final response = await _dio.get(
        "$baseUrl/user/messages/chat-members.php",
        options: Options(headers: await _headers()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print("✅ Fetched ${data['data'].length} chat members successfully.");

        return (data['data'] as List)
            .map((e) => ChatMemberModel.fromJson(e))
            .toList();
      } else {
        throw Exception("Failed to fetch chat members: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("fetchChatMembers Error: $e");
      rethrow;
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        "$baseUrl/user/messages/send.php",
        options: Options(headers: await _headers()),
        data: {"receiver_id": receiverId, "message": message},
      );

      print("******************************");
      print("Send Message Response: ${response.data}");
      print(response);

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    } catch (e) {
      debugPrint("❌ sendMessage Error: $e");
      rethrow;
    }
  }

  // ============================================================
  // MARK MESSAGE READ
  // ============================================================

  Future<Map<String, dynamic>> markMessagesRead({
    required int partnerId,
  }) async {
    try {
      final response = await _dio.post(
        "$baseUrl/user/messages/mark_messages_read.php",
        options: Options(headers: await _headers()),
        data: {"partner_id": partnerId},
      );

      print(response);

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    } catch (e) {
      debugPrint("❌ markMessagesRead Error: $e");
      rethrow;
    }
  }
}
