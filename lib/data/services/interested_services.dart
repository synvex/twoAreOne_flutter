import '../models/interested_model.dart';
import 'Api_Helper/api_manager.dart';

class InterestedServices {
  final ApiManager _api = ApiManager();

  Future<List<InterestedUserModel>> fetchInterestedYou() async {
    final res = await _api.fetch(
      Api(url: 'user/interested/you-int.php', method: 'GET'),
      <String, dynamic>{},
    );
    final list = res['data'];
    if (list is List) {
      return InterestedUserModel.listFromJson(list);
    }
    return const [];
  }

  Future<List<InterestedUserModel>> fetchYourInterested({
    required int page,
    required int perPage,
  }) async {
    final res = await _api.fetch(
      Api(url: 'user/users-interest.php?page=$page&per_page=$perPage', method: 'GET'),
      <String, dynamic>{},
    );
    final list = res['data'];
    if (list is List) {
      return InterestedUserModel.listFromJson(list);
    }
    return const [];
  }

  Future<void> removeFromInterestedYou(int viewerId) => _api.fetch(
    Api(url: 'user/interested/you-remove.php?viewer_id=$viewerId', method: 'GET'),
    <String, dynamic>{},
  );

  Future<void> removeFromYourInterested(int profileUserId) => _api.fetch(
    Api(url: 'user/user-uninterest.php', method: 'POST'),
    <String, dynamic>{'profile_user_id': profileUserId},
  );

  Future<void> blockUser(int profileUserId) => _api.fetch(
    Api(url: 'user/user-add-block-profile.php', method: 'POST'),
    <String, dynamic>{'profile_user_id': profileUserId},
  );
}
// class InterestedServices {
//   final ApiManager _api = ApiManager();
//   Future<List<InterestedUserModel>> fetchInterestedYou() async {
//     final res = await InterestedApiClient.request(
//       InterestedEndpoints.getYouInterestedList(),
//       const {},
//     );
//     return InterestedUserModel.listFromJson(
//       (res['data']?['data'] as List<dynamic>?) ?? const [],
//     );
//   }
//
//   /// RN: GetInterestedListService(page, per_page) - "Your Interested" tab.
//   Future<List<InterestedUserModel>> fetchYourInterested({
//     required int page,
//     required int perPage,
//   }) async {
//     final res = await InterestedApiClient.request(
//       InterestedEndpoints.getInterestedList(page, perPage),
//       const {},
//     );
//     return InterestedUserModel.listFromJson(
//       (res['data']?['data'] as List<dynamic>?) ?? const [],
//     );
//   }
//
//   /// RN: unInterestedMeUserService(id) - remove from "Interested You".
//   Future<void> removeFromInterestedYou(int viewerId) => InterestedApiClient.request(
//     InterestedEndpoints.unInterestedMeUser(viewerId),
//     const {},
//   );
//
//   /// RN: UserUnInterestedService - remove from "Your Interested".
//   Future<void> removeFromYourInterested(int profileUserId) => InterestedApiClient.request(
//     InterestedEndpoints.userUnInterested(),
//     {'profile_user_id': profileUserId},
//   );
//
//   /// RN: BlockUserService.
//   Future<void> blockUser(int profileUserId) => InterestedApiClient.request(
//     InterestedEndpoints.blockUser(),
//     {'profile_user_id': profileUserId},
//   );
// }