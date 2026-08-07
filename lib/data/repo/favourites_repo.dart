import '../exceptions/api_exceptions.dart';
import '../models/favourite_model.dart';
import '../services/Api_Helper/api_manager.dart';

class FavouriteServices {
  final ApiManager _apiManager = ApiManager();
  Future<List<FavouriteUserModel>> fetchFavouritedYou({
    required int page,
    required int perPage,
  })
  async {
    final result = await _apiManager.fetch(
      Api(url: 'user/favourites/you-fav.php', method: 'GET'),
      {'page': page, 'per_page': perPage},
    );
    return _parseList(result);
  }

  Future<List<FavouriteUserModel>> fetchYourFavourites({
    required int page,
    required int perPage,
  }) async {
    final result = await _apiManager.fetch(
      Api(url: 'user/user-favourites.php', method: 'GET'),
      {'page': page, 'per_page': perPage},
    );
    return _parseList(result);
  }

  Future<void> removeFavouritedYou(int viewerId) async {
    final result = await _apiManager.fetch(
      Api(url: 'user/favourites/you-remove.php', method: 'GET'),
      {'viewer_id': viewerId},
    );
    _checkOk(result, 'Failed to remove');
  }

  /// Removes someone from "Your Favourites". POST user/user-unfavourite.php
  Future<void> removeFromYourFavourites(int profileUserId) async {
    final result = await _apiManager.fetch(
      Api(url: 'user/user-unfavourite.php', method: 'POST'),
      {'profile_user_id': profileUserId},
    );
    _checkOk(result, 'Failed to unfavourite');
  }

  Future<void> addFavourite(int profileUserId) async {
    final result = await _apiManager.fetch(
      Api(url: 'user/user-add-favourite.php', method: 'POST'),
      {'profile_user_id': profileUserId},
    );
    _checkOk(result, 'Failed to add favourite');
  }

  /// Blocks a user. POST user/user-block.php
  /// NOTE: verify this endpoint matches whatever InterestedServices.blockUser
  /// uses in your project — it wasn't included in the files you shared, so
  /// this mirrors the naming convention of the other endpoints above.
  Future<void> blockUser(int profileUserId) async {
    final result = await _apiManager.fetch(
      Api(url: 'user/user-add-block-profile.php', method: 'POST'),
      {'profile_user_id': profileUserId},
    );
    _checkOk(result, 'Failed to block user');
  }

  // ─── helpers ────────────────────────────────────────────────────────────
  List<FavouriteUserModel> _parseList(Map<String, dynamic> result) {
    if (result['success'] != true) {
      throw FavouriteApiException(_message(result) ?? "Something went wrong");
    }
    final data = result['data'];
    if (data is! List) return [];
    return FavouriteUserModel.listFromJson(data);
  }

  void _checkOk(Map<String, dynamic> result, String fallback) {
    if (result['success'] != true) {
      throw FavouriteApiException(_message(result) ?? fallback);
    }
  }

  String? _message(Map<String, dynamic> result) {
    final msg = result['error'] ?? result['message'];
    final text = msg?.toString();
    return (text == null || text.isEmpty) ? null : text;
  }
}
