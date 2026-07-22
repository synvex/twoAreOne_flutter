import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/constants/app_icons.dart';
import 'package:two_are_one/data/services/chat_service.dart';
import 'package:two_are_one/features/views/chat/chat_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  ChatService? chatService;

  List<dynamic> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('Loaded auth token: $token');

    setState(() {
      chatService = ChatService(token: token);
    });

    // ✅ Only fetch AFTER chatService is created
    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    if (chatService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await chatService!.fetchReceivedMessages();

      // 🔧 Adjust this line based on your API's real JSON shape.
      // Right now it tries a few common patterns automatically.
      List<dynamic> list = [];
      if (response["data"] is List) {
        list = response["data"] as List<dynamic>;
      } else if (response["messages"] is List) {
        list = response["messages"] as List<dynamic>;
      } else if (response["chats"] is List) {
        list = response["chats"] as List<dynamic>;
      }

      setState(() {
        _messages = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load messages";
        _isLoading = false;
      });
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Messages',
                            style: GoogleFonts.poltawskiNowy(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: SvgPicture.asset(
                              AppIcons.vert_more,
                              colorFilter: ColorFilter.mode(
                                AppColors.background,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Search user by name',
                        hintStyle: GoogleFonts.poltawskiNowy(
                          fontSize: 14,
                          fontWeight: FontWeight(400),
                          color: AppColors.background,
                        ),
                        filled: true,
                        prefixIcon: Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.chat_serach,
                            colorFilter: ColorFilter.mode(
                              AppColors.background,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.r),
                          borderSide: BorderSide(
                            color: AppColors.background,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.r),
                          borderSide: BorderSide(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                      ),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                    )
                  : _messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet',
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final item = _messages[index] as Map<String, dynamic>;

                        // 🔧 Adjust these keys to match your real API fields
                        final name =
                            item['name'] ??
                            item['sender_name'] ??
                            item['username'] ??
                            'Unknown';
                        final lastMessage =
                            item['last_message'] ??
                            item['message'] ??
                            item['preview'] ??
                            '';
                        final time =
                            item['time'] ??
                            item['created_at'] ??
                            item['sent_at'] ??
                            '';
                        final avatarUrl =
                            item['avatar'] ??
                            item['profile_image'] ??
                            item['image'];
                        final isOnline =
                            item['is_online'] == true || item['online'] == true;
                        final receiverId = item['receiver_id'] ?? item['id'];

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverId:
                                    int.tryParse(receiverId.toString()) ?? 0,
                                name: name.toString(),
                                avatarUrl:
                                    (avatarUrl != null &&
                                        avatarUrl.toString().isNotEmpty)
                                    ? avatarUrl.toString()
                                    : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDz5V_uTTpPqDGDazCOM2G3C8N8q30Cwoin05thNEcUknwnHfHN0RFs8xk&s=10',
                              ),
                            ),
                          ),
                          child: Container(
                            height: 60.h,
                            margin: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              top: 16.h,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24.r,
                                  backgroundImage:
                                      (avatarUrl != null &&
                                          avatarUrl.toString().isNotEmpty)
                                      ? NetworkImage(avatarUrl.toString())
                                      : const NetworkImage(
                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDz5V_uTTpPqDGDazCOM2G3C8N8q30Cwoin05thNEcUknwnHfHN0RFs8xk&s=10',
                                        ),
                                ),
                                SizedBox(width: 10.w),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.toString(),
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      lastMessage.toString(),
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  children: [
                                    if (isOnline)
                                      CircleAvatar(
                                        radius: 6.r,
                                        backgroundColor: AppColors.green,
                                      ),
                                    Spacer(),
                                    Text(
                                      time.toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
