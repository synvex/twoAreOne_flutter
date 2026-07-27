import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/core/widgets/back_button.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/top_toast.dart';
import 'package:two_are_one/data/models/details_screen_model.dart';
import 'package:two_are_one/data/models/user_match_model.dart';
import 'package:two_are_one/data/models/visited_blocked_model.dart';
import 'package:two_are_one/data/services/home_service.dart';
import '../../../data/models/favourite_model.dart';
import 'package:two_are_one/data/models/interested_model.dart';
import 'category_questions_screen.dart';
import 'inline_video_player.dart';
import 'profile_detail_card.dart';

const String kProfileUploadImagesBase = "https://www.twoareone.love/uploads/";
const Color kMehroon = Color(0xFF77153C);
const Color kMehroonLight = Color(0xFFDD276F);

class ProfileDetailsScreen extends StatefulWidget {
  final int? userId;
  const ProfileDetailsScreen({super.key, this.userId});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final HomeService _homeService = HomeService();
  bool _didInit = false;
  FilterMatchModel? _cardUser;
  bool _blocked = false;
  bool _loading = true;
  ProfileDetailModel? _details;
  bool _showFullBio = false;
  String? _selectedImage; // fully-resolved URL for the fullscreen viewer
  bool _blockLoading = false;
  bool _heartLoading = false;
  bool _starLoading = false;
  bool _chatLoading = false;
  final Map<String, DateTime> _chatCooldowns = {};
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    print("DEBUG: ProfileDetails arguments type: ${args.runtimeType}");
    print("DEBUG: ProfileDetails arguments value: $args");

    if (args is FilterMatchModel) {
      _cardUser = args;
    }
    else if (args is FavouriteUserModel) {
      _cardUser = FilterMatchModel(
        id: args.id,
        name: args.fullName,
        imagePath: args.profilePicture ?? '',
        age: 0,
        location: '',
        city: '',
        matchPercent: '0%',
      );
    }
    else if (args is InterestedUserModel) {
      _cardUser = FilterMatchModel(
        id: args.id,
        name: args.fullName,
        imagePath: args.profilePicture ?? '',
        age: 0,
        location: '',
        city: '',
        matchPercent: '0%',
      );
    }
    else if (args is VisitedBlockedUserModel) {
      _cardUser = FilterMatchModel(
          id: args.profileId,
          name: args.fullName,
          imagePath: args.profilePicture ?? '',
          age: 0,
          location: '',
          city: '',
          matchPercent: '0%'
      );
      _blocked = true;
    }
    else if (args is Map) {
      final u = args['user'];
      _blocked = args['blocked'] == true;

      if (u is FilterMatchModel) {
        _cardUser = u;
      }
      else if (u is FavouriteUserModel) {
        _cardUser = FilterMatchModel(
          id: u.id,
          name: u.fullName,
          imagePath: u.profilePicture ?? '',
          age: 0,
          location: '',
          city: '',
          matchPercent: '0%',
        );
      }
      else if (u is InterestedUserModel) {
        _cardUser = FilterMatchModel(
          id: u.id,
          name: u.fullName,
          imagePath: u.profilePicture ?? '',
          age: 0,
          location: '',
          city: '',
          matchPercent: '0%',
        );
      }
      else if (u is VisitedBlockedUserModel) { // Move this inside the Map block
        _cardUser = FilterMatchModel(
          id: u.profileId, // Use profileId
          name: u.fullName,
          imagePath: u.profilePicture ?? '',
          age: 0,
          location: '',
          city: '',
          matchPercent: '0%',
        );
      }
    }

