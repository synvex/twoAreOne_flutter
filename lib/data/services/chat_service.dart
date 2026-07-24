import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:two_are_one/data/models/chat_history_model.dart';
import 'package:two_are_one/data/models/chat_member_model.dart';

class ChatService {
  final String baseUrl = "https://www.twoareone.love/api";

  Future<List<ChatHistoryModel>> fetchChatHistory({
    required int receiverId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/user/messages/one-to-one-chat-histories.php?receiver_id=$receiverId",
        ),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": token,
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/messages/chat-members.php"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": token,
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user/messages/send.php"),

        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-api-key": token,
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"receiver_id": receiverId, "message": message}),
      );
      print("******************************");
      print("Send Message Response: ${response.body}");
      print(response);

      final data = jsonDecode(response.body);

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

  // Future<Map<String, dynamic>> markMessagesRead({
  //   required int partnerId,
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('auth_token') ?? '';
  //   try {
  //     final response = await http.post(
  //       Uri.parse("$baseUrl/user/messages/mark_messages_read.php"),

  //       headers: {
  //         "Accept": "application/json",
  //         "Content-Type": "application/json",
  //         "x-api-key": token,
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonEncode({"partner_id": partnerId}),
  //     );

  //     print(response);

  //     final data = jsonDecode(response.body);

  //     if (data is Map<String, dynamic>) {
  //       return data;
  //     }

  //     return {};
  //   } catch (e) {
  //     debugPrint("❌ markMessagesRead Error: $e");
  //     rethrow;
  //   }
  // }
}
