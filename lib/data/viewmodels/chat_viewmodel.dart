import 'dart:async';

import 'package:flutter/material.dart';
import 'package:two_are_one/data/models/chat_history_model.dart';
import 'package:two_are_one/data/services/socket_service.dart';
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

  // ids of messages whose socket send failed — kept in the list and
  // shown as "Failed", same behavior as the RN ChatScreen.
  final Set<int> failedMessageIds = {};

  final ScrollController scrollController = ScrollController();

  int _tempIdCounter = -1;

  bool isKeyboardVisible = false;

  Timer? _membersPollTimer;
  String _lastSearchQuery = '';

  // --- Socket (real-time chat history) -----------------------------

  VoidCallback? _socketUnsubscribe;
  int? _activeChatReceiverId;

  // Global dedup set, mirrors RN's module-level `processedMessageIds`
  // with a 30s self-cleanup window.
  final Set<int> _processedMessageIds = {};

  /// Subscribes this viewmodel to the global socket for a given
  /// conversation. Call once when the chat screen opens.
  /// Replaces the old startHistoryPolling().
  ///
  int get unreadConversationCount {
    return chatMembers.where((e) => (e.unreadCount ?? 0) > 0).length;
  }

  int get totalUnreadMessages {
    return chatMembers.fold(0, (sum, e) => sum + (e.unreadCount ?? 0));
  }

  void startListening(int receiverId) {
    _activeChatReceiverId = receiverId;
    _socketUnsubscribe?.call();
    _socketUnsubscribe = SocketService.instance.addListener(
      (data) => _handleSocketMessage(data, receiverId),
    );

    // Make sure the global socket is actually connected — mirrors RN's
    // useFocusEffect(() => reconnect()) on the chat screen.
    SocketService.instance.connect();
  }

  /// Unsubscribes from the socket. Call when the chat screen closes.
  /// Does NOT disconnect the global socket — other screens (presence,
  /// unread badges) still need it, same as RN.
  /// Replaces the old stopHistoryPolling().
  void stopListening() {
    _socketUnsubscribe?.call();
    _socketUnsubscribe = null;
    _activeChatReceiverId = null;
  }

  void _handleSocketMessage(Map<String, dynamic> data, int chatUserId) {
    if (data['action'] != 'new_message') return;

    final msgId = _toInt(data['id']);
    final senderId = _toInt(data['user1']);
    final receiverId = _toInt(data['user2']);

    // Hard dedup — same as RN's processedMessageIds Set with 30s cleanup.
    if (_processedMessageIds.contains(msgId)) return;
    _processedMessageIds.add(msgId);
    Timer(const Duration(seconds: 30), () {
      _processedMessageIds.remove(msgId);
    });

    // Conversation relevance check — only handle messages that belong
    // to the conversation this viewmodel is currently open for.
    if (senderId != chatUserId && receiverId != chatUserId) return;

    final messageText = (data['message'] ?? '').toString();
    final epochSeconds = data['time'];
    final messageTime = epochSeconds != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (_toInt(epochSeconds)) * 1000,
          ).toIso8601String()
        : 'Just now';

    // Try to replace a matching optimistic ("sending") bubble first —
    // matched by text, exactly like RN (temp_id is sent but not actually
    // used for matching on the RN side either).
    final idx = chatHistory.indexWhere(
      (m) => sendingMessageIds.contains(m.id) && m.message == messageText,
    );

    if (idx != -1) {
      final old = chatHistory[idx];
      sendingMessageIds.remove(old.id);
      failedMessageIds.remove(old.id);

      chatHistory[idx] = ChatHistoryModel(
        id: msgId,
        user1: senderId,
        user2: receiverId,
        message: messageText,
        isSticker: old.isSticker,
        isPhoto: old.isPhoto,
        stickerId: old.stickerId,
        time: _toInt(epochSeconds),
        isFirst: old.isFirst,
        isSeen1: old.isSeen1,
        isSeen2: old.isSeen2,
        isVideo: old.isVideo,
        isNew: old.isNew,
        isSeen: old.isSeen,
        senderName: old.senderName,
        senderProfilePicture: old.senderProfilePicture,
        receiverName: old.receiverName,
        receiverProfilePicture: old.receiverProfilePicture,
        messageTime: messageTime,
        senderProfilePictureUrl: old.senderProfilePictureUrl,
        receiverProfilePictureUrl: old.receiverProfilePictureUrl,
      );
    } else {
      chatHistory.add(
        ChatHistoryModel(
          id: msgId,
          user1: senderId,
          user2: receiverId,
          message: messageText,
          isSticker: 0,
          isPhoto: 0,
          stickerId: 0,
          time: _toInt(epochSeconds),
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
          messageTime: messageTime,
          senderProfilePictureUrl: '',
          receiverProfilePictureUrl: '',
        ),
      );
    }

    notifyListeners();
    scrollToBottom();
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  void dispose() {
    stopMembersPolling();
    stopListening();
    scrollController.dispose();
    super.dispose();
  }

  // --- Members polling (unchanged — RN's chat-list screen uses a
  // different mechanism entirely, out of scope for this migration) ---

  void startMembersPolling({Duration interval = const Duration(seconds: 5)}) {
    _membersPollTimer?.cancel();
    _membersPollTimer = Timer.periodic(
      interval,
      (_) => _silentRefreshMembers(),
    );
  }

  void stopMembersPolling() {
    _membersPollTimer?.cancel();
    _membersPollTimer = null;
  }

  Future<void> _silentRefreshMembers() async {
    try {
      final latest = await _chatService.fetchChatMembers();
      chatMembers = latest;
      searchChatMembers(_lastSearchQuery);
      notifyListeners();
    } catch (e) {
      debugPrint("Silent Members Refresh Error: $e");
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
        scrollController.position.minScrollExtent,
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

  // --- Initial fetches (still HTTP — unchanged) -----------------------

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

  /// Sends over the socket, not HTTP — matches the active RN
  /// handleSendMessage(). Optimistic bubble shows instantly; on socket
  /// send failure it's marked "failed" (not removed) and a reconnect
  /// is triggered, exactly like RN.
  void sendMessage({
    required int receiverId,
    required int currentUserId,
    required String message,
  }) {
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
    failedMessageIds.remove(tempId);
    notifyListeners();

    scrollToBottom();

    final sent = SocketService.instance.sendMessage({
      "action": "send_message",
      "to": receiverId,
      "text": trimmed,
      "temp_id": tempId,
    });
    // try {
    //   final response = await _chatService.sendMessage(
    //     receiverId: receiverId,
    //     message: trimmed,
    //   );
    //   print('send sms response is ******');
    //   print(response);

    if (!sent) {
      debugPrint("Send Message Error: socket not open");
      SocketService.instance.reconnect();
      sendingMessageIds.remove(tempId);
      failedMessageIds.add(tempId);
      notifyListeners();
    }
  }

  // --- Mark as read (unchanged — RN also keeps this on HTTP) --------

  Future<void> markMessagesAsRead(int partnerId) async {
    try {
      await _chatService.markMessagesRead(partnerId: partnerId);
    } catch (e) {
      debugPrint("Mark Messages Read Error: $e");
    }
  }
}
