import 'end_points.dart';

const _json = {'Content-Type': 'application/json'};
const _jsonNoCache = {
  'Content-Type': 'application/json',
  'Cache-Control': 'no-cache',
  'Pragma': 'no-cache',
};
const _multipart = {'Content-Type': 'multipart/form-data'};

class ApiEndpoints {
  ApiEndpoints._();

  // ---------------- SignUpService.js ----------------
  static const signUp = ApiEndpoint(method: 'POST', url: 'auth/register.php', headers: _json);
  static const verifyOtp = ApiEndpoint(method: 'POST', url: 'auth/verify-otp.php', headers: _json);
  static const verifyPhone = ApiEndpoint(method: 'POST', url: 'auth/verify-phone-no.php', headers: _json);
  static const forgotPassword = ApiEndpoint(method: 'POST', url: 'auth/forgotpassword.php', headers: _json);
  static const resetPassword = ApiEndpoint(method: 'POST', url: 'auth/reset-password.php', headers: _json);
  static const signIn = ApiEndpoint(method: 'POST', url: 'auth/login.php', headers: {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache',
  });
  static const resendOtp = ApiEndpoint(method: 'POST', url: 'auth/resend-otp.php', headers: _multipart);
  static const logout = ApiEndpoint(method: 'POST', url: 'auth/logout.php', headers: _json);

  // ---------------- User.js ----------------
  static const introduce = ApiEndpoint(method: 'POST', url: 'user/update-user-profile.php', headers: _json);
  static const uploadUserProfile = ApiEndpoint(method: 'POST', url: 'user/upload-user-info.php', headers: _multipart);
  static const getUserInfo = ApiEndpoint(method: 'get', url: 'user/user-info.php', headers: _jsonNoCache);
  static const uploadUserProfilePicture =
      ApiEndpoint(method: 'POST', url: 'user/update-profile-photo.php', headers: _multipart);
  static ApiEndpoint getUserInfoById() => const ApiEndpoint(method: 'get', url: 'user/detail.php', headers: _json);
  static ApiEndpoint getVisitedList(int page, int perPage) => ApiEndpoint(
      method: 'get', url: '/user/visited/listing.php?page=$page&per_page=$perPage', headers: _json);
  static const removeVisited = ApiEndpoint(method: 'POST', url: '/user/visited/remove.php', headers: _json);
  static const addUserVisited = ApiEndpoint(method: 'POST', url: '/user/visited/add.php', headers: _json);
  static const getPlanList = ApiEndpoint(method: 'get', url: '/user/plan-list.php', headers: _json);
  static const changeUserPassword = ApiEndpoint(method: 'POST', url: 'user/change-password.php', headers: _json);
  static const updateUserProfile = ApiEndpoint(method: 'POST', url: 'user/update-profile-user.php', headers: _json);
  static const updateUserPhone = ApiEndpoint(method: 'POST', url: 'user/update-phone-no.php', headers: _json);
  static const updateUserEmailOtpSent =
      ApiEndpoint(method: 'POST', url: 'user/update-email-otp-send.php', headers: _json);
  static const updateEmailResendOtp =
      ApiEndpoint(method: 'POST', url: 'user/resend-email-otp.php', headers: _json);
  static const currentEmailVerifyOtp = ApiEndpoint(method: 'POST', url: 'user/otp-verify-email.php', headers: _json);
  static const updateEmailVerifyOtp = ApiEndpoint(method: 'POST', url: 'user/update-email.php', headers: _json);
  static const updateUserPhoto = ApiEndpoint(method: 'POST', url: 'user/user-update-photos.php', headers: _multipart);
  static const removeUserPhoto = ApiEndpoint(method: 'POST', url: 'user/remove-photo.php', headers: _json);
  static const removeUserVideo = ApiEndpoint(method: 'POST', url: 'user/remove-video.php', headers: _json);
  static const updateUserVideo = ApiEndpoint(method: 'POST', url: 'user/user-update-video.php', headers: _multipart);
  static const deleteUser = ApiEndpoint(method: 'POST', url: 'user/delete-account.php', headers: _json);

