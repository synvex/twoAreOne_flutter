//
//
// class ApiEndpoint {
//   final String method; // 'get' | 'post'
//   final String path;
//
//   const ApiEndpoint(this.method, this.path);
// }
//
// class UserApi {
//   UserApi._();
//
//   static const getUserInfo = ApiEndpoint('get', 'user/user-info.php');
//   static const uploadProfilePicture = ApiEndpoint('post', 'user/update-profile-photo.php');
//   static const addUserPhoto = ApiEndpoint('post', 'user/user-update-photos.php');
//   static const removeUserPhoto = ApiEndpoint('post', 'user/remove-photo.php');
//   static const addUserVideo = ApiEndpoint('post', 'user/user-update-video.php');
//   static const removeUserVideo = ApiEndpoint('post', 'user/remove-video.php');
//   static const updateUserProfile = ApiEndpoint('post', 'user/update-profile-user.php');
//   static const deleteUser = ApiEndpoint('post', 'user/delete-account.php');
// }
//
// class AuthApi {
//   AuthApi._();
//
//   static const logout = ApiEndpoint('post', 'auth/logout.php');
// }