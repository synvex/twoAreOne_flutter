import '../models/favourite_model.dart';
import 'Api_Helper/api_manager.dart';

// class FavouriteServices {
//   final ApiManager _api = ApiManager();
//
//   Future<List<FavouriteUserModel>> fetchFavouriteYou() async {
//     final res = await _api.fetch(
//       Api(url: 'user/favourites/you-int.php', method: 'GET'),
//       <String, dynamic>{},
//     );
//     final list = res['data'];
//     if (list is List) {
//       return FavouriteUserModel.listFromJson(list);
//     }
//     return const [];
//   }
//
//   Future<List<FavouriteUserModel>> fetchYourFavourite({
//     required int page,
//     required int perPage,
//   }) async {
//     final res = await _api.fetch(
//       Api(url: 'user/users-favourites.php?page=$page&per_page=$perPage', method: 'GET'),
//       <String, dynamic>{},
//     );
//     final list = res['data'];
//     if (list is List) {
//       return FavouriteUserModel.listFromJson(list);
//     }
//     return const [];
//   }
//
//   Future<void> removeFromFavouriteYou(int viewerId) => _api.fetch(
//     Api(url: 'user/favourites/you-remove.php?viewer_id=$viewerId', method: 'GET'),
//     <String, dynamic>{},
//   );
//
//   Future<void> removeFromYourFavourite(int profileUserId) => _api.fetch(
//     Api(url: 'user/user-unfavourite.php', method: 'POST'),
//     <String, dynamic>{'profile_user_id': profileUserId},
//   );
//
//   Future<void> blockUser(int profileUserId) => _api.fetch(
//     Api(url: 'user/user-add-block-profile.php', method: 'POST'),
//     <String, dynamic>{'profile_user_id': profileUserId},
//   );
// }
// import 'Api_Helper/api_manager.dart';
// import '../models/favourite_model.dart';

class FavouriteServices {
  final ApiManager _api = ApiManager();

  // "Favourite You" tab
  Future<List<FavouriteUserModel>> fetchFavouriteYou() async {
    final res = await _api.fetch(
      Api(url: 'user/favourites/you-int.php', method: 'GET'),
      {},
    );
    return FavouriteUserModel.listFromJson(res['data'] ?? []);
  }

  // "Your Favourite" tab (with pagination)
  Future<List<FavouriteUserModel>> fetchYourFavourite({
    required int page,
    required int perPage,
  }) async {
    final res = await _api.fetch(
      Api(url: 'user/users-favourites.php?page=$page&per_page=$perPage', method: 'GET'),
      {},
    );
    return FavouriteUserModel.listFromJson(res['data'] ?? []);
  }

  Future<void> removeFromFavouriteYou(int viewerId) => _api.fetch(
    Api(url: 'user/favourites/you-remove.php?viewer_id=$viewerId', method: 'GET'),
    {},
  );

  Future<void> removeFromYourFavourite(int profileUserId) => _api.fetch(
    Api(url: 'user/user-unfavourite.php', method: 'POST'),
    {'profile_user_id': profileUserId},
  );

  Future<void> blockUser(int profileUserId) => _api.fetch(
    Api(url: 'user/user-add-block-profile.php', method: 'POST'),
    {'profile_user_id': profileUserId},
  );
}