  // ---------------- Home.js ----------------
  static ApiEndpoint getMatchProfile(int page) => ApiEndpoint(
      method: 'POST', url: 'user/user-profile-match.php?page=$page&per_page=20', headers: {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-store',
    'Pragma': 'no-cache',
    'Expires': '0',
  });
  static const userFavorite = ApiEndpoint(method: 'POST', url: 'user/user-add-favourite.php', headers: _json);
  static const userInterested = ApiEndpoint(method: 'POST', url: '/user/user-add-interest.php', headers: _json);
  static const userUnInterested = ApiEndpoint(method: 'POST', url: '/user/user-uninterest.php', headers: _json);
  static const getNotification = ApiEndpoint(method: 'get', url: '/user/all-notifications.php', headers: _json);
  static const unFavouriteUser = ApiEndpoint(method: 'POST', url: 'user/user-unfavourite.php', headers: _json);

  // ---------------- Favorite.js ----------------
  static ApiEndpoint getFavoriteList(int page, int perPage) => ApiEndpoint(
      method: 'get', url: 'user/user-favourites.php?page=$page&per_page=$perPage', headers: _jsonNoCache);
  static ApiEndpoint getYouFavoriteList(int page, int perPage) => ApiEndpoint(
      method: 'get', url: 'user/favourites/you-fav.php?page=$page&per_page=$perPage', headers: _jsonNoCache);
  static const blockUser = ApiEndpoint(method: 'POST', url: '/user/user-add-block-profile.php', headers: _jsonNoCache);
  static ApiEndpoint unFavouriteMeUser(String id) =>
      ApiEndpoint(method: 'get', url: 'user/favourites/you-remove.php?viewer_id=$id', headers: _json);
  static ApiEndpoint getBlockedUsers(int page, int perPage) => ApiEndpoint(
      method: 'get', url: '/user/user-block-list.php?page=$page&per_page=$perPage', headers: _jsonNoCache);
  static const unblockUser = ApiEndpoint(method: 'POST', url: '/user/user-unblock-profile.php', headers: _json);

  // ---------------- Chat.js ----------------
  static const userChatList = ApiEndpoint(method: 'get', url: 'user/messages/chat-members.php', headers: _jsonNoCache);
  static ApiEndpoint userOneToOneChat(String receiverId) => ApiEndpoint(
      method: 'get',
      url: 'user/messages/one-to-one-chat-histories.php?receiver_id=$receiverId',
      headers: _jsonNoCache);
  static const sendMessage = ApiEndpoint(method: 'POST', url: 'user/messages/send.php', headers: _json);
  static const updateReadCount = ApiEndpoint(method: 'POST', url: 'user/messages/mark_messages_read.php', headers: _json);

  // ---------------- QuestionService.js ----------------
  static ApiEndpoint getQuestions(int page) =>
      ApiEndpoint(method: 'get', url: 'questions/listing.php?page=$page', headers: _json);
  static const saveQuestion =
      ApiEndpoint(method: 'POST', url: 'questions/save-user-question-answer.php', headers: _json);
  static const updateQuestion =
      ApiEndpoint(method: 'POST', url: '/questions/update-user-question-answer.php', headers: _json);
  static ApiEndpoint getUserQuestionByCategory({required String category, required String userId}) => ApiEndpoint(
      method: 'get',
      url: '/questions/get-user-questions-by-category.php?category_id=$category&user_id=$userId',
      headers: _jsonNoCache);
  static ApiEndpoint getUserQuestionAnswerById(String id) => ApiEndpoint(
      method: 'get', url: '/questions/get-question-answers.php?question_id=$id', headers: _json);

  // ---------------- Interested.js ----------------
  static ApiEndpoint getInterestedList(int page, int perPage) => ApiEndpoint(
      method: 'get', url: '/user/users-interest.php?page=$page&per_page=$perPage', headers: _jsonNoCache);
  static const getYouInterestedList =
      ApiEndpoint(method: 'get', url: '/user/interested/you-int.php', headers: _jsonNoCache);
  static ApiEndpoint unInterestedMeUser(String id) =>
      ApiEndpoint(method: 'get', url: '/user/interested/you-remove.php?viewer_id=$id', headers: _json);

  // ---------------- ProfileSetting.js ----------------
  static const privacyPolicy =
      ApiEndpoint(method: 'get', url: 'privacy-policy-tc.php?page_slug=privacy-policy', headers: _json);
  static const termsCondition =
      ApiEndpoint(method: 'get', url: 'privacy-policy-tc.php?page_slug=terms-and-conditions', headers: _json);
}
