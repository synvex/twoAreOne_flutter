import 'dart:async';
import 'package:flutter/material.dart';
import 'package:two_are_one/core/back_button.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/ui/views/bottom_nav/custom_nav_bar.dart';
import 'package:two_are_one/ui/views/bottom_nav/home_screen.dart';
import 'package:two_are_one/ui/views/home/profile_card.dart';
import 'package:two_are_one/data/models/user_match_model.dart';
import 'package:two_are_one/data/services/home_service.dart'; // Ensure this matches your Service file
import 'package:two_are_one/core/back_button.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/data/models/user_match_model.dart';
import 'package:two_are_one/data/services/home_service.dart';
import 'package:two_are_one/ui/views/bottom_nav/home_screen.dart';
import 'filer_sheet.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/textfield.dart';
import 'package:two_are_one/core/texts.dart';

class HomeFilterScreen extends StatefulWidget {
  const HomeFilterScreen({super.key});

  @override
  State<HomeFilterScreen> createState() => _HomeFilterScreenState();
}

class _HomeFilterScreenState extends State<HomeFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HomeService _homeService = HomeService();
  Timer? _debounce;

  bool _isLoading = false;
  bool _hasError = false;
  // States for individual card loaders (Matching React states)
  final Set<int> _starLoading = {};
  final Set<int> _heartLoading = {};
  final Set<int> _blockLoading = {};

  // Cooldown map for chat invites
  final Map<String, DateTime> _chatCooldowns = {};

  List<FilterMatchModel> users = [];

  Map<String, dynamic> filterParams = {
    "gender": "men",
    "age_range": "",       // Apply ke baad ye "18,45" format mein aayega
    "distance_range": "",  // Apply ke baad ye "0,500" format mein aayega
    "country": "",
    "city": "",
  };
  // Map<String, dynamic> filterParams = {
  //   "gender": "men",
  //   "age_range": "",
  //   "distance_range": "",
  //   "country": "",
  //   "city": "",
  // };

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _fetchFilteredProfiles(searchTerm: query);
      } else {
        setState(() {
          users = [];
          _hasError = false;  // ✅ clear error on empty search
        });
      }
    });
  }
  // 2. Fetch Profiles (Matches getMatchedProfiles API Logic)
  Future<void> _fetchFilteredProfiles({String? searchTerm}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final body = {
      "filter": "true",
      "sexual_preference": filterParams["gender"] == "women" ? "Female" : "Male",
      "age_range": filterParams["age_range"],
      "distance_range": filterParams["distance_range"],
      "country": filterParams["country"],
      "city": filterParams["city"],
      "search_term": searchTerm?.trim() ?? _searchController.text.trim(),
    };

    // Note: Assuming your ApiManager/HomeService handles this body
    final result = await _homeService.getMatchProfilesWithFilter(body);

    if (!mounted) return;

    if (result['success'] == true) {
      final List rawData = result['data'] ?? [];
      setState(() {
        users = rawData.map((u) => FilterMatchModel.fromJson(u)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // 3. Action Handlers (Like, Star, Block, Chat)
  void _onStarPress(FilterMatchModel user) async {
    setState(() => _starLoading.add(user.id));
    final success = await _homeService.toggleFavorite(user.id, user.isFavorite);
    if (success && mounted) {
      setState(() {
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = FilterMatchModel(  // replace object, don't mutate
            id: user.id,
            name: user.name,
            age: user.age,
            location: user.location,
            city: user.city,
            matchPercent: user.matchPercent,
            imagePath: user.imagePath,
            isOnline: user.isOnline,
            isFavorite: !user.isFavorite,   // ✅ toggled
            isInterested: user.isInterested,
          );
        }
      });
    }
    setState(() => _starLoading.remove(user.id));
  }

  void _onLikePress(FilterMatchModel user) async {
    setState(() => _heartLoading.add(user.id));
    final success = await _homeService.toggleInterest(user.id, user.isInterested);
    if (success && mounted) {
      setState(() {
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = FilterMatchModel(
            id: user.id,
            name: user.name,
            age: user.age,
            location: user.location,
            city: user.city,
            matchPercent: user.matchPercent,
            imagePath: user.imagePath,
            isOnline: user.isOnline,
            isFavorite: user.isFavorite,
            isInterested: !user.isInterested, // ✅ toggled
          );
        }
      });
    }
    setState(() => _heartLoading.remove(user.id));
  }
  void _onBlockPress(int id) async {
    setState(() => _blockLoading.add(id));
    final success = await _homeService.blockUser(id);
    if (success && mounted) {
      setState(() => users.removeWhere((u) => u.id == id));
    }
    setState(() => _blockLoading.remove(id));
  }

  void _handleSilentChat(FilterMatchModel user) {
    final userId = user.id.toString();
    final now = DateTime.now();
    if (_chatCooldowns.containsKey(userId)) {
      final diff = now.difference(_chatCooldowns[userId]!);
      if (diff.inSeconds < 30) {
        _showToast("Please wait ${30 - diff.inSeconds}s to send another invite");
        return;
      }
    }
    _chatCooldowns[userId] = now;
    _showToast("Invite sent to ${user.name}!");
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            children: [
              Align(
                  alignment: AlignmentGeometry.topLeft,
                  child: Back_Button(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (context) => MainBarScreen())))),
              const SizedBox(height: 35),
              _buildSearchRow(),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _hasError
                    ? _buildErrorState()
                    : users.isEmpty && _searchController.text.isNotEmpty
                    ? _buildEmptyState()
                    : _buildUserGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Containers(
            hexValue: 0xFFFFFFFF,
            wHeight: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12),
              radius: BorderRadius.circular(66),
              border: Border.all(
                  color: Colors.grey.shade500, width: 0.5),
            child: Row(
              children: [
                const Images(imageStr: "assets/svg_images/search.svg"),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: "Search User By Name",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () => _showFilterSheet(),
          child: const Images(imageStr: "assets/svg_images/filter.svg")
        ),
      ],
    );
  }

  Widget _buildUserGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.72,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ProfileCard(
          user: user,
          isStarLoading: _starLoading.contains(user.id),
          isHeartLoading: _heartLoading.contains(user.id),
          isBlockLoading: _blockLoading.contains(user.id),
          onStar: () => _onStarPress(user),
          onHeart: () => _onLikePress(user),
          onDislike: () => _onBlockPress(user.id),
          onRequestSend: () => _handleSilentChat(user),
          onPress: () => Navigator.pushNamed(context, '/profile_detail', arguments: user),
        );
      },
    );
  }
  // State Builders ... (keep your existing Loading/Empty/Error state widgets)
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilters: filterParams, // ✅ add this
        onApply: (filters) {
          setState(() => filterParams = filters);
          _fetchFilteredProfiles();
        },
        onReset: _resetFilters,
      ),
    );
  }
  void _resetFilters() {
    setState(() {
      filterParams = {
        "gender": "men",
        "age_range": "",
        "distance_range": "",
        "country": "",
        "city": "",
      };
      _hasError= false;
      users = [];
      _searchController.clear();
    });
  }

  Widget _buildLoadingState() => const Center(
    child: Column(
      children: [
        Align(
            alignment: AlignmentGeometry.topCenter,
            child: CircularProgressIndicator(color: Color(0xFF77153C))),
        SizedBox(height: 12),
        Align(
            alignment: AlignmentGeometry.topLeft,
            child: Texts(text: "Searching profiles...", size: 14,colorHexValue: 0xFF9E9E9E,fontWeight: FontWeight.w300, )),
      ],
    ),
  );

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Something went wrong", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _fetchFilteredProfiles(searchTerm: _searchController.text),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF77153C)),
          child: const Text("Try Again", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("No matches found", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
        SizedBox(height: 8),
        Text("Try changing your search or filters", style: TextStyle(fontSize: 14, color: Colors.black), textAlign: TextAlign.center),
      ],
    ),
  );
}