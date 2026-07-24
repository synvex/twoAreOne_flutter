import '../core/network/interested_api_request.dart';

enum ApiMethod { get, post, put, delete, patch }
class ApiRequest {
  final ApiMethod method;
  final String url;
  final Map<String, String>? headers;

  const ApiRequest({
    required this.method,
    required this.url,
    this.headers,
  });
}

class ApiEndpoints {
  ApiEndpoints._();
  //Blocked users
  static const String getBlockedList = "user/user-block-list.php";
  static const String userBlock = "user/user-add-block-profile.php";
  static const String userUnblock = "user/user-unblock-profile.php";

  // Visited users
  static const String visitedListing = "user/visited/listing.php";
  static const String visitedRemove = "user/visited/remove.php";
  static const String visitedAdd = "user/visited/add.php";

  static const ApiRequest privacyPolicy = ApiRequest(
    method: ApiMethod.get,
    url: 'privacy-policy-tc.php?page_slug=privacy-policy',
  );
  static const ApiRequest termsAndConditions = ApiRequest(
    method: ApiMethod.get,
    url: 'privacy-policy-tc.php?page_slug=terms-and-conditions',
  );
}
class InterestedEndpoints {
  InterestedEndpoints._();

  static InterestedApiRequest getInterestedList(int page, int perPage) => InterestedApiRequest(
    method: 'GET',
    path: '/user/users-interest.php?page=$page&per_page=$perPage',
    headers: const {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    },
  );

  static InterestedApiRequest getYouInterestedList() => const InterestedApiRequest(
    method: 'GET',
    path: '/user/interested/you-int.php',
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    },
  );

  /// RN: unInterestedMeUserService(id)
  /// GET /user/interested/you-remove.php?viewer_id=
  static InterestedApiRequest unInterestedMeUser(int viewerId) => InterestedApiRequest(
    method: 'GET',
    path: '/user/interested/you-remove.php?viewer_id=$viewerId',
  );

  /// RN: UserUnInterestedService (Home.js)
  /// POST /user/user-uninterest.php  body: { profile_user_id }
  static InterestedApiRequest userUnInterested() => const InterestedApiRequest(
    method: 'POST',
    path: '/user/user-uninterest.php',
  );

  /// RN: BlockUserService (Favorite.js)
  /// POST /user/user-add-block-profile.php  body: { profile_user_id }
  static InterestedApiRequest blockUser() => const InterestedApiRequest(
    method: 'POST',
    path: '/user/user-add-block-profile.php',
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    },
  );
}

class ApiEndpoint {
  final String method; // 'get' | 'POST'
  final String url; // relative path, appended to ApiConstants.apiUrl
  final Map<String, String>? headers;

  const ApiEndpoint({required this.method, required this.url, this.headers});

  bool get isGet => method.toLowerCase() == 'get';
}