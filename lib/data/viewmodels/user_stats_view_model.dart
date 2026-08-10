import 'package:flutter/foundation.dart';
import 'package:two_are_one/data/services/home_service.dart';


class UserStatsViewModel extends ChangeNotifier {
  UserStatsViewModel({HomeService? homeService})
      : _homeService = homeService ?? HomeService();

  final HomeService _homeService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  String userName = "Loading...";
  String userEmail = "";
  String? profileImageUrl;

  int favCount = 0;
  int interestedCount = 0;
  int blockCount = 0;

  Future<void> loadUserInfo({bool force = false}) async {
    if (_isLoading) return;
    if (_hasLoadedOnce && !force) return;

    _isLoading = true;
    notifyListeners();

    final res = await _homeService.getUserInfo();
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>? ?? {};

      userName = data['full_name']?.toString() ?? "User";
      userEmail = data['email']?.toString() ?? "";

      final rawImage = data['profile_picture']?.toString() ?? '';
      if (rawImage.endsWith('/uploads/') || rawImage.isEmpty) {
        profileImageUrl = null;
      } else {
        profileImageUrl = rawImage.startsWith('http')
            ? rawImage
            : 'https://www.twoareone.love/uploads/$rawImage';
      }

      favCount = int.tryParse(data['total_favorites']?.toString() ?? '0') ?? 0;
      interestedCount =
          int.tryParse(data['total_interested']?.toString() ?? '0') ?? 0;
      blockCount = int.tryParse(data['total_blocks']?.toString() ?? '0') ?? 0;
      _hasLoadedOnce = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFavorite(bool isNowFavorite) {
    favCount += isNowFavorite ? 1 : -1;
    if (favCount < 0) favCount = 0;
    notifyListeners();
    _reconcile();
  }

  void setInterested(bool isNowInterested) {
    interestedCount += isNowInterested ? 1 : -1;
    if (interestedCount < 0) interestedCount = 0;
    notifyListeners();
    _reconcile();
  }

  /// Call when a user is blocked. [wasFavorite]/[wasInterested] let the
  /// banner also drop that user out of the Favourites/Interested totals,
  /// mirroring what the backend does when a block removes those relations.
  void userBlocked({bool wasFavorite = false, bool wasInterested = false}) {
    blockCount += 1;
    if (wasFavorite) favCount = (favCount - 1).clamp(0, 1 << 31);
    if (wasInterested) interestedCount = (interestedCount - 1).clamp(0, 1 << 31);
    notifyListeners();
    _reconcile();
  }

  void userUnblocked() {
    blockCount = (blockCount - 1).clamp(0, 1 << 31);
    notifyListeners();
    _reconcile();
  }

  void setEmail(String newEmail) {
    userEmail = newEmail;
    notifyListeners();
  }

  void setProfile({String? name, String? imageUrl}) {
    if (name != null) userName = name;
    if (imageUrl != null) profileImageUrl = imageUrl;
    notifyListeners();
  }
  void reconcile() => _reconcile();
  void _reconcile() {
    // ignore: discarded_futures
    loadUserInfo(force: true);
  }
}

// import 'package:flutter/foundation.dart';
// import 'package:two_are_one/data/services/home_service.dart';
//
// class UserStatsViewModel extends ChangeNotifier {
//   UserStatsViewModel({HomeService? homeService})
//       : _homeService = homeService ?? HomeService();
//
//   final HomeService _homeService;
//
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//
//   bool _hasLoadedOnce = false;
//   bool get hasLoadedOnce => _hasLoadedOnce;
//
//   String userName = "Loading...";
//   String userEmail = "";
//   String? profileImageUrl;
//
//   int favCount = 0;
//   int interestedCount = 0;
//   int blockCount = 0;
//
//   Future<void> loadUserInfo({bool force = false}) async {
//     if (_isLoading) return;
//     if (_hasLoadedOnce && !force) return;
//
//     _isLoading = true;
//     notifyListeners();
//
//     final res = await _homeService.getUserInfo();
//     if (res['success'] == true) {
//       final data = res['data'] as Map<String, dynamic>? ?? {};
//
//       userName = data['full_name']?.toString() ?? "User";
//       userEmail = data['email']?.toString() ?? "";
//
//       final rawImage = data['profile_picture']?.toString() ?? '';
//       if (rawImage.endsWith('/uploads/') || rawImage.isEmpty) {
//         profileImageUrl = null;
//       } else {
//         profileImageUrl = rawImage.startsWith('http')
//             ? rawImage
//             : 'https://www.twoareone.love/uploads/$rawImage';
//       }
//
//       favCount = int.tryParse(data['total_favorites']?.toString() ?? '0') ?? 0;
//       interestedCount =
//           int.tryParse(data['total_interested']?.toString() ?? '0') ?? 0;
//       blockCount = int.tryParse(data['total_blocks']?.toString() ?? '0') ?? 0;
//       _hasLoadedOnce = true;
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   // ─── Mutators called from ANY screen that changes fav/interest/block ────
//   // Every one of these ends in notifyListeners(), which instantly rebuilds
//   // the Home banner (and any other widget listening) no matter which
//   // screen triggered the change and no matter whether Home is currently
//   // visible or just kept alive in the background by IndexedStack.
//
//   void setFavorite(bool isNowFavorite) {
//     favCount += isNowFavorite ? 1 : -1;
//     if (favCount < 0) favCount = 0;
//     notifyListeners();
//   }
//
//   void setInterested(bool isNowInterested) {
//     interestedCount += isNowInterested ? 1 : -1;
//     if (interestedCount < 0) interestedCount = 0;
//     notifyListeners();
//   }
//
//   /// Call when a user is blocked. [wasFavorite]/[wasInterested] let the
//   /// banner also drop that user out of the Favourites/Interested totals,
//   /// mirroring what the backend does when a block removes those relations.
//   void userBlocked({bool wasFavorite = false, bool wasInterested = false}) {
//     blockCount += 1;
//     if (wasFavorite) favCount = (favCount - 1).clamp(0, 1 << 31);
//     if (wasInterested) interestedCount = (interestedCount - 1).clamp(0, 1 << 31);
//     notifyListeners();
//   }
//
//   void userUnblocked() {
//     blockCount = (blockCount - 1).clamp(0, 1 << 31);
//     notifyListeners();
//   }
//
//   void setEmail(String newEmail) {
//     userEmail = newEmail;
//     notifyListeners();
//   }
//
//   void setProfile({String? name, String? imageUrl}) {
//     if (name != null) userName = name;
//     if (imageUrl != null) profileImageUrl = imageUrl;
//     notifyListeners();
//   }
// }