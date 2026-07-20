import 'package:flutter/foundation.dart';
import 'package:two_are_one/data/services/interested_services.dart';

import '../../../core/constants/app_constants.dart';
import '../../core/network/interested_api_client.dart';
import '../../data/models/favourite_model.dart';
import '../../data/models/interested_model.dart';
import '../../data/services/favourite_services.dart';

// class FavouriteViewModel extends ChangeNotifier {
//   FavouriteViewModel({FavouriteServices? repository})
//       : _repository = repository ?? FavouriteServices();
//
//   final FavouriteServices _repository;
//
//   // ─── State ──────────────────────────────────────────────────────────────
//   FavouriteTab _activeTab = FavouriteTab.interestedYou;
//   FavouriteTab get activeTab => _activeTab;
//
//   final Map<FavouriteTab, FavouriteTabState> _tabs = {
//     FavouriteTab.interestedYou: FavouriteTabState(hasMore: false),
//     FavouriteTab.yourFavourite: FavouriteTabState(hasMore: true),
//   };
//
//   bool _refreshing = false;
//   bool get isRefreshing => _refreshing;
//
//   FavouriteUserModel? _selectedItem;
//   FavouriteUserModel? get selectedItem => _selectedItem;
//
//   bool _blockUserLoading = false;
//   bool get blockUserLoading => _blockUserLoading;
//
//   bool _removeLoading = false;
//   bool get removeLoading => _removeLoading;
//
//   bool _showBottomSheet = false;
//   bool get showBottomSheet => _showBottomSheet;
//
//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;
//
//   // Guard against duplicate pagination calls in-flight, same as
//   // `isFetchingRef` in RN.
//   bool _isFetching = false;
//
//   FavouriteTabState get currentTabState => _tabs[_activeTab]!;
//   List<FavouriteUserModel> get currentItems => currentTabState.items;
//   bool get isLoadingCurrentTab => currentTabState.isLoading;
//   bool get hasMoreCurrentTab => currentTabState.hasMore;
//
//   /// Show the full-screen spinner only on the very first page load,
//   /// same condition as RN: `loadingTabs[tab] && tabData[tab].length === 0`.
//   bool get showInitialLoader => isLoadingCurrentTab && currentItems.isEmpty;
//
//   /// Show skeleton footer rows only while paginating past page 1.
//   bool get showSkeletonFooter => isLoadingCurrentTab && currentItems.isNotEmpty;
//
//   bool get showEmptyState => !isLoadingCurrentTab && currentItems.isEmpty;
//
//   String get emptyMessage => _activeTab.emptyMessage;
//
//   // ─── Lifecycle ──────────────────────────────────────────────────────────
//   /// Call once from the View's `initState` - RN's `useEffect(() => { getData(activeTab, 1, true) }, [])`.
//   Future<void> init() => _getData(_activeTab, page: 1);
//
//   // ─── Data fetching ──────────────────────────────────────────────────────
//   /// RN: `getData(tab, page, refresh)`.
//   Future<void> _getData(FavouriteTab tab, {required int page}) async {
//     if (_isFetching && page > 1) return;
//     _isFetching = true;
//
//     _updateTab(tab, (s) => s.copyWith(isLoading: true));
//     notifyListeners();
//
//     try {
//       final newItems = tab == FavouriteTab.interestedYou
//           ? await _repository.fetchFavouriteYou()
//           : await _repository.fetchYourFavourite(page: page, perPage: AppConstants.perPage);
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
//       // Catches network errors, parsing errors, and anything else so the
//       // UI never gets stuck on a spinner.
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
//
//   void _updateTab(FavouriteTab tab, FavouriteTabState Function(FavouriteTabState) update) {
//     _tabs[tab] = update(_tabs[tab]!);
//   }
//
//   /// Clears a one-shot error after the View has shown it (e.g. in a SnackBar).
//   void consumeError() {
//     _errorMessage = null;
//     debugPrint(_errorMessage);
//   }
//
//   // ─── Pagination ─────────────────────────────────────────────────────────
//   /// RN: `loadMore()` - pagination only applies to "Your Favourite".
//   Future<void> loadMore() async {
//     if (_activeTab == FavouriteTab.interestedYou) return;
//     final state = currentTabState;
//     if (!state.isLoading && state.hasMore) {
//       await _getData(_activeTab, page: state.page + 1);
//     }
//   }
//   // ─── Pull-to-refresh ────────────────────────────────────────────────────
//   /// RN: `refreshList()`.
//   Future<void> refresh() async {
//     _refreshing = true;
//     notifyListeners();
//     await _getData(_activeTab, page: 1);
//   }
//
//   // ─── Tab switch ─────────────────────────────────────────────────────────
//   /// RN: `handleTabSwitch(tab)`.
//   Future<void> switchTab(FavouriteTab tab) async {
//     if (_activeTab == tab) return;
//     _activeTab = tab;
//     notifyListeners();
//     if (_tabs[tab]!.items.isEmpty) {
//       await _getData(tab, page: 1);
//     }
//   }

  // ─── Bottom sheet selection ─────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../data/models/favourite_model.dart';
