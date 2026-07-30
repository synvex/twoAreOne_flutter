import 'dart:async';

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
  final ScrollController scrollController = ScrollController();

  int _tempIdCounter = -1;

  bool isKeyboardVisible = false;

  Timer? _membersPollTimer;
  Timer? _historyPollTimer;
  int? _activeReceiverId;
  String _lastSearchQuery = '';

  // --- Polling control -----------------------------------------

  void startMembersPolling({Duration interval = const Duration(seconds: 5)}) {
    _membersPollTimer?.cancel();
    _membersPollTimer = Timer.periodic(
      interval,
      (_) => _silentRefreshMembers(),
    );
  }

  void startHistoryPolling(
    int receiverId, {
    Duration interval = const Duration(seconds: 3),
  }) {
    _activeReceiverId = receiverId;
    _historyPollTimer?.cancel();
    _historyPollTimer = Timer.periodic(
      interval,
      (_) => _silentRefreshHistory(receiverId),
    );
  }

  void stopMembersPolling() {
    _membersPollTimer?.cancel();
    _membersPollTimer = null;
  }

  void stopHistoryPolling() {
    _historyPollTimer?.cancel();
    _historyPollTimer = null;
    _activeReceiverId = null;
  }

  @override
  void dispose() {
    stopMembersPolling();
    stopHistoryPolling();
    scrollController.dispose();
    super.dispose();
  }

  // --- Silent refresh (no isLoading spinner, no jumpy UI) --------

  Future<void> _silentRefreshMembers() async {
    try {
      final latest = await _chatService.fetchChatMembers();
      chatMembers = latest;
      // Keep the filtered/search list live too, using whatever the
      // user currently has typed in the search field.
      searchChatMembers(_lastSearchQuery);
      notifyListeners();
    } catch (e) {
      debugPrint("Silent Members Refresh Error: $e");
    }
  }

  Future<void> _silentRefreshHistory(int receiverId) async {
    // Don't refresh over a message that's still sending/optimistic
    if (sendingMessageIds.isNotEmpty) return;
    try {
      final latest = await _chatService.fetchChatHistory(
        receiverId: receiverId,
      );

      final oldLastId = chatHistory.isNotEmpty ? chatHistory.last.id : null;
      final newLastId = latest.isNotEmpty ? latest.last.id : null;
      final hasNewMessage = oldLastId != newLastId;

      if (latest.length != chatHistory.length || hasNewMessage) {
        chatHistory = latest;
        notifyListeners();

        if (hasNewMessage) {
          scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Silent History Refresh Error: $e");
    }
  }

  // --- UI state helpers --------------------------------------------

  void onKeyboardChanged(bool visible, FocusNode messageFocusNode) {
    if (isKeyboardVisible == visible) return;

    isKeyboardVisible = visible;

    if (!visible && messageFocusNode.hasFocus) {
      messageFocusNode.unfocus();
    }

    notifyListeners();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void searchChatMembers(String query) {
    _lastSearchQuery = query;

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

  // --- Initial fetches -----------------------------------------------

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
      markMessagesAsRead(receiverId);
    } catch (e) {
      debugPrint("Chat Members Error: $e");
    } finally {
      isLoading = false;
      scrollToBottom();
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

    // Scroll to show the message you just sent
    scrollToBottom();

    try {
      final response = await _chatService.sendMessage(
        receiverId: receiverId,
        message: trimmed,
      );
      print('send sms response is ******');
      print(response);

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

  // --- Mark as read -----------------------------------------------

  Future<void> markMessagesAsRead(int partnerId) async {
    try {
      await _chatService.markMessagesRead(partnerId: partnerId);
    } catch (e) {
      debugPrint("Mark Messages Read Error: $e");
    }
  }
}
