import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/my_icons.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/models/user_match_model.dart';
import 'package:two_are_one/data/services/fav_services.dart';
import 'package:two_are_one/features/views/home/profile_details_screen.dart';
import 'customs/bottom_bar.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final FavServices _favServices = FavServices();
  final ScrollController _scrollController = ScrollController();
  static const int _perPage = 10;
  List<FilterMatchModel> _data = [];
  int _page = 1;
  bool _loading = false; // pehli/subsequent page load
  bool _refreshing = false; // pull to refresh
  bool _hasMore = true;
  bool _blockUserLoading = false;
  String? _unFavoriteLoaderId; // jis card ka star loading dikhana hai
  FilterMatchModel? _selectedItem;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _getData(page: 1, refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _getData({required int page, bool refresh = false}) async {
    if (!refresh) {
      setState(() => _loading = true);
    }

    try {
      final result = await _favServices.getFavouritedList(
        page: page,
        perPage: _perPage,
      );

      if (!mounted) return;

      setState(() {
        if (refresh || page == 1) {
          _data = result;
        } else {
          final existingIds = _data.map((e) => e.id).toSet();
          _data.addAll(result.where((item) => !existingIds.contains(item.id)));
        }
        _page = page;
        _hasMore =
            result.length ==
            _perPage; // agar API total_pages deti hai to wo use karein
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
      });
      _showError(e.toString());
    }
  }

  void _loadMore() {
    if (!_loading && _hasMore && _data.length >= _perPage) {
      _getData(page: _page + 1);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _getData(page: 1, refresh: true);
  }

  // ── Unfavorite (RN ke onUnfavoritePress jaisa) ───────────────────────────
  Future<void> _onUnfavoritePress(FilterMatchModel item) async {
    setState(() => _unFavoriteLoaderId = item.id.toString());
    try {
      await _favServices.removeFavourite(profileUserId: item.id.toString());
      if (!mounted) return;
      setState(() {
        _data.removeWhere((e) => e.id == item.id);
        _unFavoriteLoaderId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _unFavoriteLoaderId = null);
      _showError(e.toString());
    }
  }

  Future<void> _blockUser() async {
    if (_selectedItem == null) return;
    setState(() => _blockUserLoading = true);

    try {
      // NOTE: "Block Profile" ka endpoint aapke shared Favourite Postman
      // collection mein nahi hai — ye alag "User Actions" collection mein
      // hoga. Apni BlockService (ya jo bhi service ho) yahan call karein.
      // Filhal placeholder chhoda hai:
      // await _blockService.blockUser(profileUserId: _selectedItem!.id.toString());
      if (!mounted) return;
      setState(() {
        _data.removeWhere((e) => e.id == _selectedItem!.id);
        _blockUserLoading = false;
      });
      Navigator.pop(context); // bottom sheet band karein
    } catch (e) {
      if (!mounted) return;
      setState(() => _blockUserLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onNotificationPress() {
    // TODO: Apni notification screen route yahan navigate karein
    // Navigator.pushNamed(context, NotificationScreen.routeName);
  }
  void _onMenuPress(FilterMatchModel item) {
    setState(() => _selectedItem = item);
    showCustomBottomSheet(context,
        onViewProfile: () {Navigator.push(context, MaterialPageRoute(builder: (context) =>
          ProfileDetailsScreen()));  },
        onBlockProfile: () {
      // _blockUser()
    });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MenuItem(
                      imgStr: 'assets/svg_images/Favorite/viewProfile.svg',
                      label: "View Profile",
                      onPress: () {
                        Navigator.pop(context);
                        // Navigate logic here
                      },
                    ),
                    MenuItem(
                      imgStr: 'assets/svg_images/Favorite/blockProfile.svg',
                      label: "Block Profile",
                      iconLoading: false, // pass state here
                      onPress: () {
                        // Block logic
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Header (RN ke Header() jaisa) ────────────────────────────────────────
  // Widget _buildHeader() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         const Text(
  //           "Favorites",
  //           style: TextStyle(
  //             fontSize: 28,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black,
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: _onNotificationPress,
  //           child: Container(
  //             width: 44,
  //             height: 44,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               border: Border.all(color: Colors.black, width: 1.2),
  //             ),
  //             child: const Icon(Icons.notifications_none, color: Colors.black),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // ── Empty State (RN ke EmptyList jaisa) ──────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: const Icon(
                Icons.star_border,
                size: 34,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "No one is added to favorite list",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton Card (RN ke renderSkeletonItem jaisa) ───────────────────────
  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 220,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildCard(FilterMatchModel person) {
    final String imageUrl = person.imagePath.startsWith('http')
        ? person.imagePath
        : 'https://www.twoareone.love/uploads/${person.imagePath}';
    final bool isUnfavoriting = _unFavoriteLoaderId == person.id.toString();

    return Containers(
      margin: const EdgeInsets.only(bottom: 20),
      wHeight: 220,
      hexValue: 0xFFFFFFFF,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Texts(
                    text: "NO-PIC",
                    colorHexValue: 0x8A000000,
                    fontWeight: FontWeight.bold,
                    size: 16,
                  ),
                ),
              ),
            ),
            // Bottom gradient overlay for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 90,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            // "..." menu button top-right
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => _onMenuPress(person),
                child: const MyIcons(
                  iconData: Icons.more_horiz_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            // Name / Age / Location bottom-left
            Positioned(
              bottom: 14,
              left: 14,
              right: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Texts(
                    text: "${person.name}, ${person.age}",
                    colorHexValue: 0xFFFFFFFF,
                    fontWeight: FontWeight.bold,
                    size: 17,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Texts(
                    text:
                        "${person.city.isNotEmpty ? person.city : 'N/A'} , ${person.location ?? 'N/A'}",
                    colorHexValue: 0xB3FFFFFF,
                    size: 16,
                    maxLines: 1,
                    // overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Star button bottom-right (unfavorite)
            Positioned(
              bottom: 14,
              right: 14,
              child: GestureDetector(
                onTap: isUnfavoriting ? null : () => _onUnfavoritePress(person),
                child: Containers(
                  wWidth: 40,
                  wHeight: 40,
                  hexValue: 0xFFFFFFFF,
                  shape: BoxShape.circle,
                  child: Center(
                    child: isUnfavoriting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF477CB6),
                                  Color(0xFF8B4DAB),
                                  Color(0xFFDD276F),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: CircularProgressIndicator(strokeWidth: 2),
                              // child: CircularProgressIndicator(
                              //   strokeWidth: 2,
                              //   color: Color(0xFFDD276F),
                              //
                              // ),
                            ),
                          )
                        : const Images(
                            imageStr: "assets/svg_images/star_coloured.svg",
                            height: 25,
                            width: 25,
                          ),
                    // ShaderMask(
                    //   shaderCallback: (bounds) => const LinearGradient(
                    //     colors: [
                    //       Color(0xFF477CB6),
                    //       Color(0xFF8B4DAB),
                    //       Color(0xFFDD276F),
                    //     ],
                    //     begin: Alignment.topLeft,
                    //     end: Alignment.bottomRight,
                    //   ).createShader(bounds),
                    //   child: const Images(imageStr: "assets/svg_images/star_coloured.svg"),
                    // ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading && _data.isEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) => _buildSkeletonCard(),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFFDD276F),
                      onRefresh: _onRefresh,
                      child: _data.isEmpty
                          ? ListView(
                              // ListView taake RefreshIndicator kaam kare empty state pe bhi
                              children: [_buildEmptyState()],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                20,
                                30,
                              ),
                              itemCount: _data.length + (_loading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= _data.length) {
                                  return _buildSkeletonCard();
                                }
                                return _buildCard(_data[index]);
                              },
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
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
      child: Row(
        children: [
          Texts(text: "Favorites", size: 24, fontWeight: FontWeight.w600),
          Spacer(),
          GestureDetector(
            onTap: _onNotificationPress,
            child: Containers(
              hexValue: 0xFFFFFFFF,
              shape: BoxShape.circle,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              border: Border.all(color: Colors.grey, style: BorderStyle.solid),
              child: Images(
                imageStr: "assets/svg_images/notification.svg",
                height: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