    _visitedUser();
    _getUserDetails();
  }

  int? get _userId => _details?.userId ?? _cardUser?.id;
  // ── API ──────────────────────────────────────────────────────────────
  Future<void> _visitedUser() async {
    final id = _cardUser?.id ?? widget.userId;
    debugPrint("VISITED: cardUser id = $id, blocked = $_blocked");
    if (id == null) {
      debugPrint("VISITED: skipped, no id");
      return;
    }
    final res = await _homeService.addVisitedUser(id);
    debugPrint("visited/add.php -> $res");

  }

  Future<void> _getUserDetails() async {
    final id = _cardUser?.id?? widget.userId;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    if (_details == null) setState(() => _loading = true);

    final res = await _homeService.getUserDetail(id);
    if (!mounted) return;

    if (res['success'] == true && res['data'] is Map) {
      setState(() {
        _details = ProfileDetailModel.fromJson(
          (res['data'] as Map).cast<String, dynamic>(),
        );
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  // ── utils ────────────────────────────────────────────────────────────
  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  String _fullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : '$kProfileUploadImagesBase$path';
  }

  String get _truncatedBio {
    final bio = _details?.bio ?? '';
    return bio.length > 200 ? bio.substring(0, 200) : bio;
  }

  // ── actions ──────────────────────────────────────────────────────────
  void _handleSilentChat() {
    if (_chatLoading) return;
    final id = (_userId ?? 0).toString();
    final now = DateTime.now();

    if (_chatCooldowns.containsKey(id) &&
        now.difference(_chatCooldowns[id]!).inSeconds < 60) {
      final left = 60 - now.difference(_chatCooldowns[id]!).inSeconds;
      TopToast.show(
        context,
        title: "Please wait",
        message: "You can send another invite in ${left}s",
        type: ToastType.info,
      );
      return;
    }
    _chatCooldowns[id] = now;

    setState(() => _chatLoading = true);
    // TODO: wire actual socket sendMessage() call here (RN: useChatSocket).
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _chatLoading = false);
      TopToast.show(
        context,
        title: "Invite sent!",
        message: "Your message has been delivered.",
        type: ToastType.success,
      );
    });
  }

  Future<void> _onBlockPress() async {
    final id = _userId;
    if (id == null) return;
    setState(() => _blockLoading = true);

    final success = await _homeService.blockUser(id);
    if (!mounted) return;

    setState(() => _blockLoading = false);
    if (success) {
      TopToast.show(
        context,
        title: "User blocked",
        message: "Removed from match list",
        type: ToastType.success,
      );
      Navigator.of(context).pop();
    } else {
      TopToast.show(
        context,
        title: "Couldn't block user",
        message: "Please check your connection and try again.",
        type: ToastType.error,
      );
    }
  }

  Future<void> _onLikePress() async {
    final id = _userId;
    if (id == null || _details == null) return;
    setState(() => _heartLoading = true);

    final wasInterested = _details!.isInterested;
    final success = await _homeService.toggleInterest(id, wasInterested);
    if (!mounted) return;

    if (success) {
      setState(
        () => _details = _details!.copyWith(isInterested: !wasInterested),
      );
    }
    setState(() => _heartLoading = false);
  }

  Future<void> _onStarPress() async {
    final id = _userId;
    if (id == null || _details == null) return;
    setState(() => _starLoading = true);

    final wasFav = _details!.isFavorite;
    final success = await _homeService.toggleFavorite(id, wasFav);
    if (!mounted) return;

    if (success) {
      setState(() => _details = _details!.copyWith(isFavorite: !wasFav));
    }
    setState(() => _starLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _details == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: kMehroon)),
      );
    }

    return Stack(
      children: [
        _buildScreen(context),
        if (_selectedImage != null) _buildFullScreenImageViewer(),
      ],
    );
  }

  Widget _buildScreen(BuildContext context) {
    final details = _details;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.userId.toString()),),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                ).copyWith(bottom: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // ── Detail card (image + actions) ────────────────
                    ProfileDetailCard(
                      imageUrl: _fullUrl(details?.profilePicture),
                      blocked: _blocked,
                      onPress: () {
                        final url = _fullUrl(details?.profilePicture);
                        if (url.isNotEmpty) {
                          setState(() => _selectedImage = url);
                        }
                      },
                      onLike: _onLikePress,
                      onStar: _onStarPress,
                      onDislike: _onBlockPress,
                      onChat: _handleSilentChat,
                      isFavorite: details?.isFavorite ?? false,
                      isInterested: details?.isInterested ?? false,
                      heartLoading: _heartLoading,
                      starLoading: _starLoading,
                      blockLoading: _blockLoading,
                    ),
                    const SizedBox(height: 16),
                    // ── Name & location ──────────────────────────────
                    Text(
                      _capitalize(details?.fullName),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xD9000000),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Images(
                          imageStr: "assets/location_detail_screen.svg",
                          height: 15,
                          width: 15,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "${details?.city.isNotEmpty == true ? details!.city : 'N/A'} , ${details?.country ?? ''}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ── CTA ───────────────────────────────────────────
                    if (!_blocked) _buildGetToKnowButton(details),
                    const SizedBox(height: 16),
                    // ── About ─────────────────────────────────────────
                    _sectionTitle("About me"),
                    Text(
                      _showFullBio ? (details?.bio ?? '') : _truncatedBio,
                      style: const TextStyle(fontSize: 11, color: Colors.black),
                    ),
                    if ((details?.bio?.length ?? 0) > 200)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showFullBio = !_showFullBio),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _showFullBio ? 'Show less' : 'Read more',
                            style: const TextStyle(
                              color: kMehroon,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // ── Work ──────────────────────────────────────────
                    _sectionTitle("Work"),
                    Text(
                      (details?.work?.isNotEmpty == true)
                          ? details!.work!
                          : "No work description available",
                      style: const TextStyle(fontSize: 11, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    // ── Personal Info ─────────────────────────────────
                    _sectionTitle("Personal Info"),
                    Wrap(
                      runSpacing: 6,
                      children: [
                        _infoBadge("Gender", details?.gender),
                        _infoBadge("Height", details?.height),
                        _infoBadge("Age", details?.age),
                        _infoBadge("Weight", details?.weight),
                      ],
                    ),
                    // ── Images ────────────────────────────────────────
                    if ((details?.images.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 16),
                      const Text(
                        "Uploaded Images",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xD9000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: details!.images.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final url = _fullUrl(details.images[index]);
                            return GestureDetector(
                              onTap: () => setState(() => _selectedImage = url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      Container(
                                        width: 100,
                                        height: 100,
                                        color: const Color(0xFFD9D9D9),
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    // ── Video ─────────────────────────────────────────
                    if(details?.video?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      const Text(
                        "Uploaded Video",
                        style: TextStyle(fontSize: 16, color: Color(
                            0xD9000000)),
                      ),
                      const SizedBox(height: 8),
                      InlineVideoPlayer(url: _fullUrl(details!.video)),
                    ],
                    // ── Matches breakdown ─────────────────────────────
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            letterSpacing: 0.4,
                          ),
                          children: [
                            const TextSpan(text: "How "),
                            TextSpan(
                              text: _capitalize(details?.fullName),
                              style: const TextStyle(
                                color: kMehroon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " answered questions"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    ...?details?.categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              category.categoryName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CategoryQuestionsScreen(
                                        categoryId: category
                                            .categoryId, // 👈 confirm field name — neeche note dekhein
                                        categoryName: category.categoryName,
                                        userId: _userId ?? 0,
                                        editable:
                                            false, // doosre user ka profile view ho raha hai — read-only
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kMehroon,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: const Text(
                                  "View Answers",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenImageViewer() {
    return GestureDetector(
      onTap: () => setState(() => _selectedImage = null),
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  _selectedImage!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stack) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImage = null),
                child: const Text(
                  "✕",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Back_Button(onTap: () => Navigator.of(context).maybePop()),
          GestureDetector(
            onTap: () {
              // RN navigates to NotificationScreen here.
              TopToast.show(
                context,
                title: "Notifications",
                type: ToastType.info,
              );
            },
            child: Containers(
              wWidth: 45,
              wHeight: 45,
              shape: BoxShape.circle,
              hexValue: 0xFFFFFFFF,
              border: Border.all(color: Colors.black12),
              alignment: Alignment.center,
              child: const Images(
                imageStr: "assets/svg_images/notification.svg",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetToKnowButton(ProfileDetailModel? details) {
    return GestureDetector(
      onTap: _chatLoading ? null : _handleSilentChat,
      child: Opacity(
        opacity: _chatLoading ? 0.7 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [kMehroon, kMehroonLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          alignment: Alignment.center,
          child: _chatLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Get to know ${_capitalize(details?.fullName)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${details?.percentMatch ?? '0'} % MATCH OVERALL",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xD9000000),
        ),
      ),
    );
  }
  Widget _infoBadge(String label, String? value) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width * 0.92) / 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Texts(text: label, size: 15, colorHexValue: 0xFF4D4D4D),
            Container(
              height: 30,
              constraints: const BoxConstraints(minWidth: 80),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xCCF0F0F0),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Texts(
                text: (value?.isNotEmpty == true) ? value! : 'N/A',
                size: 10,
                colorHexValue: 0xFF77153C,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
