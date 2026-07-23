import 'package:flutter/material.dart';
import 'package:two_are_one/data/models/chat_history_model.dart';
import '../models/chat_member_model.dart';
import '../services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatMemberModel> chatMembers = [];
  List<ChatHistoryModel> chatHistory = [];

  bool isLoading = false;

  Future<void> getChatMembers() async {
    try {
      isLoading = true;
      notifyListeners();

      chatMembers = await _chatService.fetchChatMembers();
    } catch (e) {
      debugPrint("Chat Members Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchedChatHistory(int receiverId) async {
    try {
      isLoading = true;
      notifyListeners();

      chatHistory = await _chatService.fetchChatHistory(receiverId: receiverId);
    } catch (e) {
      debugPrint("Chat Members Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<Map<String, dynamic>> sendMessage({
  //   required int receiverId,
  //   required String message,
  //   String? type,
  // }) async {
  //   try {
  //     isLoading = true;
  //     notifyListeners();

  //     final resp = await _chatService.sendMessage(
  //       receiverId: receiverId,
  //       message: message,
  //       type: type,
  //     );

  //     // Refresh history after sending
  //     await fetchedChatHistory(receiverId);

  //     return resp;
  //   } catch (e) {
  //     debugPrint("Send Message Error: $e");
  //     rethrow;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
