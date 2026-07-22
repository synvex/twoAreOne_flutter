import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/constants/app_icons.dart';
import 'package:two_are_one/data/services/chat_service.dart';

/// Simple model for a chat message.
/// type: 'text' or 'voice'
/// isMe: true -> sent by current user (grey bubble, right aligned)
///       false -> received (pink gradient bubble, left aligned with avatar)
class _ChatMessage {
  final String type;
  final bool isMe;
  final String? text;
  final String time;

  _ChatMessage({
    required this.type,
    required this.isMe,
    required this.time,
    this.text,
  });

  /// 🔧 Adjust these keys to match your real API's JSON field names
  factory _ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required int currentUserId,
  }) {
    final senderId = json['sender_id'] ?? json['from_id'];
    return _ChatMessage(
      type: json['type'] ?? 'text',
      isMe: senderId != null && senderId.toString() == currentUserId.toString(),
      text: json['message'] ?? json['text'] ?? '',
      time: json['time'] ?? json['created_at'] ?? json['sent_at'] ?? '',
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.receiverId,
    this.name = 'Ronda',
    this.avatarUrl =
        'https://thumbs.dreamstime.com/b/profile-beautiful-smiling-girl-6243612.jpg',
    this.statusText = 'Online 45 mins ago',
  });

  final int receiverId;
  final String name;
  final String avatarUrl;
  final String statusText;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  ChatService? _chatService;
  int? _currentUserId;

  List<_ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // 🔧 `getInt` returns null if 'user_id' was ever stored as a String
    // elsewhere in the app (e.g. prefs.setString('user_id', '123')).
    // Fall back to reading it as a string and parsing it, so isMe
    // comparisons don't silently break just because of a type mismatch.
    _currentUserId =
        prefs.getInt('user_id') ??
        int.tryParse(prefs.getString('user_id') ?? '');

    debugPrint('🔑 token: ${token != null ? "present" : "MISSING"}');
    debugPrint('🔑 currentUserId: $_currentUserId');

    if (token == null || token.isEmpty) {
      // Calling authenticated endpoints without a token is a common reason
      // "nothing loads" — surface this clearly instead of a generic error.
      setState(() {
        _isLoading = false;
        _messages = [];
        _errorMessage = 'Not logged in (no auth token found).';
      });
      return;
    }

    _chatService = ChatService(token: token);
    await _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (_chatService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final history = await _chatService!.fetchChatHistory(
        receiverId: widget.receiverId,
      );

      debugPrint('📨 fetchChatHistory returned ${history.length} item(s)');

      final parsed = history
          .whereType<Map<String, dynamic>>()
          .map(
            (e) =>
                _ChatMessage.fromJson(e, currentUserId: _currentUserId ?? -1),
          )
          .toList();

      setState(() {
        _messages = parsed;
        _isLoading = false;
      });
    } catch (e) {
      // Show the *real* error instead of a generic message — this is the
      // single most useful thing for figuring out what's actually wrong
      // (auth failure, wrong field names, network issue, etc). Check the
      // console too: ChatService prints the raw JSON response above this.
      debugPrint('❌ _fetchHistory error: $e');
      setState(() {
        _errorMessage = 'Failed to load chat: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatService == null || _isSending) return;

    setState(() => _isSending = true);

    // Optimistically add to UI first
    final optimisticMessage = _ChatMessage(
      type: 'text',
      isMe: true,
      text: text,
      time: 'Now',
    );
    setState(() {
      _messages.add(optimisticMessage);
    });
    _messageController.clear();

    try {
      await _chatService!.sendMessage(
        receiverId: widget.receiverId,
        message: text,
      );
    } catch (e) {
      debugPrint('❌ sendMessage error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [AppColors.mehroon, AppColors.blue],
              ),
            ),

            child: SafeArea(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            AppIcons.backIcon,
                            colorFilter: ColorFilter.mode(
                              AppColors.background,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Text(
                          'Chat',
                          style: GoogleFonts.poltawskiNowy(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.background,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _sendMessage();
                          },
                          child: SvgPicture.asset(
                            AppIcons.vert_more,
                            colorFilter: ColorFilter.mode(
                              AppColors.background,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      children: [
                        Container(
                          height: 60.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              widget.avatarUrl,
                              height: 60.h,
                              width: 60.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 35.sp,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: GoogleFonts.roboto(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.background,
                              ),
                            ),
                            Text(
                              widget.statusText,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.maxFinite,
              height: 600.h,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36.r),
                  topRight: Radius.circular(36.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(fontSize: 14),
                                  ),
                                  SizedBox(height: 12.h),
                                  TextButton(
                                    onPressed: _init,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'No chat available.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(fontSize: 14),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 20.h,
                            ),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 22.h),
                                child: msg.type == 'voice'
                                    ? _VoiceBubble(msg: msg)
                                    : _TextBubble(
                                        msg: msg,
                                        avatarUrl: widget.avatarUrl,
                                      ),
                              );
                            },
                          ),
                  ),
                  _MessageInputBar(
                    controller: _messageController,
                    onSend: _sendMessage,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.msg, required this.avatarUrl});

  final _ChatMessage msg;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: 0.68.sw),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: msg.isMe
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.mehroon.withValues(alpha: .8),
                  AppColors.chatGradientSecondary.withValues(alpha: .8),
                ],
              ),
        color: msg.isMe ? const Color(0xFFEFEFEF) : null,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomLeft: Radius.circular(msg.isMe ? 20.r : 20.r),
          bottomRight: Radius.circular(msg.isMe ? 20.r : 20.r),
        ),
      ),
      child: Text(
        msg.text ?? '',
        style: GoogleFonts.inriaSerif(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: msg.isMe ? Colors.black87 : Colors.white,
        ),
      ),
    );

    final timeLabel = Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Text(
        msg.time,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.grayColor,
        ),
      ),
    );

    if (msg.isMe) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [bubble, timeLabel],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.network(
            avatarUrl,
            height: 32.h,
            width: 32.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.person, size: 20.sp, color: AppColors.grayColor),
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [bubble, timeLabel],
        ),
      ],
    );
  }
}

class _VoiceBubble extends StatelessWidget {
  const _VoiceBubble({required this.msg});

  final _ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    final heights = List.generate(24, (i) {
      final values = [8, 16, 22, 12, 26, 10, 18, 24, 14, 20, 9, 17];
      return values[i % values.length].toDouble();
    });

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 0.78.sw),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 34.h,
                  width: 34.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: heights
                      .map(
                        (h) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                          width: 2.5.w,
                          height: h.h,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              msg.time,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 8.w),
            SvgPicture.asset(
              AppIcons.send_file,
              colorFilter: ColorFilter.mode(
                AppColors.grayColor,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Type your message',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.grayColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: onSend,
              child: Container(
                height: 44.h,
                width: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.mehroon.withValues(alpha: .8),
                      AppColors.chatGradientSecondary.withValues(alpha: .8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.0,
                  ),
                  child: GestureDetector(
                    onTap: onSend,
                    child: SvgPicture.asset('assets/svg_images/send_msg.svg'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
