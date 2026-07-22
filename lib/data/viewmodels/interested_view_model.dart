import 'package:flutter/foundation.dart';
import 'package:two_are_one/data/services/interested_services.dart';

import '../../../core/constants/app_constants.dart';
import '../../core/network/interested_api_client.dart';
import '../../data/models/interested_model.dart';
class InterestedViewModel extends ChangeNotifier {
  InterestedViewModel({InterestedServices? repository})
      : _repository = repository ?? InterestedServices();

  final InterestedServices _repository;

  // ─── State ──────────────────────────────────────────────────────────────
  InterestedTab _activeTab = InterestedTab.interestedYou;
  InterestedTab get activeTab => _activeTab;

  final Map<InterestedTab, InterestedTabState> _tabs = {
    InterestedTab.interestedYou: InterestedTabState(hasMore: false),
    InterestedTab.yourInterested: InterestedTabState(hasMore: true),
  };

  bool _refreshing = false;
  bool get isRefreshing => _refreshing;

  InterestedUserModel? _selectedItem;
  InterestedUserModel? get selectedItem => _selectedItem;

  bool _blockUserLoading = false;
  bool get blockUserLoading => _blockUserLoading;

  bool _removeLoading = false;
  bool get removeLoading => _removeLoading;

  bool _showBottomSheet = false;
  bool get showBottomSheet => _showBottomSheet;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Guard against duplicate pagination calls in-flight, same as
  // `isFetchingRef` in RN.
  bool _isFetching = false;

  InterestedTabState get currentTabState => _tabs[_activeTab]!;
  List<InterestedUserModel> get currentItems => currentTabState.items;
  bool get isLoadingCurrentTab => currentTabState.isLoading;
  bool get hasMoreCurrentTab => currentTabState.hasMore;

  /// Show the full-screen spinner only on the very first page load,
  /// same condition as RN: `loadingTabs[tab] && tabData[tab].length === 0`.
  bool get showInitialLoader => isLoadingCurrentTab && currentItems.isEmpty;

  /// Show skeleton footer rows only while paginating past page 1.
  bool get showSkeletonFooter => isLoadingCurrentTab && currentItems.isNotEmpty;

  bool get showEmptyState => !isLoadingCurrentTab && currentItems.isEmpty;

  String get emptyMessage => _activeTab.emptyMessage;

  // ─── Lifecycle ──────────────────────────────────────────────────────────
  /// Call once from the View's `initState` - RN's `useEffect(() => { getData(activeTab, 1, true) }, [])`.
  Future<void> init() => _getData(_activeTab, page: 1);

