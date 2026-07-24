import 'package:flutter/material.dart';
import 'package:two_are_one/data/models/visited_blocked_model.dart';
import '../repo/visited_blocked_service.dart';
import 'package:flutter/foundation.dart';

class VisitedUserViewModel extends ChangeNotifier {
  final UserRelationsService _service = UserRelationsService();

  final int perPage = 10;

  List<VisitedBlockedUserModel> users = [];
  int _page = 1;
  bool isLoading = false;
  bool isRefreshing = false;
  bool hasMore = true;
  String? error;
  bool _isDisposed = false;
  int? actionLoadingId;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      _page = 1;
      hasMore = true;
      isRefreshing = true;
    } else {
      isLoading = true;
    }

    error = null;
    notifyListeners();

    try {
      final res = await _service.getVisitedList(_page, perPage);
      debugPrint("visited/listing.php response: $res");

      if (res['success'] == true) {
        final list = _extractList(res['data']);

        final fetched = <VisitedBlockedUserModel>[];
        for (final item in list) {
          try {
            fetched.add(
              VisitedBlockedUserModel.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            debugPrint("Skipping malformed visited user: $e");
          }
        }

        if (refresh) {
          users = fetched;
        } else {
          for (final newUser in fetched) {
            if (!users.any((u) => u.profileId == newUser.profileId)) {
              users.add(newUser);
            }
          }
        }

        hasMore = fetched.length == perPage;
        _page += 1;
      } else {
        error = res['error']?.toString() ?? "Failed to load visited users";
      }
    } catch (e)
    {
      debugPrint("fetchUsers Error: $e");
      error = "Connection error. Please try again.";
    }

    isLoading = false;
    isRefreshing = false;
    notifyListeners();
  }

  /// Handles every response shape the backend has been seen to return for
  /// this endpoint: a plain list, `{data: [...]}` or the paginated
  /// `{data: {data: [...], pagination: {...}}}` form.
  List<dynamic> _extractList(dynamic rawData) {
    if (rawData is List) return rawData;
    if (rawData is Map) {
      if (rawData['data'] is List) return List.from(rawData['data']);
      if (rawData['data'] is Map && rawData['data']['data'] is List) {
        return List.from(rawData['data']['data']);
      }
    }
    return const [];
  }

  Future<bool> blockUser(VisitedBlockedUserModel user) async {
    actionLoadingId = user.profileId;
    notifyListeners();

    try {
      final res = await _service.blockUser(user.profileId);
      if (res['success'] == true) {
        users.removeWhere((u) => u.profileId == user.profileId);
        actionLoadingId = null;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    actionLoadingId = null;
    notifyListeners();
    return false;
  }

  Future<bool> removeVisited(VisitedBlockedUserModel user) async {
    actionLoadingId = user.profileId;
    notifyListeners();

    try {
      final res = await _service.removeVisited(user.profileId);
      if (res['success'] == true) {
        users.removeWhere((u) => u.profileId == user.profileId);
        actionLoadingId = null;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    actionLoadingId = null;
    notifyListeners();
    return false;
  }
}
// class VisitedUserViewModel extends ChangeNotifier {
//   final UserRelationsService _service = UserRelationsService();
//
//   final int perPage = 10;
//
//   List<VisitedBlockedUserModel> users = [];
//   int _page = 1;
//   bool isLoading = false;
//   bool isRefreshing = false;
//   bool hasMore = true;
//   String? error;
//   bool _isDisposed = false;
//   int? actionLoadingId;
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     super.dispose();
//   }
//
//   @override
//   void notifyListeners() {
//     if (!_isDisposed) {
//       super.notifyListeners();
//     }
//   }
//
//   Future<void> fetchUsers({bool refresh = false}) async {
//     if (isLoading) return;
//
//     if (refresh) {
//       _page = 1;
//       hasMore = true;
//       isRefreshing = true;
//     } else {
//       isLoading = true;
//     }
//
//     error = null;
//     notifyListeners();
//
//     try {
//       final res = await _service.getVisitedList(_page, perPage);
//       debugPrint("visited/listing.php response: $res");
//       debugPrint("res['data'] runtimeType: ${res['data'].runtimeType}");
//       debugPrint("res['success'] value: ${res['success']}");
//
//       if (res['success'] == true) {
//         final rawData = res['data'];
//         List<dynamic> list = [];
//
//         // Robust check for different API response shapes
//         if (rawData is List) {
//           list = rawData;
//         } else if (rawData is Map) {
//           if (rawData['data'] is List) {
//             list = List.from(rawData['data']);
//           } else if (rawData['data'] is Map && rawData['data']['data'] is List) {
//             list = List.from(rawData['data']['data']);
//           }
//         }
//
//         final fetched = <VisitedBlockedUserModel>[];
//         for (final item in list) {
//           try {
//             fetched.add(VisitedBlockedUserModel.fromJson(Map<String, dynamic>.from(item)));
//           } catch (e) {
//             debugPrint("Skipping malformed visited user: $e");
//           }
//         }
//
//         if (refresh) {
//           users = fetched;
//         } else {
//           // Add unique users only
//           for (var newUser in fetched) {
//             if (!users.any((u) => u.profileId == newUser.profileId)) {
//               users.add(newUser);
//             }
//           }
//         }
//
//         // If we fetched less than requested, we reached the end
//         hasMore = fetched.length >= perPage;
//         _page += 1;
//       } else {
//         error = res['error']?.toString() ?? "Failed to load visited users";
//       }
//     } catch (e) {
//       debugPrint("fetchUsers Error: $e");
//       error = "Connection error. Please try again.";
//     }
//
//     isLoading = false;
//     isRefreshing = false;
//     notifyListeners();
//   }
//
//   Future<bool> blockUser(VisitedBlockedUserModel user) async {
//     actionLoadingId = user.profileId;
//     notifyListeners();
//
//     try {
//       final res = await _service.blockUser(user.profileId);
//       actionLoadingId = null;
//       if (res['success'] == true) {
//         users.removeWhere((u) => u.profileId == user.profileId);
//         notifyListeners();
//         return true;
//       }
//     } catch (_) {
//       actionLoadingId = null;
//     }
//     notifyListeners();
//     return false;
//   }
//
//   Future<bool> removeVisited(VisitedBlockedUserModel user) async {
//     actionLoadingId = user.profileId;
//     notifyListeners();
//
//     try {
//       final res = await _service.removeVisited(user.profileId);
//       actionLoadingId = null;
//       if (res['success'] == true) {
//         users.removeWhere((u) => u.profileId == user.profileId);
//         notifyListeners();
//         return true;
//       }
//     } catch (_) {
//       actionLoadingId = null;
//     }
//     notifyListeners();
//     return false;
//   }
// }