import '../../data/services/favourite_services.dart';

class FavouriteViewModel extends ChangeNotifier {
  FavouriteViewModel({FavouriteServices? repository})
      : _repository = repository ?? FavouriteServices();

  final FavouriteServices _repository;

  // --- State ---
  FavouriteTab _activeTab = FavouriteTab.favouriteYou; // Fixed name
  FavouriteTab get activeTab => _activeTab;

  final Map<FavouriteTab, FavouriteTabState> _tabs = {
    FavouriteTab.favouriteYou: FavouriteTabState(hasMore: false),
    FavouriteTab.yourFavourite: FavouriteTabState(hasMore: true),
  };

  bool _refreshing = false;
  bool get isRefreshing => _refreshing;

  FavouriteUserModel? _selectedItem; // Fixed: Added missing field
  FavouriteUserModel? get selectedItem => _selectedItem;

  bool _blockUserLoading = false; // Fixed: Added missing field
  bool get blockUserLoading => _blockUserLoading;

  bool _removeLoading = false; // Fixed: Added missing field
  bool get removeLoading => _removeLoading;

  bool _showBottomSheet = false; // Fixed: Added missing field
  bool get showBottomSheet => _showBottomSheet;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isFetching = false;

  FavouriteTabState get currentTabState => _tabs[_activeTab]!;
  List<FavouriteUserModel> get currentItems => currentTabState.items;
  bool get isLoadingCurrentTab => currentTabState.isLoading;
  bool get hasMoreCurrentTab => currentTabState.hasMore;

  bool get showInitialLoader => isLoadingCurrentTab && currentItems.isEmpty;
  bool get showSkeletonFooter => isLoadingCurrentTab && currentItems.isNotEmpty;
  bool get showEmptyState => !isLoadingCurrentTab && currentItems.isEmpty;
  String get emptyMessage => _activeTab.emptyMessage;

  // --- Lifecycle ---
  Future<void> init() => _getData(_activeTab, page: 1);

  // --- Data Fetching ---
  Future<void> _getData(FavouriteTab tab, {required int page}) async {
    if (_isFetching && page > 1) return;
    _isFetching = true;

    _updateTab(tab, (s) => s.copyWith(isLoading: true));
    notifyListeners();

    try {
      final newItems = tab == FavouriteTab.favouriteYou
          ? await _repository.fetchFavouriteYou()
          : await _repository.fetchYourFavourite(page: page, perPage: AppConstants.perPage);

      _updateTab(tab, (s) {
        final merged = page == 1 ? newItems : [...s.items, ...newItems];
        return s.copyWith(
          items: merged,
          page: page,
          hasMore: newItems.length >= AppConstants.perPage,
          isLoading: false,
        );
      });
    } catch (e) {
      debugPrint('Favourite fetch error: $e');
      _errorMessage = "Failed to load favorites";
      _updateTab(tab, (s) => s.copyWith(isLoading: false));
    } finally {
      _isFetching = false;
      _refreshing = false;
      notifyListeners();
    }
  }

  // Fixed: Added the missing _updateTab method
  void _updateTab(FavouriteTab tab, FavouriteTabState Function(FavouriteTabState) update) {
    _tabs[tab] = update(_tabs[tab]!);
  }

  void consumeError() {
    _errorMessage = null;
  }