  // ─── Data fetching ──────────────────────────────────────────────────────
  /// RN: `getData(tab, page, refresh)`.
  Future<void> _getData(InterestedTab tab, {required int page}) async {
    if (_isFetching && page > 1) return;
    _isFetching = true;

    _updateTab(tab, (s) => s.copyWith(isLoading: true));
    notifyListeners();

    try {
      final newItems = tab == InterestedTab.interestedYou
          ? await _repository.fetchInterestedYou()
          : await _repository.fetchYourInterested(page: page, perPage: AppConstants.perPage);

      _updateTab(tab, (s) {
        final merged = page == 1 ? newItems : [...s.items, ...newItems];
        return s.copyWith(
          items: merged,
          page: page,
          hasMore: newItems.length >= AppConstants.perPage,
        );
      });
    } catch (e, stack) {
      // Catches network errors, parsing errors, and anything else so the
      // UI never gets stuck on a spinner.
      debugPrint('InterestedViewModel._getData error: $e\n$stack');
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

  // Future<void> _getData(InterestedTab tab, {required int page}) async {
  //   if (_isFetching && page > 1) return;
  //   _isFetching = true;
  //
  //   _updateTab(tab, (s) => s.copyWith(isLoading: true));
  //
  //   try {
  //     final newItems = tab == InterestedTab.interestedYou
  //         ? await _repository.fetchInterestedYou()
  //         : await _repository.fetchYourInterested(page: page, perPage: AppConstants.perPage);
  //
  //     _updateTab(tab, (s) {
  //       final merged = page == 1 ? newItems : [...s.items, ...newItems];
  //       return s.copyWith(
  //         items: merged,
  //         page: page,
  //         hasMore: newItems.length >= AppConstants.perPage,
  //         isLoading: false,
  //       );
  //     });
  //     _refreshing = false;
  //     _isFetching = false;
  //   } on InterestedApiException catch (e) {
  //     _isFetching = false;
  //     _refreshing = false;
  //
  //     if (e.message == 'No one has liked you yet!') {
  //       _updateTab(tab, (s) => s.copyWith(items: [], isLoading: false));
  //     } else {
  //       _errorMessage = e.message.isNotEmpty ? e.message : 'Something went wrong';
  //       _updateTab(tab, (s) => s.copyWith(isLoading: false));
  //     }
  //   }
  //   notifyListeners();
  // }

  void _updateTab(InterestedTab tab, InterestedTabState Function(InterestedTabState) update) {
    _tabs[tab] = update(_tabs[tab]!);
  }

  /// Clears a one-shot error after the View has shown it (e.g. in a SnackBar).
  void consumeError() {
    _errorMessage = null;
    debugPrint(_errorMessage);
  }

  // ─── Pagination ─────────────────────────────────────────────────────────
  /// RN: `loadMore()` - pagination only applies to "Your Interested".
  Future<void> loadMore() async {
    if (_activeTab == InterestedTab.interestedYou) return;
    final state = currentTabState;
    if (!state.isLoading && state.hasMore) {
      await _getData(_activeTab, page: state.page + 1);
    }
  }
  // ─── Pull-to-refresh ────────────────────────────────────────────────────
  /// RN: `refreshList()`.
  Future<void> refresh() async {
    _refreshing = true;
    notifyListeners();
    await _getData(_activeTab, page: 1);
  }

  // ─── Tab switch ─────────────────────────────────────────────────────────
  /// RN: `handleTabSwitch(tab)`.
  Future<void> switchTab(InterestedTab tab) async {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
    if (_tabs[tab]!.items.isEmpty) {
      await _getData(tab, page: 1);
    }
  }

  // ─── Bottom sheet selection ─────────────────────────────────────────────
  void selectItem(InterestedUserModel item) {
    _selectedItem = item;
    _showBottomSheet = true;
    notifyListeners();
  }

  void closeBottomSheet() {
    _showBottomSheet = false;
    notifyListeners();
  }
  // ─── Helpers ────────────────────────────────────────────────────────────
  /// RN: `removeFromList(id)`.
  void _removeFromCurrentList(int id) {
    _updateTab(_activeTab, (s) => s.copyWith(
      items: s.items.where((u) => u.id != id).toList(),
    ));
    notifyListeners();
  }
  void _restoreToCurrentList(InterestedUserModel item) {
    _updateTab(_activeTab, (s) => s.copyWith(items: [...s.items, item]));
    notifyListeners();
  }

  // ─── Actions ────────────────────────────────────────────────────────────
  /// RN: `blockedUser()`.
  Future<void> blockSelectedUser() async {
    final item = _selectedItem;
    if (item == null) return;
    _blockUserLoading = true;
    notifyListeners();
    try {
      await _repository.blockUser(item.id);
      _blockUserLoading = false;
      _showBottomSheet = false;
      _removeFromCurrentList(item.id);
    } on InterestedApiException catch (e) {
      _errorMessage = e.message;
      _blockUserLoading = false;
      notifyListeners();
    }
  }

  /// RN: `onUnfavoritePress()` - "Remove from Interested" on the
  /// "Your Interested" tab.
  Future<void> removeFromYourInterested() async {
    final item = _selectedItem;
    if (item == null) return;
    _removeLoading = true;
    notifyListeners();
    try {
      await _repository.removeFromYourInterested(item.id);
      _removeLoading = false;
      _showBottomSheet = false;
      _removeFromCurrentList(item.id);
    } on InterestedApiException catch (e) {
      _errorMessage = e.message;
      _removeLoading = false;
      _restoreToCurrentList(item);
    }
  }

  /// "Interested You" tab.
  Future<void> removeFromInterestedYou() async {
    final item = _selectedItem;
    if (item == null) return;
    _removeLoading = true;
    notifyListeners();
    try {
      await _repository.removeFromInterestedYou(item.id);
      _removeLoading = false;
      _showBottomSheet = false;
      _removeFromCurrentList(item.id);
    } on InterestedApiException catch (e) {
      _errorMessage = e.message;
      _removeLoading = false;
      _restoreToCurrentList(item);
    }
  }

  /// Dispatches to the correct remove action based on the active tab -
  /// RN: `onPress={activeTab === 'interestedYou' ? onUnfavoriteMePress : onUnfavoritePress}`.
  Future<void> removeSelected() {
    return _activeTab == InterestedTab.interestedYou
        ? removeFromInterestedYou()
        : removeFromYourInterested();
  }

  // ─── Presentation utils ─────────────────────────────────────────────────
  /// RN: `getImageUrl(image)`.
  String? resolveImageUrl(String? image) {
    if (image == null || image.isEmpty || image == 'null') return null;
    final clean = image.trim();
    if (RegExp(r'/uploads/?$').hasMatch(clean)) return null;
    if (clean.startsWith('http')) return clean;
    return '${AppConstants.uploadImagesUrl}$clean';
  }

  /// RN: `getInitials(name)`.
  String initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// RN: `capitalizeFirstLetter(text)`.
  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class InterestedTabState {
  List<InterestedUserModel> items;
  int page;
  bool hasMore;
  bool isLoading;

  InterestedTabState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
  });

  InterestedTabState copyWith({
    List<InterestedUserModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
  }) {
    return InterestedTabState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
/// Mirrors the RN `activeTab` values: `'interestedYou' | 'yourInterested'`.
enum InterestedTab { interestedYou, yourInterested }

extension InterestedTabLabel on InterestedTab {
  String get label => switch (this) {
    InterestedTab.interestedYou => 'Interested You',
    InterestedTab.yourInterested => 'Your Interested',
  };

  String get emptyMessage => switch (this) {
    InterestedTab.interestedYou => 'No one has shown interest in you yet.',
    InterestedTab.yourInterested => "You haven't shown interest in anyone yet.",
  };
}