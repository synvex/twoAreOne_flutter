import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/constants/app_icons.dart';
import 'package:two_are_one/core/utils/date_time_formater.dart';
import 'package:two_are_one/core/utils/random_color_picker_util.dart';
import 'package:two_are_one/data/models/chat_history_model.dart';
import 'package:two_are_one/data/services/presense_service.dart';
import 'package:two_are_one/data/viewmodels/chat_viewmodel.dart';

/// Simple text-only chat message.
class _ChatMessage {
  final bool isMe;
  final String text;
  final String time;

  _ChatMessage({required this.isMe, required this.text, required this.time});

  static _ChatMessage? fromChatHistory(
    ChatHistoryModel data, {
    required int currentUserId,
  }) {
    final message = data.message;

    if (message == null || message.trim().isEmpty) {
      return null;
    }

    return _ChatMessage(
      isMe: data.user1 == currentUserId,
      text: message,
      time: data.messageTime,
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.name,
    required this.avatarUrl,
    required this.statusText,
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
  final FocusNode _focusNode = FocusNode();
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();

    // Call API when screen opens
    Future.microtask(() async {
      await _loadCurrentUser();
      await context.read<ChatViewModel>().fetchedChatHistory(widget.receiverId);

      // Start live polling for this conversation once initial history is loaded
      if (mounted) {
        context.read<ChatViewModel>().startHistoryPolling(widget.receiverId);
      }
    });
  }

  @override
  void dispose() {
    // Stop polling so it doesn't keep hitting the API after leaving the screen
    context.read<ChatViewModel>().stopHistoryPolling();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.get('user_id');

    setState(() {
      _currentUserId = userId is int
          ? userId
          : int.tryParse(userId.toString()) ?? 0;
    });
  }

  void _handleSend(ChatViewModel chatViewModel) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Clear field immediately — the message appears in the list right
    // away via the viewmodel's optimistic add, no waiting on the API.
    _messageController.clear();
    FocusScope.of(context).unfocus();

    chatViewModel.sendMessage(
      receiverId: widget.receiverId,
      currentUserId: _currentUserId,
      message: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<PresenceService>().isOnline(
      widget.receiverId,
    );
    final statusText = isOnline ? "Online" : "Offline";
    final chatViewModel = context.watch<ChatViewModel>();

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().onKeyboardChanged(
        keyboardVisible,
        _focusNode,
      );
    });
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gradientFirst,
                  AppColors.gradientSecond,
                  AppColors.gradientSecond,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: SvgPicture.asset(
                                AppIcons.backIcon,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.background,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),

                          Center(
                            child: Text(
                              "Chat",
                              style: GoogleFonts.poltawskiNowy(
                                fontSize: 24,
                                color: AppColors.background,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),
                    Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            widget.avatarUrl,
                            height: 60.h,
                            width: 60.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              final bgColor = RandomColorPickerUtil.getColor(
                                widget.name.toString(),
                              );
                              return CircleAvatar(
                                radius: 24.r,
                                backgroundColor: bgColor,
                                child: Center(
                                  child: Text(
                                    widget.name.toString().trim().isNotEmpty
                                        ? widget.name
                                              .toString()
                                              .trim()[0]
                                              .toUpperCase()
                                        : "?",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: GoogleFonts.roboto(
                                fontSize: 18.sp,
                                color: AppColors.background,
                              ),
                            ),
                            Text(
                              statusText,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _focusNode.hasFocus ? 500.h : 600.h,
              width: double.infinity,
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
                    child: chatViewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : chatViewModel.chatHistory.isEmpty
                        ? const Center(child: Text("No chat available"))
                        : ListView.builder(
                            controller: chatViewModel.scrollController,

                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: chatViewModel.chatHistory.length,
                            itemBuilder: (context, index) {
                              final raw = chatViewModel.chatHistory[index];

                              final chatMsg = _ChatMessage.fromChatHistory(
                                raw,
                                currentUserId: _currentUserId,
                              );

                              if (chatMsg == null) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: EdgeInsets.only(bottom: 20.h),
                                child: _TextBubble(
                                  isSending: chatViewModel.sendingMessageIds
                                      .contains(raw.id),
                                  msg: chatMsg,
                                  avatarUrl: widget.avatarUrl,
                                  name: widget.name,
                                ),
                              );
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,

                    child: _MessageInputBar(
                      controller: _messageController,
                      focusNode: _focusNode,
                      onSend: () => _handleSend(chatViewModel),
                    ),
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
  const _TextBubble({
    required this.msg,
    required this.avatarUrl,
    required this.isSending,
    required this.name,
  });

  final _ChatMessage msg;
  final String avatarUrl;
  final bool isSending;
  final String name;

  @override
  Widget build(BuildContext context) {
    final bubble = Column(
      crossAxisAlignment: msg.isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 0.68.sw),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: msg.isMe
                  ? [AppColors.grey1, AppColors.grey1]
                  : [
                      AppColors.mehroon.withValues(alpha: 0.8),
                      AppColors.gradientFirst.withValues(alpha: 0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            msg.text,
            style: GoogleFonts.inriaSerif(
              fontSize: 14.sp,
              color: msg.isMe ? Colors.black : Colors.white,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            DateTimeFormatter.chatTime(msg.time),
            style: GoogleFonts.inriaSerif(fontSize: 10.sp, color: Colors.grey),
          ),
        ),
        Visibility(
          visible: isSending,
          child: Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Text(
              'sending...',
              style: GoogleFonts.inriaSerif(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );

    if (msg.isMe) {
      return Align(alignment: Alignment.centerRight, child: bubble);
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
            errorBuilder: (_, __, ___) {
              final bgColor = RandomColorPickerUtil.getColor(name.toString());
              return CircleAvatar(
                radius: 14.r,
                backgroundColor: bgColor,
                child: Center(
                  child: Text(
                    name.toString().trim().isNotEmpty
                        ? name.toString().trim()[0].toUpperCase()
                        : "?",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 8.w),
        bubble,
      ],
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.onSend,
    required this.focusNode,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: "Type your message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.lightGray,
                suffixIcon: Container(
                  height: 46.h,
                  width: 46.w,
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gradientFirst.withValues(alpha: 0.7),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: onSend,
                      child: SvgPicture.asset(AppIcons.send_msg),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
