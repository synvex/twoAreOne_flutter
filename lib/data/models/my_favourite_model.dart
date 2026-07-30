
class MyFavouriteUserModel {
  final int id;
  final String fullName;
  final String? profilePicture;

  const MyFavouriteUserModel({
    required this.id,
    required this.fullName,
    this.profilePicture,
  });

  factory MyFavouriteUserModel.fromJson(Map<String, dynamic> json) {
    // Different endpoints key the id differently (id / user_id /
    // profile_user_id / viewer_id) — check all known variants, same
    // defensive approach as InterestedUserModel.
    final rawId = json['id'] ?? json['user_id'] ?? json['profile_user_id'] ?? json['viewer_id'];

    return MyFavouriteUserModel(
      id: int.tryParse(rawId?.toString() ?? '') ?? 0,
      fullName: (json['full_name'] ?? json['fullName'] ?? '').toString().trim(),
      profilePicture: (json['profile_picture'] ?? json['profilePicture'])?.toString(),
    );
  }

  static List<MyFavouriteUserModel> listFromJson(List<dynamic> data) => data
      .whereType<Map>()
      .map((e) => MyFavouriteUserModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}




// class MyFavouriteModel {
//   List<UserData>? data;
//
//   MyFavouriteModel({this.data});
//
//   MyFavouriteModel.fromJson(Map<String, dynamic> json) {
//     if (json['data'] != null) {
//       data = <UserData>[];
//       json['data'].forEach((v) {
//         data!.add(UserData.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> dataMap = {};
//     if (data != null) {
//       dataMap['data'] = data!.map((v) => v.toJson()).toList();
//     }
//     return dataMap;
//   }
// }
//
// class UserData {
//   String? id;
//   String? fbId;
//   String? role;
//   String? affiliateUserid;
//   String? fullName;
//   String? email;
//   String? password;
//   String? country;
//   String? state;
//   String? city;
//   String? latitude;
//   String? longitude;
//   String? credits;
//   String? birthday;
//   String? age;
//   String? bio;
//   String? gender;
//   String? sexuality;
//   String? profilePicture;
//   String? coverPhoto;
//   String? video;
//   String? isVerifyVideo;
//   String? ip;
//   String? registered;
//   String? lastLogin;
//   String? lastActive;
//   String? currentActive;
//
//   UserData({
//     this.id,
//     this.fbId,
//     this.role,
//     this.affiliateUserid,
//     this.fullName,
//     this.email,
//     this.password,
//     this.country,
//     this.state,
//     this.city,
//     this.latitude,
//     this.longitude,
//     this.credits,
//     this.birthday,
//     this.age,
//     this.bio,
//     this.gender,
//     this.sexuality,
//     this.profilePicture,
//     this.coverPhoto,
//     this.video,
//     this.isVerifyVideo,
//     this.ip,
//     this.registered,
//     this.lastLogin,
//     this.lastActive,
//     this.currentActive,
//   });
//
//   UserData.fromJson(Map<String, dynamic> json) {
//     id = json['id']?.toString();
//     fbId = json['fb_id']?.toString();
//     role = json['role']?.toString();
//     affiliateUserid = json['affiliate_userid']?.toString();
//     fullName = json['full_name']?.toString();
//     email = json['email']?.toString();
//     password = json['password']?.toString();
//     country = json['country']?.toString();
//     state = json['state']?.toString();
//     city = json['city']?.toString();
//     latitude = json['latitude']?.toString();
//     longitude = json['longitude']?.toString();
//     credits = json['credits']?.toString();
//     birthday = json['birthday']?.toString();
//     age = json['age']?.toString();
//     bio = json['bio']?.toString();
//     gender = json['gender']?.toString();
//     sexuality = json['sexuality']?.toString();
//     profilePicture = json['profile_picture']?.toString();
//     coverPhoto = json['cover_photo']?.toString();
//     video = json['video']?.toString();
//     isVerifyVideo = json['is_verify_video']?.toString();
//     ip = json['ip']?.toString();
//     registered = json['registered']?.toString();
//     lastLogin = json['last_login']?.toString();
//     lastActive = json['last_active']?.toString();
//     currentActive = json['current_active']?.toString();
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'fb_id': fbId,
//       'role': role,
//       'affiliate_userid': affiliateUserid,
//       'full_name': fullName,
//       'email': email,
//       'password': password,
//       'country': country,
//       'state': state,
//       'city': city,
//       'latitude': latitude,
//       'longitude': longitude,
//       'credits': credits,
//       'birthday': birthday,
//       'age': age,
//       'bio': bio,
//       'gender': gender,
//       'sexuality': sexuality,
//       'profile_picture': profilePicture,
//       'cover_photo': coverPhoto,
//       'video': video,
//       'is_verify_video': isVerifyVideo,
//       'ip': ip,
//       'registered': registered,
//       'last_login': lastLogin,
//       'last_active': lastActive,
//       'current_active': currentActive,
//     };
//   }
// }