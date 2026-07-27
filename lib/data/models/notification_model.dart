class NotificationModel {
  final String id;
  final String profileId;
  final String viewerId;
  final String time;
  final String datetime;
  final String tableName;
  final String msgType;
  final int timeDiff;
  final String createdDate;
  final UserInfo userInfo;
  final String message;

  NotificationModel({
    required this.id,
    required this.profileId,
    required this.viewerId,
    required this.time,
    required this.datetime,
    required this.tableName,
    required this.msgType,
    required this.timeDiff,
    required this.createdDate,
    required this.userInfo,
    required this.message,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      viewerId: json['viewer_id']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      datetime: json['datetime'] ?? '',
      tableName: json['table_name'] ?? '',
      msgType: json['msg_type'] ?? '',
      timeDiff: json['time_diff'] ?? 0,
      createdDate: json['created_date'] ?? '',
      userInfo: UserInfo.fromJson(json['user_info'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'viewer_id': viewerId,
      'time': time,
      'datetime': datetime,
      'table_name': tableName,
      'msg_type': msgType,
      'time_diff': timeDiff,
      'created_date': createdDate,
      'user_info': userInfo.toJson(),
      'message': message,
    };
  }
}

class UserInfo {
  final String id;
  final String? fbId;
  final String role;
  final String affiliateUserid;
  final String fullName;
  final String email;
  final String password;
  final String country;
  final String state;
  final String city;
  final String latitude;
  final String longitude;
  final String credits;
  final String? birthday;
  final String age;
  final String bio;
  final String gender;
  final String sexuality;
  final String? profilePicture;
  final String? coverPhoto;
  final String? video;
  final String isVerifyVideo;
  final String? ip;
  final String registered;
  final String? lastLogin;
  final String? lastActive;
  final String? currentActive;
  final String isActualLogin;
  final String isMakeOnlines;
  final String isAdmin;
  final String isVerified;
  final String language;
  final String height;
  final String weight;
  final String? lastEncounter;
  final String? education;
  final String work;
  final String hereTo;
  final String languages;
  final String? relationship;
  final String? isFeatured;
  final String? isFeaturedExp;
  final String? riseUpEncounters;
  final String? riseUpEncountersExp;
  final String? riseUpPeople;
  final String? riseUpPeopleExp;
  final String? hasSuperpowers;
  final String? superpowersExpiration;
  final String? emailVerificationLink;
  final String? emailVerifiedAt;
  final String? interest;
  final String? isActive;
  final String? resetLinkToken;
  final String? expDate;
  final String phoneNo;
  final String? otp;
  final String? otpExpiration;
  final String? lastOtpRequest;
  final String screenType;
  final String apiToken;
  final String updatedAt;
  final String profileImgUrl;

  UserInfo({
    required this.id,
    this.fbId,
    required this.role,
    required this.affiliateUserid,
    required this.fullName,
    required this.email,
    required this.password,
    required this.country,
    required this.state,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.credits,
    this.birthday,
    required this.age,
    required this.bio,
    required this.gender,
    required this.sexuality,
    this.profilePicture,
    this.coverPhoto,
    this.video,
    required this.isVerifyVideo,
    this.ip,
    required this.registered,
    this.lastLogin,
    this.lastActive,
    this.currentActive,
    required this.isActualLogin,
    required this.isMakeOnlines,
    required this.isAdmin,
    required this.isVerified,
    required this.language,
    required this.height,
    required this.weight,
    this.lastEncounter,
    this.education,
    required this.work,
    required this.hereTo,
    required this.languages,
    this.relationship,
    this.isFeatured,
    this.isFeaturedExp,
    this.riseUpEncounters,
    this.riseUpEncountersExp,
    this.riseUpPeople,
    this.riseUpPeopleExp,
    this.hasSuperpowers,
    this.superpowersExpiration,
    this.emailVerificationLink,
    this.emailVerifiedAt,
    this.interest,
    this.isActive,
    this.resetLinkToken,
    this.expDate,
    required this.phoneNo,
    this.otp,
    this.otpExpiration,
    this.lastOtpRequest,
    required this.screenType,
    required this.apiToken,
    required this.updatedAt,
    required this.profileImgUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      fbId: json['fb_id']?.toString(),
      role: json['role'] ?? '',
      affiliateUserid: json['affiliate_userid']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      credits: json['credits']?.toString() ?? '',
      birthday: json['birthday']?.toString(),
      age: json['age']?.toString() ?? '',
      bio: json['bio'] ?? '',
      gender: json['gender'] ?? '',
      sexuality: json['sexuality'] ?? '',
      profilePicture: json['profile_picture']?.toString(),
      coverPhoto: json['cover_photo']?.toString(),
      video: json['video']?.toString(),
      isVerifyVideo: json['is_verify_video']?.toString() ?? '',
      ip: json['ip']?.toString(),
      registered: json['registered']?.toString() ?? '',
      lastLogin: json['last_login']?.toString(),
      lastActive: json['last_active']?.toString(),
      currentActive: json['current_active']?.toString(),
      isActualLogin: json['is_actual_login']?.toString() ?? '',
      isMakeOnlines: json['is_make_onlines']?.toString() ?? '',
      isAdmin: json['is_admin']?.toString() ?? '',
      isVerified: json['is_verified']?.toString() ?? '',
      language: json['language'] ?? '',
      height: json['height']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      lastEncounter: json['last_encounter']?.toString(),
      education: json['education']?.toString(),
      work: json['work'] ?? '',
      hereTo: json['here_to']?.toString() ?? '',
      languages: json['languages'] ?? '',
      relationship: json['relationship']?.toString(),
      isFeatured: json['is_featured']?.toString(),
      isFeaturedExp: json['is_featured_exp']?.toString(),
      riseUpEncounters: json['rise_up_encounters']?.toString(),
      riseUpEncountersExp: json['rise_up_encounters_exp']?.toString(),
      riseUpPeople: json['rise_up_people']?.toString(),
      riseUpPeopleExp: json['rise_up_people_exp']?.toString(),
      hasSuperpowers: json['has_superpowers']?.toString(),
      superpowersExpiration: json['superpowers_expiration']?.toString(),
      emailVerificationLink: json['email_verification_link']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      interest: json['interest']?.toString(),
      isActive: json['is_active']?.toString(),
      resetLinkToken: json['reset_link_token']?.toString(),
      expDate: json['exp_date']?.toString(),
      phoneNo: json['phone_no'] ?? '',
      otp: json['otp']?.toString(),
      otpExpiration: json['otp_expiration']?.toString(),
      lastOtpRequest: json['last_otp_request']?.toString(),
      screenType: json['screen_type']?.toString() ?? '',
      apiToken: json['api_token'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      profileImgUrl: json['profile_img_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fb_id': fbId,
      'role': role,
      'affiliate_userid': affiliateUserid,
      'full_name': fullName,
      'email': email,
      'password': password,
      'country': country,
      'state': state,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'credits': credits,
      'birthday': birthday,
      'age': age,
      'bio': bio,
      'gender': gender,
      'sexuality': sexuality,
      'profile_picture': profilePicture,
      'cover_photo': coverPhoto,
      'video': video,
      'is_verify_video': isVerifyVideo,
      'ip': ip,
      'registered': registered,
      'last_login': lastLogin,
      'last_active': lastActive,
      'current_active': currentActive,
      'is_actual_login': isActualLogin,
      'is_make_onlines': isMakeOnlines,
      'is_admin': isAdmin,
      'is_verified': isVerified,
      'language': language,
      'height': height,
      'weight': weight,
      'last_encounter': lastEncounter,
      'education': education,
      'work': work,
      'here_to': hereTo,
      'languages': languages,
      'relationship': relationship,
      'is_featured': isFeatured,
      'is_featured_exp': isFeaturedExp,
      'rise_up_encounters': riseUpEncounters,
      'rise_up_encounters_exp': riseUpEncountersExp,
      'rise_up_people': riseUpPeople,
      'rise_up_people_exp': riseUpPeopleExp,
      'has_superpowers': hasSuperpowers,
      'superpowers_expiration': superpowersExpiration,
      'email_verification_link': emailVerificationLink,
      'email_verified_at': emailVerifiedAt,
      'interest': interest,
      'is_active': isActive,
      'reset_link_token': resetLinkToken,
      'exp_date': expDate,
      'phone_no': phoneNo,
      'otp': otp,
      'otp_expiration': otpExpiration,
      'last_otp_request': lastOtpRequest,
      'screen_type': screenType,
      'api_token': apiToken,
      'updated_at': updatedAt,
      'profile_img_url': profileImgUrl,
    };
  }
}
