import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/divider.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/core/widgets/top_toast.dart';
import 'package:two_are_one/data/models/user_match_model.dart';
import 'package:two_are_one/data/services/home_service.dart';
import 'package:two_are_one/features/views/Interested/interrested_user_screen.dart';
import 'package:two_are_one/features/views/bottom_nav/custom_nav_bar.dart';
import 'package:two_are_one/features/views/chat/message_screen.dart';
import 'package:two_are_one/features/views/favourites/favourites_screen.dart';
import 'package:two_are_one/features/views/home/home_filter_screen.dart';
import 'package:two_are_one/features/views/home/profile_card.dart';
import 'package:two_are_one/features/views/notification/notification_screen.dart';
import 'package:two_are_one/features/views/visted_screen.dart';

const String kUploadImagesBase = "https://www.twoareone.love/uploads/";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeService _homeService = HomeService();
  final ScrollController _scrollController = ScrollController();
  String _userName = "Loading...";
  String _userEmail = "";
  String? _profileImageUrl;
  List<FilterMatchModel> _users = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  int _favCount = 0;
  int _interestedCount = 0;
  int _blockCount = 0;
  final Set<int> _loadingStars = {};
  final Set<int> _loadingHearts = {};
  final Set<int> _loadingBlocks = {};
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserInfo(); // ✅ load real name/email/counts
    _fetchProfiles(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final res = await _homeService.getUserInfo();
    if (res['success'] == true && mounted) {
      final data = res['data'] as Map<String, dynamic>? ?? {};
      setState(() {
        _userName = data['full_name']?.toString() ?? "User";
        _userEmail = data['email']?.toString() ?? "";

        String rawImage = data['profile_picture']?.toString() ?? '';

        // ✅ SENIOR FIX: If it ends in / (no filename), it's empty
        if (rawImage.endsWith('/uploads/') || rawImage.isEmpty) {
          _profileImageUrl = null;
        } else {
          // Only prefix if it's a raw filename
          _profileImageUrl = rawImage.startsWith('http')
              ? rawImage
              : 'https://www.twoareone.love/uploads/$rawImage';
        }

        _favCount =
            int.tryParse(data['total_favorites']?.toString() ?? '0') ?? 0;
        _interestedCount =
            int.tryParse(data['total_interested']?.toString() ?? '0') ?? 0;
        _blockCount =
            int.tryParse(data['total_blocks']?.toString() ?? '0') ?? 0;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMore) {
        _fetchProfiles();
      }
    }
  }

  Future<void> _fetchProfiles({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _isLoading = true;
        _users = []; // Clear list on refresh
      });
    } else {
      if (_isFetchingMore || !_hasMore) return;
      setState(() => _isFetchingMore = true);
    }

    final res = await _homeService.getMatchProfiles(_currentPage);
    if (!mounted) return;
    if (res['success'] == true) {
      final dynamic rawData = res['data'];

      if (rawData is List) {
        final List<FilterMatchModel> newUsers = rawData.map((u) {
          final model = FilterMatchModel.fromJson(u as Map<String, dynamic>);

          String fullPath = "";
          // ✅ Check both profile_picture (RN key) and imagePath
          String rawFile = model.imagePath.trim();

          if (rawFile.isNotEmpty && rawFile != "null") {
            fullPath = rawFile.startsWith('http')
                ? rawFile
                : "https://www.twoareone.love/uploads/$rawFile";
          }

          return model.copyWith(imagePath: fullPath);
        }).toList();
        setState(() {
          if (refresh) {
            _users = newUsers;
          } else {
            _users.addAll(newUsers);
          }

          _currentPage++;
          // ✅ Match pagination logic to res structure
          int total = int.tryParse(res['total_count']?.toString() ?? '0') ?? 0;
          _hasMore = _users.length < total && newUsers.isNotEmpty;
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    } else {
      debugPrint("API Error: ${res['error']}");
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  void _handleFavorite(FilterMatchModel user) async {
    setState(() => _loadingStars.add(user.id));
    final success = await _homeService.toggleFavorite(user.id, user.isFavorite);
    if (success && mounted) {
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          final wasTrue = _users[index].isFavorite;
          _users[index] = _users[index].copyWith(isFavorite: !wasTrue);
          _favCount += wasTrue ? -1 : 1;
        }
      });
    }
    setState(() => _loadingStars.remove(user.id));
  }

  void _handleInterest(FilterMatchModel user) async {
    setState(() => _loadingHearts.add(user.id));
    final success = await _homeService.toggleInterest(
      user.id,
      user.isInterested,
    );
    if (success && mounted) {
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          final wasTrue = _users[index].isInterested;
          _users[index] = _users[index].copyWith(isInterested: !wasTrue);
          _interestedCount += wasTrue ? -1 : 1;
        }
      });
    }
    setState(() => _loadingHearts.remove(user.id));
  }

  void _handleBlock(FilterMatchModel user) async {
    setState(() => _loadingBlocks.add(user.id));
    final success = await _homeService.blockUser(user.id);
    if (success && mounted) {
      setState(() {
        _blockCount++;
        // ✅ matches React Native: decrement if user was favorite/interested
        if (user.isFavorite) _favCount--;
        if (user.isInterested) _interestedCount--;
        _users.removeWhere((u) => u.id == user.id);
      });
      TopToast.show(context, title: "User blocked", type: ToastType.success);
    } else if (mounted) {
      TopToast.show(
        context,
        title: "Couldn't block user",
        message: "Please check your connection and try again.",
        type: ToastType.error,
      );
    }
    setState(() => _loadingBlocks.remove(user.id));
  }

  final Map<String, DateTime> _chatCooldowns = {};
  void _handleSilentChat(FilterMatchModel user) {
    final userId = user.id.toString();
    final now = DateTime.now();
    if (_chatCooldowns.containsKey(userId) &&
        now.difference(_chatCooldowns[userId]!).inSeconds < 60) {
      final left = 60 - now.difference(_chatCooldowns[userId]!).inSeconds;
      TopToast.show(
        context,
        title: "Please wait",
        message: "You can send another invite in ${left}s",
        type: ToastType.info,
      );
      return;
    }
    _chatCooldowns[userId] = now;
    // TODO: wire actual socket sendMessage() call here (RN: useChatSocket)
    TopToast.show(
      context,
      title: "Invite sent!",
      message: "Your message has been delivered.",
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: _buildDrawer(),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchProfiles(refresh: true),
                child: _isLoading
                    ? _buildSkeletonGrid()
                    : ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _buildActionBanner(),
                          const SizedBox(height: 20),
                          _buildSectionDivider("YOUR MATCHES"),
                          const SizedBox(height: 15),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return ProfileCard(
                                user: user,
                                isStarLoading: _loadingStars.contains(user.id),
                                isHeartLoading: _loadingHearts.contains(
                                  user.id,
                                ),
                                isBlockLoading: _loadingBlocks.contains(
                                  user.id,
                                ),
                                onStar: () => _handleFavorite(user),
                                onHeart: () => _handleInterest(user),
                                onDislike: () => _handleBlock(user),
                                // onChat: () => _handleSilentChat(user),
                                onRequestSend: () => _handleSilentChat(user),
                                onPress: () => Navigator.pushNamed(
                                  context,
                                  '/profile_detail',
                                  arguments: user,
                                ),
                              );
                            },
                          ),
                          if (_isFetchingMore)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            behavior: HitTestBehavior
                .opaque, // Ensures the entire slop area catches taps
            child: Padding(
              padding: const EdgeInsets.all(
                10.0,
              ), // Replicates hitSlop (top, bottom, left, right)
              child: SizedBox(
                width: 36.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Mimics React Native's left alignment
                  mainAxisSize:
                      MainAxisSize.min, // Wraps content tightly like a View
                  children: [
                    Container(
                      width: 22.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: AppColors.drawer,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    SizedBox(height: 5.h), // Replicates gap: 5
                    Container(
                      width: 15.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: AppColors.drawer,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 5), // Replicates gap: 5
                    Container(
                      width: 22.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: AppColors.drawer,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Images(imageStr: "assets/images/two_are_one.png", height: 35),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeFilterScreen()),
              );
            },
            child: Containers(
              hexValue: 0xFFFFFFFF,
              shape: BoxShape.circle,
              padding: const EdgeInsets.only(
                left: 12,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              border: Border.all(color: Colors.black45),
              child: Images(
                imageStr: "assets/svg_images/search.svg",
                height: 20.h,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {},
            child: Containers(
              hexValue: 0xFFFFFFFF,
              shape: BoxShape.circle,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              border: Border.all(color: Colors.black45),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                ),
                child: Images(
                  imageStr: "assets/svg_images/notification.svg",
                  height: 20.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // ✅ RN: diagonal gradient start:{x:0,y:0} end:{x:1,y:1}
        gradient: const LinearGradient(
          colors: [Color(0xFF477CB6), Color(0xFF8B4DAB), Color(0xFFDD276F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.sp),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Containers(
                wHeight: 118,
                wWidth: 118,
                shape: BoxShape.circle,
                opacityValue: .1,
                hexValue: 0x0FFFFFFF, // rgba(255,255,255,0.06)
              ),
            ),
            Positioned(
              bottom: -22,
              left: -11,
              child: Containers(
                wHeight: 80,
                wWidth: 80,
                shape: BoxShape.circle,
                opacityValue: .1,
                hexValue: 0x0DFFFFFF, // rgba(255,255,255,0.05)
              ),
            ),
            // ── Main content ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── User info row ────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Profile picture or initials
                          _profileImageUrl != null &&
                                  _profileImageUrl!.isNotEmpty
                              ? Container(
                                  width: 58.w,
                                  height: 58.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      // RN: borderColor: rgba(255,255,255,0.65)
                                      color: const Color(0xA6FFFFFF),
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(_profileImageUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : SizedBox(width: 58, height: 58),
                          Positioned(
                            bottom: 3,
                            right: 2,
                            child: Containers(
                              wWidth: 13,
                              wHeight: 13,
                              shape: BoxShape.circle,
                              hexValue: 0xFF4CD964,
                              border: Border.all(
                                color: const Color(0xFF8B4DAB),
                                width: 2.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 14.w), // RN: gap:14
                      // ── Name, email, online pill ─────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              _userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Email
                            Text(
                              _userEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(
                                  0xA6FFFFFF,
                                ), // rgba(255,255,255,0.65)
                              ),
                            ),

                            const SizedBox(height: 7),

                            Containers(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              hexValue: 0x2EFFFFFF, // rgba(255,255,255,0.18)
                              radius: BorderRadius.circular(20),
                              opacityValue: .1,
                              border: Border.all(
                                color: const Color(
                                  0x47FFFFFF,
                                ), // rgba(255,255,255,0.28)
                                width: 1,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Green dot
                                  Containers(
                                    wWidth: 6,
                                    wHeight: 6,
                                    shape: BoxShape.circle,
                                    hexValue: 0xFF4CD964,
                                  ),

                                  const SizedBox(width: 5),
                                  const Texts(
                                    text: 'Online now',
                                    size: 10,
                                    colorHexValue: 0xFFFFFFFF,
                                    // color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    // letterSpacing: 0.3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(color: Colors.white24, height: 10, thickness: 1),
                  // ── Stats row ────────────────────────────────────────────────
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // FAVOURITES
                        Expanded(
                          child: _buildStat(_favCount.toString(), "FAVOURITES"),
                        ),
                        CustomDivider(),
                        // INTERESTED
                        Expanded(
                          child: _buildStat(
                            _interestedCount.toString(),
                            "INTERESTED",
                          ),
                        ),

                        CustomDivider(),
                        // BLOCKS
                        Expanded(
                          child: _buildStat(_blockCount.toString(), "BLOCKS"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Texts(
          text: count,
          size: 22,
          fontWeight: FontWeight.bold,
          colorHexValue: 0xFFFFFFFF,
        ),
        Texts(text: label, size: 10, colorHexValue: 0xFFB0B0B0),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // const SizedBox(height: 50),
          Container(
            height: 120.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF477CB6), Color(0xFFDD276F)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Images(
                    imageStr: "assets/images/two_are_one.png",
                    height: 35.h,
                    width: 180.w,
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF477CB6), Color(0xFFDD276F)],
              ),
            ),
            // ✅ FIX: Real name and email in drawer
            accountName: Text(_userName),
            accountEmail: Text(_userEmail),
          ),
          _drawerItem(
            "Matches",
            isSelected: true,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CustomNavBar(initialIndex: 0),
              ),
            ),
          ),
          _drawerItem(
            "Messages",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomNavBar(initialIndex: 2),
              ),
            ),
          ),
          _drawerItem(
            "Interested",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InterestedUserScreen()),
            ),
          ),
          _drawerItem(
            "Visited You",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VisitedUserScreen()),
            ),
          ),
          _drawerItem(
            "Favorites",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavouriteUserScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    String title, {
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: isSelected
          ? const Color(0xFFDD276F).withValues(alpha: 0.1)
          : Colors.white,
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFFDD276F) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Texts(
            text: title,
            colorHexValue: 0xFF808080,
            size: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics:
          const NeverScrollableScrollPhysics(), // Loading ke waqt scroll na ho
      children: [
        const SizedBox(height: 10),
        const SizedBox(height: 30),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          itemCount: 6, // 6 boxes dikhayenge loading mein
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, _) => _buildShimmerCard(),
        ),
      ],
    );
  }
}
