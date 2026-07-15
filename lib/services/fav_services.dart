import '../models/user_match_model.dart';
import 'Api_Helper/api_manager.dart';

class FavServices {
  final ApiManager _api = ApiManager();

  // ── GET /user/user-favourites.php ──────────────────────────────────────
  // "Your Favorites" — jinhe AAP ne favorite kiya hai
  Future<List<FilterMatchModel>> getFavouritedList({
    int page = 1,
    int perPage = 10,
  }) async {
    final res = await _api.fetch(
      Api(url: "user/user-favourites.php", method: "GET"),
      {
        "page": page,
        "per_page": perPage,
      },
    );

    if (res['success'] == true && res['data'] != null) {
      final List list = res['data'];
      return list.map((json) => FilterMatchModel.fromJson(json)).toList();
    }
    return [];
  }

  // ── GET /user/favourites/you-fav.php ───────────────────────────────────
  // "Favorited You" — jinhone AAPKO favorite kiya hai
  Future<List<FilterMatchModel>> getYouFavList({
    int page = 1,
    int perPage = 10,
  }) async {
    final res = await _api.fetch(
      Api(url: "user/favourites/you-fav.php", method: "GET"),
      {
        "page": page,
        "per_page": perPage,
      },
    );

    if (res['success'] == true && res['data'] != null) {
      final List list = res['data'];
      return list.map((json) => FilterMatchModel.fromJson(json)).toList();
    }
    return [];
  }

  // ── GET /user/favourites/you-remove.php?viewer_id= ─────────────────────
  // "Favorited You" list se kisi ko remove karna (query param: viewer_id)
  Future<bool> removeFromYouFavList({required String viewerId}) async {
    final res = await _api.fetch(
      Api(url: "user/favourites/you-remove.php", method: "GET"),
      {
        "viewer_id": viewerId,
      },
    );

    return res['success'] == true || res['error'] == false;
  }

  // ── POST /user/user-add-favourite.php ──────────────────────────────────
  // Kisi profile ko favorite list mein add karna
  Future<bool> addFavourite({required String profileUserId}) async {
    final res = await _api.fetch(
      Api(url: "user/user-add-favourite.php", method: "POST"),
      {
        "profile_user_id": profileUserId,
      },
    );

    return res['success'] == true || res['error'] == false;
  }

  // ── POST /user/user-unfavourite.php ────────────────────────────────────
  // "Your Favorites" list se kisi ko remove karna (body param: profile_user_id)
  Future<bool> removeFavourite({required String profileUserId}) async {
    final res = await _api.fetch(
      Api(url: "user/user-unfavourite.php", method: "POST"),
      {
        "profile_user_id": profileUserId,
      },
    );

    return res['success'] == true || res['error'] == false;
  }
}