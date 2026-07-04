import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/divider.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/features/Bottom_Nav_Bar_Screens/custom_nav_bar.dart';
import 'package:two_are_one/features/home/profile_card.dart';
import 'package:two_are_one/models/user_match_model.dart';
import 'package:two_are_one/services/home_service.dart';

import '../../core/image.dart';

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
    _loadUserInfo();           // ✅ load real name/email/counts
    _fetchProfiles(refresh: true);
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // lib/features/home/home_screen.dart -> _loadUserInfo method
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

        _favCount = int.tryParse(data['total_favorites']?.toString() ?? '0') ?? 0;
        _interestedCount = int.tryParse(data['total_interested']?.toString() ?? '0') ?? 0;
        _blockCount = int.tryParse(data['total_blocks']?.toString() ?? '0') ?? 0;
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
    } else
    {
      if (_isFetchingMore || !_hasMore) return;
      setState(() => _isFetchingMore = true);
    }

    final res = await _homeService.getMatchProfiles(_currentPage);

    if (!mounted) return;
// Inside _fetchProfiles in HomeScreen.dart

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
    }
    // if (res['success'] == true) {
    //   // res['data'] is the List of profiles from your ApiManager fetch() unwrap
    //   final dynamic rawList = res['data'];
    //
    //   if (rawList is List) {
    //     final List<FilterMatchModel> newUsers = rawList.map((u) {
    //       final model = FilterMatchModel.fromJson(u as Map<String, dynamic>);
    //
    //       // ✅ SENIOR FIX: Only prepend URL if we actually have a filename
    //       String fullPath = "";
    //       if (model.imagePath.isNotEmpty && model.imagePath != "null") {
    //         fullPath = model.imagePath.startsWith('http')
    //             ? model.imagePath
    //             : "https://www.twoareone.love/uploads/${model.imagePath}";
    //       }
    //
    //       return model.copyWith(imagePath: fullPath);
    //     }).toList();
    //
    //     setState(() {
    //       if (refresh) {
    //         _users = newUsers;
    //       } else {
    //         _users.addAll(newUsers);
    //       }
    //
    //       _currentPage++;
    //
    //       // ✅ SENIOR FIX: Real Pagination Logic
    //       int total = int.tryParse(res['total_count']?.toString() ?? '0') ?? 0;
    //       _hasMore = _users.length < total && newUsers.isNotEmpty;
    //
    //       _isLoading = false;
    //       _isFetchingMore = false;
    //     });
    //   } else {
    //     // Data came back, but it wasn't a list (maybe an error message)
    //     debugPrint("API returned success but 'data' was not a list: $rawList");
    //     setState(() { _isLoading = false; _isFetchingMore = false; });
    //   }
    // }
    else {
      debugPrint("API Error: ${res['error']}");
      setState(() { _isLoading = false; _isFetchingMore = false; });
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
          // _users[index] = FilterMatchModel(
          //   id: user.id, name: user.name, age: user.age,
          //   location: user.location, city: user.city,
          //   matchPercent: user.matchPercent, imagePath: user.imagePath,
          //   isOnline: user.isOnline, isInterested: user.isInterested,
          //   isFavorite: !wasTrue,
          // );
          _favCount += wasTrue ? -1 : 1;
        }
      });
    }
    setState(() => _loadingStars.remove(user.id));
  }
  void _handleInterest(FilterMatchModel user) async {
    setState(() => _loadingHearts.add(user.id));
    final success = await _homeService.toggleInterest(user.id, user.isInterested);
    if (success && mounted) {
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          final wasTrue = _users[index].isInterested;
          _users[index] = _users[index].copyWith(isInterested: !wasTrue);
          // _users[index] = FilterMatchModel(
          //   id: user.id, name: user.name, age: user.age,
          //   location: user.location, city: user.city,
          //   matchPercent: user.matchPercent, imagePath: user.imagePath,
          //   isOnline: user.isOnline, isFavorite: user.isFavorite,
          //   isInterested: !wasTrue,
          // );
          _interestedCount += wasTrue ? -1 : 1;
        }
      });
    }
    setState(() => _loadingHearts.remove(user.id));
  }
   // FIX: Decrements favorite/interested counts if blocked user had those flags
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
    }
    setState(() => _loadingBlocks.remove(user.id));
  }
  void _handleSilentChat(FilterMatchModel user) {
    // Wire your socket sendMessage here
    AlertDialog(
      title: Texts(text: "Invite Send!",fontWeight: FontWeight.bold,size: 18,),
      content: Texts(text: 'Invite has been sent to ${user.name}.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    );
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Invite sent to ${user.name}!")),
    // );
    // ScaffoldMessenger.of(context).showMaterialBanner(
    //     MaterialBanner(
    //         content: Containers(hexValue: 0xFF477CB6,wHeight: 45,
    //     wWidth: 7,), actions: [
    //
    //     ]));
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
                          isHeartLoading: _loadingHearts.contains(user.id),
                          isBlockLoading: _loadingBlocks.contains(user.id),
                          onStar: () => _handleFavorite(user),
                          onHeart: () => _handleInterest(user),
                          onDislike: () => _handleBlock(user),
                          // onChat: () => _handleSilentChat(user),
                          onRequestSend: ()=> _handleSilentChat(user),
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
      padding: const EdgeInsets.fromLTRB(25, 45, 25, 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: const Icon(Icons.menu, size: 30),
          ),
          const Spacer(),
          Images(
              imageStr: "assets/images/two_are_one.png", height: 35),
          const Spacer(),
          GestureDetector(
              onTap: (){},
              child: Containers(
                hexValue: 0xFFFFFFFF,
                shape: BoxShape.circle,
                padding: const EdgeInsets.only(left: 12, right: 10, top: 10, bottom: 10),
                border: Border.all(color: Colors.black45),
                child: Images(
                  imageStr: "assets/svg_images/search.svg", height: 20,),
              )
          ),
          const SizedBox(width: 10),
          GestureDetector(
              onTap: (){},
              child: Containers(
                hexValue: 0xFFFFFFFF,
                shape: BoxShape.circle,
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                border: Border.all(color: Colors.black45),
                child: Images(
                  imageStr: "assets/svg_images/notification.svg", height: 20,),
              )
          ),        ],
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
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // ── RN: top-right decorative circle ───────────────────────────────
            // position: absolute, top:-30, right:-30, width:120, height:120
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
                          _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                              ? Container(
                            width: 58,
                            height: 58,
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
                          // ── No image: show initial letter ──────────────
                          // RN: backgroundColor rgba(255,255,255,0.2), border rgba(255,255,255,0.6)
                              : Containers(
                            wHeight: 58,
                            wWidth: 58,
                              shape: BoxShape.circle,
                              hexValue: 0x33FFFFFF,
                              border: Border.all(
                                color: const Color(0x99FFFFFF),
                                width: 2,
                              ),
                            alignment: Alignment.center,
                            child: Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
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
                      const SizedBox(width: 14), // RN: gap:14

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
                              style: const TextStyle(
                                fontSize: 16,
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
                                color: Color(0xA6FFFFFF), // rgba(255,255,255,0.65)
                              ),
                            ),

                            const SizedBox(height: 7),

                            // ── "Online now" pill ─────────────────────────────
                            // RN: alignSelf:'flex-start', bg rgba(255,255,255,0.18)
                            // border rgba(255,255,255,0.28), borderRadius:20
                            Containers(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                                hexValue: 0x2EFFFFFF,   // rgba(255,255,255,0.18)
                                radius: BorderRadius.circular(20),
                                opacityValue: .1,
                                border: Border.all(
                                  color: const Color(0x47FFFFFF), // rgba(255,255,255,0.28)
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
                  // RN: marginBottom:14 on row
                  // ── Divider ──────────────────────────────────────────────────
                  // RN: height:1, backgroundColor: rgba(255,255,255,0.15)
                  // Containers(
                  //   wHeight: 1,
                  //   hexValue: 0x26FFFFFF, // rgba(255,255,255,0.15)
                  //   margin: const EdgeInsets.only(bottom: 13),
                  // ),
                  Divider(
                    color: Colors.white24,height: 10,thickness: 1,
                  ),
                  // ── Stats row ────────────────────────────────────────────────
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // FAVOURITES
                        Expanded(child: _buildStat(_favCount.toString(), "FAVOURITES")),
                        // RN: width:1, height:32, rgba(255,255,255,0.2)
                        // Containers(
                        //   wWidth: 1,
                        //   wHeight: 32,
                        //   hexValue: 0x33FFFFFF,
                        // ),
                        CustomDivider(),
                        // INTERESTED
                        Expanded(child: _buildStat(_interestedCount.toString(), "INTERESTED")),
                        // Containers(
                        //   wWidth: 1,
                        //   wHeight: 32,
                        //   hexValue: 0x33FFFFFF,
                        // ),
                        CustomDivider(),
                        // BLOCKS
                        Expanded(child: _buildStat(_blockCount.toString(), "BLOCKS")),
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

// ── Stat widget — matches RN exactly ──────────────────────────────────────────
//   Widget _buildStat(String count, String label) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           count,
//           style: const TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             height: 1.2, // RN: lineHeight:26
//           ),
//         ),
//         const SizedBox(height: 5), // RN: marginTop:5
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 10,
//             color: Color(0x99FFFFFF), // rgba(255,255,255,0.6)
//             letterSpacing: 0.5,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
  // Widget _buildActionBanner() {
  //   return Container(
  //     padding: const EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(20),
  //       gradient: const LinearGradient(
  //         colors: [Color(0xFF477CB6), Color(0xFF8B4DAB), Color(0xFFDD276F),],
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             // ✅ FIX: Real profile image, not placeholder
  //             CircleAvatar(
  //               radius: 28,
  //               backgroundImage: _profileImageUrl != null &&
  //                   _profileImageUrl!.isNotEmpty
  //                   ? NetworkImage(_profileImageUrl!)
  //                   : const AssetImage("assets/images/placeholder.png")
  //               as ImageProvider,
  //             ),
  //             const SizedBox(width: 12),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // ✅ FIX: Real name and email
  //                 Texts(
  //                   text: _userName,
  //                   size: 16,
  //                   fontWeight: FontWeight.bold,
  //                   colorHexValue: 0xFFFFFFFF,
  //                 ),
  //                 Texts(
  //                   text: _userEmail,
  //                   size: 11,
  //                   colorHexValue: 0xFFE0E0E0,
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         Containers(hexValue: 0xFFcc99ff,opacityValue: .05,
  //           wHeight: 50,
  //           wWidth: 150,
  //           child: Row(
  //             children: [
  //               Containers(
  //                 shape: BoxShape.circle,
  //                 hexValue: 0xFF00FF00, wHeight: 10,wWidth: 10,),
  //               Texts(text: "Online"),
  //             ],
  //           ),
  //
  //         ),
  //
  //         const Divider(color: Colors.white24, height: 25),
  //         IntrinsicHeight(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               _buildStat(_favCount.toString(), "FAVORITES"),
  //              const VerticalDivider(color: Colors.white24,width: 10,thickness: 1,),
  //               _buildStat(_interestedCount.toString(), "INTERESTED"),
  //               const VerticalDivider(color: Colors.white24,width: 10,thickness: 1,),
  //               _buildStat(_blockCount.toString(), "BLOCKS"),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Texts(
            text: count,
            size: 22,
            fontWeight: FontWeight.bold,
            colorHexValue: 0xFFFFFFFF),
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
            height: 120,
            decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF477CB6), Color(0xFFDD276F)],
            ),
          ),
            child:Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Images(imageStr: "assets/images/two_are_one.png", height: 35,width: 180,),
                  Spacer()
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
          _drawerItem("Matches", isSelected: true),
          _drawerItem("Messages"),
          _drawerItem("Interested"),
          _drawerItem("Visited You"),
          _drawerItem("Favorites"),
        ],
      ),
    );
  }
  Widget _drawerItem(String title, {bool isSelected = false}) {
    return ListTile(
      tileColor: isSelected ? const Color(0xFFDD276F).withOpacity(0.5) : Colors.white,
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFFDD276F) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
  Widget _buildSectionDivider(String title) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ),
      const Expanded(child: Divider()),
    ]);
  }
  Widget _buildSkeletonGrid() =>
      const Center(child: CircularProgressIndicator());
}