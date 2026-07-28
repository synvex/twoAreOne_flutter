import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/constants/app_icons.dart';
import 'package:two_are_one/core/utils/date_time_formater.dart';
import 'package:two_are_one/core/utils/random_color_picker_util.dart';
import 'package:two_are_one/core/utils/skelton_util.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
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

    _viewModel = context.read<ChatViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.getChatMembers();
      _viewModel.searchChatMembers(_searchController.text);

      // Start live polling for the member list
      if (mounted) {
        _viewModel.startMembersPolling();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.stopMembersPolling();
    _searchController.dispose();
    super.dispose();
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
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 20.w,
                  vertical: 20.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messages',
                      style: GoogleFonts.poltawskiNowy(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.background,
                      ),
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
                            AppIcons.chat_search,
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
                      ? ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return SkeletonEffect.chatTile();
                          },
                        )
                      : viewModel.chatMembers.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () async {
                            await viewModel.getChatMembers();
                            viewModel.searchChatMembers(_searchController.text);
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 200.h),
                              Center(
                                child: Text(
                                  'No messages yet',
                                  style: GoogleFonts.roboto(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await viewModel.getChatMembers();
                            viewModel.searchChatMembers(_searchController.text);
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50.r),
                                              child: Image(
                                                image: NetworkImage(
                                                  item.profilePicture
                                                      .toString(),
                                                ),
                                                width: 48.w,
                                                height: 48.h,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      final bgColor =
                                                          RandomColorPickerUtil.getColor(
                                                            item.fullName
                                                                .toString(),
                                                          );
                                                      return CircleAvatar(
                                                        radius: 24.r,
                                                        backgroundColor:
                                                            bgColor,
                                                        child: Center(
                                                          child: Text(
                                                            item.fullName
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty
                                                                ? item.fullName
                                                                      .toString()
                                                                      .trim()[0]
                                                                      .toUpperCase()
                                                                : "?",
                                                            style:
                                                                GoogleFonts.inter(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),

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
                                                      fontWeight:
                                                          FontWeight.w500,
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
////////////////
///
///import 'package:flutter/material.dart';

/// A reusable shimmer effect wrapper.
/// Wrap any widget tree in this to make it "shimmer" (loading skeleton effect).
