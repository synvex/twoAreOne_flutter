import 'package:flutter/material.dart';
import 'package:two_are_one/data/models/visited_blocked_model.dart';

import '../repo/visited_blocked_service.dart';

class VisitedUserViewModel extends ChangeNotifier {
  final UserRelationsService _service = UserRelationsService();
  final int perPage = 10;

  List<VisitedBlockedUserModel> users = [];
  int _page = 1;
  bool isLoading = false;
  bool isRefreshing = false;
  bool hasMore = true;
  String? error;

  /// profileId of the row currently running an action (block / remove).
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

    final res = await _service.getVisitedList(_page, perPage);

    if (res['success'] == true) {
      final List raw = (res['data'] is List) ? res['data'] : [];
      final fetched = raw
          .map(
            (e) =>
                VisitedBlockedUserModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();

      // De-dupe by profileId, same as the RN screen does.
      final combined = refresh ? fetched : [...users, ...fetched];
      final uniqueMap = <int, VisitedBlockedUserModel>{};
      for (final u in combined) {
        uniqueMap[u.profileId] = u;
      }
      users = uniqueMap.values.toList();

      hasMore = fetched.length == perPage;
      _page += 1;
    } else {
      error = res['error']?.toString();
    }

    isLoading = false;
    isRefreshing = false;
    notifyListeners();
  }

  Future<bool> blockUser(VisitedBlockedUserModel user) async {
    actionLoadingId = user.profileId;
    notifyListeners();

    final res = await _service.blockUser(user.profileId);

    actionLoadingId = null;
    if (res['success'] == true) {
      users.removeWhere((u) => u.profileId == user.profileId);
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> removeVisited(VisitedBlockedUserModel user) async {
    actionLoadingId = user.profileId;
    notifyListeners();

    final res = await _service.removeVisited(user.profileId);

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
