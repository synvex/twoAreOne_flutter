import 'package:flutter/material.dart';
import 'package:two_are_one/data/models/chat_history_model.dart';
import '../models/chat_member_model.dart';
import '../services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  bool isLoading = false;

  List<ChatMemberModel> chatMembers = [];
  List<ChatHistoryModel> chatHistory = [];
  List<ChatMemberModel> chatSearch = [];

  // ids (temp negative ids) of messages currently being sent
  final Set<int> sendingMessageIds = {};

  int _tempIdCounter = -1;

  void searchChatMembers(String query) {
    if (query.trim().isEmpty) {
      chatSearch = List.from(chatMembers);
    } else {
      chatSearch = chatMembers.where((member) {
        final name = (member.fullName ?? "").toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

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

  /// Adds the message to the list immediately (optimistic), then sends it.
  /// On success the "sending" flag is cleared in place — no list refresh.
  /// On failure the optimistic message is removed.
  Future<void> sendMessage({
    required int receiverId,
    required int currentUserId,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    final tempId = _tempIdCounter--;

    final optimisticMessage = ChatHistoryModel(
      id: tempId,
      user1: currentUserId,
      user2: receiverId,
      message: trimmed,
      isSticker: 0,
      isPhoto: 0,
      stickerId: 0,
      time: 0,
      isFirst: 0,
      isSeen1: 0,
      isSeen2: 0,
      isVideo: 0,
      isNew: 0,
      isSeen: 0,
      senderName: '',
      senderProfilePicture: '',
      receiverName: '',
      receiverProfilePicture: '',
      messageTime: 'Just now',
      senderProfilePictureUrl: '',
      receiverProfilePictureUrl: '',
    );

    chatHistory.add(optimisticMessage);
    sendingMessageIds.add(tempId);
    notifyListeners();

    try {
      await _chatService.sendMessage(receiverId: receiverId, message: trimmed);

      // Success: just stop showing "sending..." for this message.
      // (If your API response includes the real saved message/id,
      // you can replace optimisticMessage in the list with it here.)
      sendingMessageIds.remove(tempId);
    } catch (e) {
      debugPrint("Send Message Error: $e");
      // Failed: drop the optimistic bubble (or mark it "failed" instead if you prefer).
      chatHistory.removeWhere((m) => m.id == tempId);
      sendingMessageIds.remove(tempId);
    } finally {
      notifyListeners();
    }
  }
}
