import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:two_are_one/data/models/chat_history_model.dart';
import 'package:two_are_one/data/models/chat_member_model.dart';

/// Service for all chat/messaging related endpoints under `/user/messages/*`
/// as defined in the twoareone_love Postman collection:
///
///   GET  /user/messages/receive.php
///   GET  /user/messages/one-to-one-chat-histories.php?receiver_id=
///   GET  /user/messages/chat-members.php
///   POST /user/messages/send.php
///   POST /user/messages/mark_messages_read.php
class ChatService {
  final Dio _dio;
  final String baseUrl = "https://www.twoareone.love/api";

  ChatService({String? token})
    : _dio = Dio(
        BaseOptions(
          baseUrl: "https://www.twoareone.love/api",
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            if (token != null) "Authorization": "Bearer $token",
            if (token != null) "x-api-key": token,
          },
        ),
      );

  // ---------------------------------------------------------------------
  // GET /user/messages/receive.php
  // ---------------------------------------------------------------------
  /// Fetch all received messages (inbox-style).
  Future<Map<String, dynamic>> fetchReceivedMessages() async {
    try {
      final response = await _dio.get("/user/messages/receive.php");
      _printResponse(response);

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {};
    } on DioException catch (e) {
      _printError(e);
      rethrow;
    } catch (e) {
      // Catches non-Dio errors too (e.g. a bad type cast if the backend's
      // JSON shape doesn't match what we expect) so failures are visible
      // instead of silently producing an empty result.
      print("❌ Unexpected error in ChatService: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------
  // GET /user/messages/one-to-one-chat-histories.php?receiver_id=
  // ---------------------------------------------------------------------
  /// Fetch one-to-one chat history with a specific user.
  Future<ChatHistoryModel> fetchChatHistory({required int receiverId}) async {
    try {
      final response = await _dio.get(
        "/user/messages/one-to-one-chat-histories.php",
        queryParameters: {"receiver_id": receiverId},
      );

      _printResponse(response);

      print("💬 Chat history for receiver_id=$receiverId: ${response.data}");

      return ChatHistoryModel.fromJson(response.data);
    } on DioException catch (e) {
      _printError(e);
      rethrow;
    } catch (e) {
      print("❌ Unexpected error in ChatService: $e");
      rethrow;
    }
  }

  /// Pulls a List of messages/members out of a variety of backend response
  /// shapes. Handles:
  ///   [ ... ]
  ///   { "data": [ ... ] }
  ///   { "data": { "messages": [ ... ] } }
  ///   { "data": { "chats": [ ... ] } }
  ///   { "data": { "history": [ ... ] } }
  ///   { "messages": [ ... ] }
  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      // common top-level list keys
      for (final key in ['data', 'messages', 'chats', 'history', 'result']) {
        final value = data[key];
        if (value is List) return value;
        if (value is Map) {
          for (final innerKey in ['messages', 'chats', 'history', 'list']) {
            final inner = value[innerKey];
            if (inner is List) return inner;
          }
        }
      }
    }

    // Nothing matched a known shape — log it so the real shape is visible
    // in the console instead of silently returning an empty list.
    print(
      "⚠️ ChatService: couldn't find a message list in response. "
      "Check the printed JSON above and adjust _extractList's keys to match.",
    );
    return [];
  }

  // ---------------------------------------------------------------------
  // GET /user/messages/chat-members.php
  // ---------------------------------------------------------------------
  /// Fetch the list of chat members / conversation threads
  /// (i.e. everyone the current user has an active chat with).
  // Only the relevant method is shown — keep the rest of your ChatService
  // class (constructor, _dio setup, _printResponse, _printError, other
  // methods) exactly as it is. Replace just fetchChatMembers with this.

  Future<List<ChatMemberModel>> fetchChatMembers() async {
    try {
      final response = await _dio.get("/user/messages/chat-members.php");

      _printResponse(response);

      print("💬 Chat members: ${response.data}");

      // Handle the common shapes a PHP endpoint might return:
      // 1) A raw JSON array:            [ {...}, {...} ]
      // 2) Wrapped under "data":        { "data": [ {...}, {...} ] }
      // 3) Wrapped under "chat_members": { "chat_members": [ {...}, {...} ] }
      final dynamic raw = response.data;
      late final List<dynamic> list;

      if (raw is List) {
        list = raw;
      } else if (raw is Map<String, dynamic>) {
        if (raw['data'] is List) {
          list = raw['data'] as List<dynamic>;
        } else if (raw['chat_members'] is List) {
          list = raw['chat_members'] as List<dynamic>;
        } else {
          // Fallback: single object response, wrap it in a list of one.
          list = [raw];
        }
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => ChatMemberModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      _printError(e);
      rethrow;
    } catch (e) {
      print("❌ Unexpected error in ChatService: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------
  // POST /user/messages/send.php
  // ---------------------------------------------------------------------
  /// Send a text message to a specific receiver.
  ///
  /// [type] is optional — the Postman collection's example body only
  /// contains `receiver_id` and `message`. Pass [type] only if your
  /// backend actually supports/expects it (e.g. 'text' | 'voice').
  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String message,
    String? type,
  }) async {
    try {
      final response = await _dio.post(
        "/user/messages/send.php",
        data: {
          "receiver_id": receiverId,
          "message": message,
          if (type != null) "type": type,
        },
      );

      _printResponse(response);

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {};
    } on DioException catch (e) {
      _printError(e);
      rethrow;
    } catch (e) {
      // Catches non-Dio errors too (e.g. a bad type cast if the backend's
      // JSON shape doesn't match what we expect) so failures are visible
      // instead of silently producing an empty result.
      print("❌ Unexpected error in ChatService: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------
  // POST /user/messages/mark_messages_read.php
  // ---------------------------------------------------------------------
  /// Mark all messages from a given chat partner as read.
  Future<Map<String, dynamic>> markMessagesRead({
    required int partnerId,
  }) async {
    try {
      final response = await _dio.post(
        "/user/messages/mark_messages_read.php",
        data: {"partner_id": partnerId},
      );

      _printResponse(response);

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {};
    } on DioException catch (e) {
      _printError(e);
      rethrow;
    } catch (e) {
      // Catches non-Dio errors too (e.g. a bad type cast if the backend's
      // JSON shape doesn't match what we expect) so failures are visible
      // instead of silently producing an empty result.
      print("❌ Unexpected error in ChatService: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------
  // Debug helpers
  // ---------------------------------------------------------------------
  // ---------------------------------------------------------------------
  // Debug helpers
  // ---------------------------------------------------------------------

  void _printResponse(Response response) {
    debugPrint("");
    debugPrint(
      "════════════════════════════════════════════════════════════════════",
    );
    debugPrint("✅ API RESPONSE");
    debugPrint("STATUS CODE : ${response.statusCode}");
    debugPrint("METHOD      : ${response.requestOptions.method}");
    debugPrint("URL         : ${response.requestOptions.uri}");

    if (response.requestOptions.queryParameters.isNotEmpty) {
      debugPrint("QUERY PARAMETERS:");
      _prettyPrintJson(response.requestOptions.queryParameters);
    }

    if (response.requestOptions.data != null) {
      debugPrint("REQUEST BODY:");
      _prettyPrintJson(response.requestOptions.data);
    }

    debugPrint("RESPONSE BODY:");
    _prettyPrintJson(response.data);

    debugPrint(
      "════════════════════════════════════════════════════════════════════",
    );
    debugPrint("");
  }

  void _printError(DioException e) {
    debugPrint("");
    debugPrint(
      "════════════════════════════════════════════════════════════════════",
    );
    debugPrint("❌ API ERROR");
    debugPrint("TYPE        : ${e.type}");
    debugPrint("METHOD      : ${e.requestOptions.method}");
    debugPrint("URL         : ${e.requestOptions.uri}");

    if (e.requestOptions.data != null) {
      debugPrint("REQUEST BODY:");
      _prettyPrintJson(e.requestOptions.data);
    }

    if (e.response != null) {
      debugPrint("STATUS CODE : ${e.response?.statusCode}");
      debugPrint("ERROR RESPONSE:");
      _prettyPrintJson(e.response?.data);
    } else {
      debugPrint("MESSAGE : ${e.message}");
    }

    debugPrint(
      "════════════════════════════════════════════════════════════════════",
    );
    debugPrint("");
  }

  void _prettyPrintJson(dynamic data) {
    try {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
      _printLongString(prettyJson);
    } catch (e) {
      _printLongString(data.toString());
    }
  }

  void _printLongString(String text) {
    const chunkSize = 800;

    for (int i = 0; i < text.length; i += chunkSize) {
      debugPrint(
        text.substring(
          i,
          i + chunkSize > text.length ? text.length : i + chunkSize,
        ),
      );
    }
  }
}