  Future<void> loadMore() async {
    if (_activeTab == FavouriteTab.favouriteYou) return;
    final state = currentTabState;
    if (!state.isLoading && state.hasMore) {
      await _getData(_activeTab, page: state.page + 1);
    }
  }

  Future<void> refresh() async {
    _refreshing = true;
    notifyListeners();
    await _getData(_activeTab, page: 1);
  }

  Future<void> switchTab(FavouriteTab tab) async {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
    if (_tabs[tab]!.items.isEmpty) {
      await _getData(tab, page: 1);
    }
  }

  void selectItem(FavouriteUserModel item) {
    _selectedItem = item;
    _showBottomSheet = true;
    notifyListeners();
  }

  void closeBottomSheet() {
    _showBottomSheet = false;
    notifyListeners();
  }

  // --- Actions ---
  Future<void> blockSelectedUser() async {
    if (_selectedItem == null) return;
    _blockUserLoading = true;
    notifyListeners();
    try {
      await _repository.blockUser(_selectedItem!.id);
      _itemsRemovedLocally(_selectedItem!.id);
      _showBottomSheet = false;
    } catch (e) {
      _errorMessage = "Failed to block user";
    } finally {
      _blockUserLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSelected() async {
    if (_selectedItem == null) return;
    _removeLoading = true;
    notifyListeners();
    try {
      if (_activeTab == FavouriteTab.favouriteYou) {
        await _repository.removeFromFavouriteYou(_selectedItem!.id);
      } else {
        await _repository.removeFromYourFavourite(_selectedItem!.id);
      }
      _itemsRemovedLocally(_selectedItem!.id);
      _showBottomSheet = false;
    } catch (e) {
      _errorMessage = "Failed to remove from favorites";
    } finally {
      _removeLoading = false;
      notifyListeners();
    }
  }

  void _itemsRemovedLocally(int id) {
    _updateTab(_activeTab, (s) => s.copyWith(
      items: s.items.where((u) => u.id != id).toList(),
    ));
  }

  // --- Utils ---
  String? resolveImageUrl(String? image) {
    if (image == null || image.isEmpty || image == 'null') return null;
    if (image.startsWith('http')) return image;
    return '${AppConstants.uploadImagesUrl}$image';
  }

  String initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class FavouriteTabState {
  final List<FavouriteUserModel> items;
  final int page;
  final bool hasMore;
  final bool isLoading;

  FavouriteTabState({
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

enum FavouriteTab { favouriteYou, yourFavourite }

extension FavouriteTabLabel on FavouriteTab {
  String get label => this == FavouriteTab.favouriteYou ? 'Favourite You' : 'Your Favourite';
  String get emptyMessage => this == FavouriteTab.favouriteYou
      ? 'No one has favorited you yet.'
      : 'You haven\'t added anyone to favorites.';
}

// class FavouriteViewModel extends ChangeNotifier {
//   final FavouriteServices _repository = FavouriteServices();
//
//   FavouriteTab _activeTab = FavouriteTab.favouriteYou;
//   FavouriteTab get activeTab => _activeTab;
//
//   final Map<FavouriteTab, List<FavouriteUserModel>> _items = {
//     FavouriteTab.favouriteYou: [],
//     FavouriteTab.yourFavourite: [],
//   };
//
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//
//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;
//
//   List<FavouriteUserModel> get currentItems => _items[_activeTab]!;
//
//   Future<void> init() => getData();
//
//   Future<void> getData() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       final data = _activeTab == FavouriteTab.favouriteYou
//           ? await _repository.fetchFavouriteYou()
//           : await _repository.fetchYourFavourite(page: 1, perPage: 10);
//       _items[_activeTab] = data;
//     } catch (e) {
//       _errorMessage = "Failed to load favorites";
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void switchTab(FavouriteTab tab) {
//     if (_activeTab == tab) return;
//     _activeTab = tab;
//     if (_items[tab]!.isEmpty) getData();
//     notifyListeners();
//   }
//   void selectItem(FavouriteUserModel item) {
//     _selectedItem = item;
//     _showBottomSheet = true;
//     notifyListeners();
//   }
//
//   void closeBottomSheet() {
//     _showBottomSheet = false;
//     notifyListeners();
//   }
//
//   // ─── Helpers ────────────────────────────────────────────────────────────
//   /// RN: `removeFromList(id)`.
//   void _removeFromCurrentList(int id) {
//     _updateTab(_activeTab, (s) => s.copyWith(
//       items: s.items.where((u) => u.id != id).toList(),
//     ));
//     notifyListeners();
//   }
//   void _restoreToCurrentList(FavouriteUserModel item) {
//     _updateTab(_activeTab, (s) => s.copyWith(items: [...s.items, item]));
//     notifyListeners();
//   }
//
//   // ─── Actions ────────────────────────────────────────────────────────────
//   /// RN: `blockedUser()`.
//   Future<void> blockSelectedUser() async {
//     final item = _selectedItem;
//     if (item == null) return;
//     _blockUserLoading = true;
//     notifyListeners();
//     try {
//       await _repository.blockUser(item.id);
//       _blockUserLoading = false;
//       _showBottomSheet = false;
//       _removeFromCurrentList(item.id);
//     } on FavouriteApiException catch (e) {
//       _errorMessage = e.message;
//       _blockUserLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// RN: `onUnfavoritePress()` - "Remove from Favourite" on the
//   /// "Your Favourite" tab.
//   Future<void> removeFromYourFavourite() async {
//     final item = _selectedItem;
//     if (item == null) return;
//     _removeLoading = true;
//     notifyListeners();
//     try {
//       await _repository.removeFromYourFavourite(item.id);
//       _removeLoading = false;
//       _showBottomSheet = false;
//       _removeFromCurrentList(item.id);
//     } on FavouriteApiException catch (e) {
//       _errorMessage = e.message;
//       _removeLoading = false;
//       _restoreToCurrentList(item);
//     }
//   }
//
//   /// "Favourite You" tab.
//   Future<void> removeFromFavouriteYou() async {
//     final item = _selectedItem;
//     if (item == null) return;
//     _removeLoading = true;
//     notifyListeners();
//     try {
//       await _repository.removeFromFavouriteYou(item.id);
//       _removeLoading = false;
//       _showBottomSheet = false;
//       _removeFromCurrentList(item.id);
//     } on FavouriteApiException catch (e) {
//       _errorMessage = e.message;
//       _removeLoading = false;
//       _restoreToCurrentList(item);
//     }
//   }
//
//   Future<void> removeSelected() {
//     return _activeTab == FavouriteTab.interestedYou
//         ? removeFromFavouriteYou()
//         : removeFromYourFavourite();
//   }
//
//   // ─── Presentation utils ─────────────────────────────────────────────────
//   /// RN: `getImageUrl(image)`.
//   String? resolveImageUrl(String? image) {
//     if (image == null || image.isEmpty || image == 'null') return null;
//     final clean = image.trim();
//     if (RegExp(r'/uploads/?$').hasMatch(clean)) return null;
//     if (clean.startsWith('http')) return clean;
//     return '${AppConstants.uploadImagesUrl}$clean';
//   }
//
//   /// RN: `getInitials(name)`.
//   String initialsFor(String name) {
//     final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
//     if (words.isEmpty) return '';
//     if (words.length == 1) return words[0][0].toUpperCase();
//     return (words[0][0] + words[1][0]).toUpperCase();
//   }
//
//   /// RN: `capitalizeFirstLetter(text)`.
//   String capitalize(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1);
//   }
// }
// class FavouriteTabState {
//   List<FavouriteUserModel> items;
//   int page;
//   bool hasMore;
//   bool isLoading;
//
//   FavouriteTabState({
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
// /// Mirrors the RN `activeTab` values: `'interestedYou' | 'yourFavourite'`.
// enum FavouriteTab { interestedYou, yourFavourite }
//
// extension FavouriteTabLabel on FavouriteTab {
//   String get label => switch (this) {
//     FavouriteTab.interestedYou => 'Favourite You',
//     FavouriteTab.yourFavourite => 'Your Favourite',
//   };
//
//   String get emptyMessage => switch (this) {
//     FavouriteTab.interestedYou => 'No one has shown interest in you yet.',
//     FavouriteTab.yourFavourite => "You haven't shown interest in anyone yet.",
//   };
// }