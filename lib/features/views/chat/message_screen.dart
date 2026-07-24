import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/constants/app_icons.dart';
import 'package:two_are_one/core/utils/date_time_formater.dart';
import 'package:two_are_one/data/models/chat_member_model.dart';
import 'package:two_are_one/data/services/chat_service.dart';
import 'package:two_are_one/data/viewmodels/chat_viewmodel.dart';
import 'package:two_are_one/features/views/chat/chat_screen.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    // Call API when screen opens
    Future.microtask(() {
      context.read<ChatViewModel>().getChatMembers();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _viewModel = context.read<ChatViewModel>();
      await _viewModel.getChatMembers();
      _viewModel.searchChatMembers(_searchController.text);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = context.watch<ChatViewModel>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
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
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: GestureDetector(
                        //     onTap: () async {
                        //       await chatViewModel.getChatMembers();
                        //     },
                        //     child: SvgPicture.asset(
                        //       AppIcons.vert_more,
                        //       colorFilter: ColorFilter.mode(
                        //         AppColors.background,
                        //         BlendMode.srcIn,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    TextFormField(
                      controller: _searchController,
                      onChanged: (value) {
                        chatViewModel.searchChatMembers(value);
                      },
                      style: GoogleFonts.poltawskiNowy(
                        fontSize: 14,

                        fontWeight: FontWeight(400),
                        color: AppColors.background,
                      ),
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
              padding: EdgeInsets.only(bottom: 90.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36.r),
                  topRight: Radius.circular(36.r),
                ),
              ),
              child: Consumer<ChatViewModel>(
                builder: (context, viewModel, child) {
                  return viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.chatMembers.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet',
                            style: GoogleFonts.roboto(fontSize: 14),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                itemCount: viewModel.chatSearch.isNotEmpty
                                    ? viewModel.chatSearch.length
                                    : viewModel.chatMembers.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final item = viewModel.chatSearch.isNotEmpty
                                      ? viewModel.chatSearch[index]
                                      : viewModel.chatMembers[index];

                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          receiverId: int.parse(
                                            item.userId.toString(),
                                          ),
                                          name: item.fullName.toString(),
                                          avatarUrl: item.profilePicture
                                              .toString(),
                                          statusText: item.isOnline == true
                                              ? "Online"
                                              : "Offline",
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
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              50.r,
                                            ),
                                            child: Image(
                                              image: NetworkImage(
                                                item.profilePicture.toString(),
                                              ),
                                              width: 48.w,
                                              height: 48.h,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      AppIcons.personIcon,
                                                      size: 32.sp,
                                                      color:
                                                          AppColors.grayColor,
                                                    );
                                                  },
                                            ),
                                          ),
                                          // CircleAvatar(
                                          //   radius: 24.r,
                                          //   backgroundImage: NetworkImage(
                                          //     item.profilePicture.toString(),
                                          //   ),
                                          // (avatarUrl != null &&
                                          //     avatarUrl.isNotEmpty)
                                          // ? NetworkImage(avatarUrl)
                                          // : const NetworkImage(
                                          //     'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDz5V_uTTpPqDGDazCOM2G3C8N8q30Cwoin05thNEcUknwnHfHN0RFs8xk&s=10',
                                          //   ),
                                          //),
                                          SizedBox(width: 10.w),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.fullName.toString(),
                                                style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                width: 150.w,
                                                child: Text(
                                                  maxLines: 1,
                                                  item.lastMessage.toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            children: [
                                              if (item.isOnline == true)
                                                CircleAvatar(
                                                  radius: 6.r,
                                                  backgroundColor:
                                                      AppColors.green,
                                                ),
                                              const Spacer(),
                                              Text(
                                                DateTimeFormatter.chatTime(
                                                  item.lastMessageTime
                                                      .toString(),
                                                ),
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
                              SizedBox(height: 50.h),
                            ],
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
