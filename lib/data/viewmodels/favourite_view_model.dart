import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../data/models/favourite_model.dart';
import '../../data/services/Api_Helper/api_manager.dart' show navigatorKey;
import '../exceptions/api_exceptions.dart';
import '../repo/favourites_repo.dart';
import 'user_stats_view_model.dart';
enum FavouriteTab { favouritedYou, yourFavourites }
extension FavouriteTabLabel on FavouriteTab {
  String get label => switch (this) {
    FavouriteTab.favouritedYou => 'Favourited You',
    FavouriteTab.yourFavourites => 'Your Favourites',
  };

  String get emptyMessage => switch (this) {
    FavouriteTab.favouritedYou => 'No one has favourited you yet.',
    FavouriteTab.yourFavourites => "You haven't favourited anyone yet.",
  };
}
class FavouriteTabState {
  final List<FavouriteUserModel> items;
  final int page;
  final bool hasMore;
  final bool isLoading;

  const FavouriteTabState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
  });

  FavouriteTabState copyWith({
    List<FavouriteUserModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
  }) {
    return FavouriteTabState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
class FavouriteViewModel extends ChangeNotifier {
  FavouriteViewModel({FavouriteServices? services}) : _services = services ?? FavouriteServices();

  final FavouriteServices _services;

  FavouriteTab _activeTab = FavouriteTab.favouritedYou;
  FavouriteTab get activeTab => _activeTab;

  final Map<FavouriteTab, FavouriteTabState> _tabs = {
    FavouriteTab.favouritedYou: const FavouriteTabState(),
    FavouriteTab.yourFavourites: const FavouriteTabState(),
  };

  bool _refreshing = false;
  bool get isRefreshing => _refreshing;

  // Guards against duplicate pagination calls in-flight.
  bool _isFetching = false;

  FavouriteUserModel? _selectedItem;
  FavouriteUserModel? get selectedItem => _selectedItem;

  bool _removeLoading = false;
  bool get removeLoading => _removeLoading;

  bool _blockUserLoading = false;
  bool get blockUserLoading => _blockUserLoading;

  bool _showBottomSheet = false;
  bool get showBottomSheet => _showBottomSheet;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FavouriteTabState get currentTabState => _tabs[_activeTab]!;
  List<FavouriteUserModel> get currentItems => currentTabState.items;
  bool get isLoadingCurrentTab => currentTabState.isLoading;
  bool get hasMoreCurrentTab => currentTabState.hasMore;

  bool get showInitialLoader => isLoadingCurrentTab && currentItems.isEmpty;
  bool get showSkeletonFooter => isLoadingCurrentTab && currentItems.isNotEmpty;
  bool get showEmptyState => !isLoadingCurrentTab && currentItems.isEmpty;
  String get emptyMessage => _activeTab.emptyMessage;
  // ─── Lifecycle ──────────────────────────────────────────────────────────
  /// Call once from the View's `initState`.
  Future<void> init() => _getData(_activeTab, page: 1);
  // ─── Data fetching ──────────────────────────────────────────────────────
  Future<void> _getData(FavouriteTab tab, {required int page}) async {
    if (_isFetching && page > 1) return;
    _isFetching = true;

    _updateTab(tab, (s) => s.copyWith(isLoading: true));
    notifyListeners();

    try {
      final newItems = tab == FavouriteTab.favouritedYou
          ? await _services.fetchFavouritedYou(page: page, perPage: AppConstants.perPage)
          : await _services.fetchYourFavourites(page: page, perPage: AppConstants.perPage);

      _updateTab(tab, (s) {
        final merged = page == 1 ? newItems : [...s.items, ...newItems];
        return s.copyWith(
          items: merged,
          page: page,
          hasMore: newItems.length >= AppConstants.perPage,
        );
      });
    } catch (e, stack) {
      debugPrint('FavouriteViewModel._getData error: $e\n$stack');
      _errorMessage = e.toString().isNotEmpty ? e.toString() : 'Something went wrong';
      if (page == 1) {
        _updateTab(tab, (s) => s.copyWith(items: []));
      }
    } finally {
      _isFetching = false;
      _refreshing = false;
      _updateTab(tab, (s) => s.copyWith(isLoading: false));
      notifyListeners();
    }
  }
  void _updateTab(FavouriteTab tab, FavouriteTabState Function(FavouriteTabState) update) {
    _tabs[tab] = update(_tabs[tab]!);
  }
  void consumeError() {
    _errorMessage = null;
  }
  // ─── Pagination ─────────────────────────────────────────────────────────
  Future<void> loadMore() async {
    final state = currentTabState;
    if (!state.isLoading && state.hasMore) {
      await _getData(_activeTab, page: state.page + 1);
    }
  }
  // ─── Pull-to-refresh ────────────────────────────────────────────────────
  Future<void> refresh() async {
    _refreshing = true;
    notifyListeners();
    await _getData(_activeTab, page: 1);
  }
  // ─── Tab switch ─────────────────────────────────────────────────────────
  Future<void> switchTab(FavouriteTab tab) async {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
    if (_tabs[tab]!.items.isEmpty) {
      await _getData(tab, page: 1);
    }
  }
  // ─── Bottom sheet selection ─────────────────────────────────────────────
  void selectItem(FavouriteUserModel item) {
    _selectedItem = item;
    _showBottomSheet = true;
    notifyListeners();
  }
  void closeBottomSheet() {
    _showBottomSheet = false;
    notifyListeners();
  }
  // ─── Helpers ────────────────────────────────────────────────────────────
  void _removeFromCurrentList(int id) {
    _updateTab(_activeTab, (s) => s.copyWith(
      items: s.items.where((u) => u.id != id).toList(),
    ));
    notifyListeners();
  }
  void _restoreToCurrentList(FavouriteUserModel item) {
    _updateTab(_activeTab, (s) => s.copyWith(items: [...s.items, item]));
    notifyListeners();
  }

  UserStatsViewModel? get _stats =>
      navigatorKey.currentContext?.read<UserStatsViewModel>();

  // ─── Actions ────────────────────────────────────────────────────────────
  Future<void> removeSelected() async {
    final item = _selectedItem;
    if (item == null) return;

    _removeLoading = true;
    notifyListeners();
    debugPrint('Remove user Selected');
    try {
      if (_activeTab == FavouriteTab.favouritedYou) {
        await _services.removeFavouritedYou(item.id);
      } else {
        await _services.removeFromYourFavourites(item.id);
        // Only "Your Favourites" feeds the Home banner's FAVOURITES count.
        _stats?.setFavorite(false);
      }
      _removeLoading = false;
      _showBottomSheet = false;
      _removeFromCurrentList(item.id);
    } on FavouriteApiException catch (e) {
      _errorMessage = e.message;
      _removeLoading = false;
      notifyListeners();
    }
  }
  Future<void> blockSelectedUser() async {
    final item = _selectedItem;
    if (item == null) return;

    _blockUserLoading = true;
    notifyListeners();
    debugPrint(' block user Selected');
    try {
      await _services.blockUser(item.id);
      _blockUserLoading = false;
      _showBottomSheet = false;
      _removeFromCurrentList(item.id);
      // Blocking always bumps BLOCKS; it also drops the user from
      // "Your Favourites" if that's where they came from.
      _stats?.userBlocked(wasFavorite: _activeTab == FavouriteTab.yourFavourites);
    } on FavouriteApiException catch (e) {

      _errorMessage = e.message;
      _blockUserLoading = false;
      notifyListeners();
      debugPrint(' block user Selected error ${e.message}');

    }
  }
  // ─── Presentation utils ─────────────────────────────────────────────────
  String? resolveImageUrl(String? image) {
    if (image == null || image.isEmpty || image == 'null') return null;
    final clean = image.trim();
    if (RegExp(r'/uploads/?$').hasMatch(clean)) return null;
    if (clean.startsWith('http')) return clean;
    return '${AppConstants.uploadImagesUrl}$clean';
  }
  String initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }
  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}


