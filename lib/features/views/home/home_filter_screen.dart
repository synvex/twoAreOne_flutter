import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/widgets/app_header_widget.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/features//views/home/profile_card.dart';
import 'package:two_are_one/data/models/user_match_model.dart';
import 'package:two_are_one/data/services/home_service.dart'; // Ensure this matches your Service file
import 'package:two_are_one/data/viewmodels/user_stats_view_model.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import '../../../core/widgets/top_toast.dart';
import '../../../data/repo/socket_service.dart';
import 'filer_sheet.dart';

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
  final Set<int> _starLoading = {};
  final Set<int> _heartLoading = {};
  final Set<int> _blockLoading = {};
  final Map<String, DateTime> _chatCooldowns = {};

  List<FilterMatchModel> users = [];

  Map<String, dynamic> filterParams = {
    "gender": "men",
    "age_range": "", // Apply ke baad ye "18,45" format mein aayega
    "distance_range": "", // Apply ke baad ye "0,500" format mein aayega
    "country": "",
    "city": "",
  };

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _fetchFilteredProfiles(searchTerm: query);
      } else {
        setState(() {
          users = [];
          _hasError = false; // ✅ clear error on empty search
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
      "sexual_preference": filterParams["gender"] == "women"
          ? "Female"
          : "Male",
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
          users[index] = FilterMatchModel(
            // replace object, don't mutate
            id: user.id,
            name: user.name,
            age: user.age,
            location: user.location,
            city: user.city,
            matchPercent: user.matchPercent,
            imagePath: user.imagePath,
            isOnline: user.isOnline,
            isFavorite: !user.isFavorite, // ✅ toggled
            isInterested: user.isInterested,
          );
        }
      });
      // ✅ Keep the Home banner's FAVOURITES count in sync instantly -
      // this screen was previously only updating its own local `users`
      // list, so the banner never found out this action happened here.
      context.read<UserStatsViewModel>().setFavorite(!user.isFavorite);
    }
    setState(() => _starLoading.remove(user.id));
  }

  void _onLikePress(FilterMatchModel user) async {
    setState(() => _heartLoading.add(user.id));
    final success = await _homeService.toggleInterest(
      user.id,
      user.isInterested,
    );
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
      context.read<UserStatsViewModel>().setInterested(!user.isInterested);
    }
    setState(() => _heartLoading.remove(user.id));
  }

  void _onBlockPress(int id) async {
    setState(() => _blockLoading.add(id));
    final user = users.firstWhere(
          (u) => u.id == id,
      orElse: () => FilterMatchModel(
        id: id,
        name: '',
        age: 0,
        location: '',
        city: '',
        matchPercent: '0%',
        imagePath: '',
      ),
    );
    final success = await _homeService.blockUser(id);
    if (success && mounted) {
      setState(() => users.removeWhere((u) => u.id == id));
      context.read<UserStatsViewModel>().userBlocked(
        wasFavorite: user.isFavorite,
        wasInterested: user.isInterested,
      );
    }
    setState(() => _blockLoading.remove(id));
  }

  void _handleSilentChat(FilterMatchModel user) {
    final userId = user.id.toString();
    final now = DateTime.now();
    if (_chatCooldowns.containsKey(userId)) {
      final diff = now.difference(_chatCooldowns[userId]!);
      if (diff.inSeconds < 30) {
        final secondsLeft = 30 - diff.inSeconds;
        TopToast.show(
          context,
          title: "Please wait",
          message: "You can send another invite in ${secondsLeft}s",
          type: ToastType.info,
        );
        _showToast(
          "Please wait ${30 - diff.inSeconds}s to send another invite",
        );
        return;
      }
    }
    final sent = context.read<SocketService>().sendMessage({
      'action': 'send_message',
      'to': user.id,
      'text': "Let's Get To Know Each Other",
    });
    if (sent) {
      _chatCooldowns[userId] = now;
      TopToast.show(
        context,
        title: "Invite sent!",
        message: "Your message has been delivered.",
        type: ToastType.success,
      );
    } else {
      TopToast.show(
        context,
        title: "Couldn't send invite",
        message: "Please check your connection and try again.",
        type: ToastType.error,
      );
    }
  }

  void _showToast(String msg, {ToastType type = ToastType.info}) {
    TopToast.show(context, title: msg, type: type);
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              AppHeaderWidget(isTrailing: false),
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
            border: Border.all(color: Colors.grey.shade500, width: 0.5),
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
          child: const Images(imageStr: "assets/svg_images/filter.svg"),
        ),
      ],
    );
  }

  Widget _buildUserGrid() {
    return GridView.builder(
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
          onPress: () =>
              Navigator.pushNamed(context, '/profile_detail', arguments: user),
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
      _hasError = false;
      users = [];
      _searchController.clear();
    });
  }

  Widget _buildLoadingState() => const Center(
    child: Column(
      children: [
        Align(
          alignment: AlignmentGeometry.topCenter,
          child: CircularProgressIndicator(color: Color(0xFF77153C)),
        ),
        SizedBox(height: 12),
        Align(
          alignment: AlignmentGeometry.topLeft,
          child: Texts(
            text: "Searching profiles...",
            size: 14,
            colorHexValue: 0xFF9E9E9E,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Something went wrong",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () =>
              _fetchFilteredProfiles(searchTerm: _searchController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF77153C),
          ),
          child: const Text("Try Again", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "No matches found",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Try changing your search or filters",
          style: TextStyle(fontSize: 14, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}


