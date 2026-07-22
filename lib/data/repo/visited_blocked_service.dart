import '../end_points.dart';
import '../services/Api_Helper/api_manager.dart'; // merge ApiEndpoints from end_points_blocked_visited.dart here

/// Handles all API calls for the Blocked Users and Visited Users screens.
/// Thin wrapper around the existing [ApiManager] (Dio based) — no extra logic.
class UserRelationsService {
  final ApiManager _api = ApiManager();

  // ---------------- Blocked users ----------------

  Future<Map<String, dynamic>> getBlockedList(int page, int perPage) {
    return _api.fetch(
      Api(
        url: "${ApiEndpoints.getBlockedList}?page=$page&per_page=$perPage",
        method: "GET",
      ),
      null,
    );
  }

  Future<Map<String, dynamic>> blockUser(int profileUserId) {
    return _api.fetch(
      Api(url: ApiEndpoints.userBlock, method: "POST"),
      {"profile_user_id": profileUserId.toString()},
    );
  }

  Future<Map<String, dynamic>> unblockUser(int profileUserId) {
    return _api.fetch(
      Api(url: ApiEndpoints.userUnblock, method: "POST"),
      {"profile_user_id": profileUserId.toString()},
    );
  }

  // ---------------- Visited users ----------------

  Future<Map<String, dynamic>> getVisitedList(int page, int perPage) {
    return _api.fetch(
      Api(
        url: "${ApiEndpoints.visitedListing}?page=$page&per_page=$perPage",
        method: "GET",
      ),
      null,
    );
  }

  Future<Map<String, dynamic>> removeVisited(int visitedUserId) {
    return _api.fetch(
      Api(url: ApiEndpoints.visitedRemove, method: "POST"),
      {"visited_user_id": visitedUserId},
    );
  }
}