// import 'package:flutter/foundation.dart';
// import '../../../core/constants/app_constants.dart';
// import '../../data/models/favourite_model.dart';
// import '../exceptions/api_exceptions.dart';
// import '../repo/favourites_repo.dart';
// enum FavouriteTab { favouritedYou, yourFavourites }
// extension FavouriteTabLabel on FavouriteTab {
//   String get label => switch (this) {
//     FavouriteTab.favouritedYou => 'Favourited You',
//     FavouriteTab.yourFavourites => 'Your Favourites',
//   };
//
//   String get emptyMessage => switch (this) {
//     FavouriteTab.favouritedYou => 'No one has favourited you yet.',
//     FavouriteTab.yourFavourites => "You haven't favourited anyone yet.",
//   };
// }
// class FavouriteTabState {
//   final List<FavouriteUserModel> items;
//   final int page;
//   final bool hasMore;
//   final bool isLoading;
//
//   const FavouriteTabState({
//     this.items = const [],
//     this.page = 1,
//     this.hasMore = true,
//     this.isLoading = false,
//   });
//
//   FavouriteTabState copyWith({
//     List<FavouriteUserModel>? items,
//     int? page,
//     bool? hasMore,
//     bool? isLoading,
//   }) {
//     return FavouriteTabState(
//       items: items ?? this.items,
//       page: page ?? this.page,
//       hasMore: hasMore ?? this.hasMore,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }
// class FavouriteViewModel extends ChangeNotifier {
//   FavouriteViewModel({FavouriteServices? services}) : _services = services ?? FavouriteServices();
//
//   final FavouriteServices _services;
//
//   FavouriteTab _activeTab = FavouriteTab.favouritedYou;
//   FavouriteTab get activeTab => _activeTab;
//
//   final Map<FavouriteTab, FavouriteTabState> _tabs = {
//     FavouriteTab.favouritedYou: const FavouriteTabState(),
//     FavouriteTab.yourFavourites: const FavouriteTabState(),
//   };
//
//   bool _refreshing = false;
//   bool get isRefreshing => _refreshing;
//
//   // Guards against duplicate pagination calls in-flight.
//   bool _isFetching = false;
//
//   FavouriteUserModel? _selectedItem;
//   FavouriteUserModel? get selectedItem => _selectedItem;
//
//   bool _removeLoading = false;
//   bool get removeLoading => _removeLoading;
//
//   bool _blockUserLoading = false;
//   bool get blockUserLoading => _blockUserLoading;
//
//   bool _showBottomSheet = false;
//   bool get showBottomSheet => _showBottomSheet;
//
//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;
//
//   FavouriteTabState get currentTabState => _tabs[_activeTab]!;
//   List<FavouriteUserModel> get currentItems => currentTabState.items;
//   bool get isLoadingCurrentTab => currentTabState.isLoading;
//   bool get hasMoreCurrentTab => currentTabState.hasMore;
//
//   bool get showInitialLoader => isLoadingCurrentTab && currentItems.isEmpty;
//   bool get showSkeletonFooter => isLoadingCurrentTab && currentItems.isNotEmpty;
//   bool get showEmptyState => !isLoadingCurrentTab && currentItems.isEmpty;
//   String get emptyMessage => _activeTab.emptyMessage;
//   // ─── Lifecycle ──────────────────────────────────────────────────────────
//   /// Call once from the View's `initState`.
//   Future<void> init() => _getData(_activeTab, page: 1);
//   // ─── Data fetching ──────────────────────────────────────────────────────
//   Future<void> _getData(FavouriteTab tab, {required int page}) async {
//     if (_isFetching && page > 1) return;
//     _isFetching = true;
//
//     _updateTab(tab, (s) => s.copyWith(isLoading: true));
//     notifyListeners();
//
//     try {
//       final newItems = tab == FavouriteTab.favouritedYou
//           ? await _services.fetchFavouritedYou(page: page, perPage: AppConstants.perPage)
//           : await _services.fetchYourFavourites(page: page, perPage: AppConstants.perPage);
//
//       _updateTab(tab, (s) {
//         final merged = page == 1 ? newItems : [...s.items, ...newItems];
//         return s.copyWith(
//           items: merged,
//           page: page,
//           hasMore: newItems.length >= AppConstants.perPage,
//         );
//       });
//     } catch (e, stack) {
//       debugPrint('FavouriteViewModel._getData error: $e\n$stack');
//       _errorMessage = e.toString().isNotEmpty ? e.toString() : 'Something went wrong';
//       if (page == 1) {
//         _updateTab(tab, (s) => s.copyWith(items: []));
//       }
//     } finally {
//       _isFetching = false;
//       _refreshing = false;
//       _updateTab(tab, (s) => s.copyWith(isLoading: false));
//       notifyListeners();
//     }
//   }
//   void _updateTab(FavouriteTab tab, FavouriteTabState Function(FavouriteTabState) update) {
//     _tabs[tab] = update(_tabs[tab]!);
//   }
//   /// Clears a one-shot error after the View has shown it (e.g. SnackBar).
//   void consumeError() {
//     _errorMessage = null;
//   }
//   // ─── Pagination ─────────────────────────────────────────────────────────
//   Future<void> loadMore() async {
//     final state = currentTabState;
//     if (!state.isLoading && state.hasMore) {
//       await _getData(_activeTab, page: state.page + 1);
//     }
//   }
//   // ─── Pull-to-refresh ────────────────────────────────────────────────────
//   Future<void> refresh() async {
//     _refreshing = true;
//     notifyListeners();
//     await _getData(_activeTab, page: 1);
//   }
//   // ─── Tab switch ─────────────────────────────────────────────────────────
//   Future<void> switchTab(FavouriteTab tab) async {
//     if (_activeTab == tab) return;
//     _activeTab = tab;
//     notifyListeners();
//     if (_tabs[tab]!.items.isEmpty) {
//       await _getData(tab, page: 1);
//     }
//   }
//   // ─── Bottom sheet selection ─────────────────────────────────────────────
//   void selectItem(FavouriteUserModel item) {
//     _selectedItem = item;
//     _showBottomSheet = true;
//     notifyListeners();
//   }
//   void closeBottomSheet() {
//     _showBottomSheet = false;
//     notifyListeners();
//   }
//   // ─── Helpers ────────────────────────────────────────────────────────────
//   void _removeFromCurrentList(int id) {
//     _updateTab(_activeTab, (s) => s.copyWith(
//       items: s.items.where((u) => u.id != id).toList(),
//     ));
//     notifyListeners();
//   }
//   void _restoreToCurrentList(FavouriteUserModel item) {
//     _updateTab(_activeTab, (s) => s.copyWith(items: [...s.items, item]));
//     notifyListeners();
//   }  // ─── Actions ────────────────────────────────────────────────────────────
//   Future<void> removeSelected() async {
//     final item = _selectedItem;
//     if (item == null) return;
//
//     _removeLoading = true;
//     notifyListeners();
//     debugPrint('Remove user Selected');
//     try {
//       if (_activeTab == FavouriteTab.favouritedYou) {
//         await _services.removeFavouritedYou(item.id);
//       } else {
//         await _services.removeFromYourFavourites(item.id);
//       }
//       _removeLoading = false;
//       _showBottomSheet = false;
//       _removeFromCurrentList(item.id);
//     } on FavouriteApiException catch (e) {
//       _errorMessage = e.message;
//       _removeLoading = false;
//       notifyListeners();
//     }
//   }
//   Future<void> blockSelectedUser() async {
//     final item = _selectedItem;
//     if (item == null) return;
//
//     _blockUserLoading = true;
//     notifyListeners();
//     debugPrint(' block user Selected');
//     try {
//       await _services.blockUser(item.id);
//       _blockUserLoading = false;
//       _showBottomSheet = false;
//       _removeFromCurrentList(item.id);
//     } on FavouriteApiException catch (e) {
//
//       _errorMessage = e.message;
//       _blockUserLoading = false;
//       notifyListeners();
//       debugPrint(' block user Selected error ${e.message}');
//
//     }
//   }
//   // ─── Presentation utils ─────────────────────────────────────────────────
//   String? resolveImageUrl(String? image) {
//     if (image == null || image.isEmpty || image == 'null') return null;
//     final clean = image.trim();
//     if (RegExp(r'/uploads/?$').hasMatch(clean)) return null;
//     if (clean.startsWith('http')) return clean;
//     return '${AppConstants.uploadImagesUrl}$clean';
//   }
//   String initialsFor(String name) {
//     final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
//     if (words.isEmpty) return '';
//     if (words.length == 1) return words[0][0].toUpperCase();
//     return (words[0][0] + words[1][0]).toUpperCase();
//   }
//   String capitalize(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1);
//   }
// }
