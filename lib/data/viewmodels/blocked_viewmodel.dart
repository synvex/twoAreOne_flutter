import 'package:flutter/material.dart';
import 'package:two_are_one/data/models/visited_blocked_model.dart';
import '../repo/visited_blocked_service.dart';

class BlockedUserViewModel extends ChangeNotifier {
  final UserRelationsService _service = UserRelationsService();
  final int perPage = 10;

  List<VisitedBlockedUserModel> users = [];
  int _page = 1;
  bool isLoading = false; // initial / pagination load
  bool isRefreshing = false; // pull to refresh
  bool hasMore = true;
  String? error;

  /// profileId of the row currently running an action (unblock), used to
  /// show a small spinner on that specific bottom-sheet item.
  int? actionLoadingId;

  Future<void> fetchUsers({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      _page = 1;
      hasMore = true;
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    notifyListeners();

    final res = await _service.getBlockedList(_page, perPage);

    if (res['success'] == true) {
      final List raw = (res['data'] is List) ? res['data'] : [];
      final fetched = raw
          .map((e) => VisitedBlockedUserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      users = refresh ? fetched : [...users, ...fetched];
      hasMore = fetched.length == perPage;
      _page += 1;
    } else {
      error = res['error']?.toString();
    }

    isLoading = false;
    isRefreshing = false;
    notifyListeners();
  }

  Future<bool> unblockUser(VisitedBlockedUserModel user) async {
    actionLoadingId = user.profileId;
    notifyListeners();

    final res = await _service.unblockUser(user.profileId);

    actionLoadingId = null;
    if (res['success'] == true) {
      users.removeWhere((u) => u.profileId == user.profileId);
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }
}