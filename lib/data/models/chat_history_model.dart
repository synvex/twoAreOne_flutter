class ChatHistoryModel {
  final int id;
  final String? message;
  final int user1;
  final int user2;
  final int isSticker;
  final int isPhoto;
  final int stickerId;
  final int time;
  final int isFirst;
  final int isSeen1;
  final int isSeen2;
  final int isVideo;
  final int isNew;
  final int isSeen;

  final String senderName;
  final String senderProfilePicture;
  final String? senderLoginTime;

  final String receiverName;
  final String receiverProfilePicture;
  final String? receiverLoginTime;

  final String messageTime;

  final String senderProfilePictureUrl;
  final String receiverProfilePictureUrl;

  ChatHistoryModel({
    required this.id,
    this.message,
    required this.user1,
    required this.user2,
    required this.isSticker,
    required this.isPhoto,
    required this.stickerId,
    required this.time,
    required this.isFirst,
    required this.isSeen1,
    required this.isSeen2,
    required this.isVideo,
    required this.isNew,
    required this.isSeen,
    required this.senderName,
    required this.senderProfilePicture,
    this.senderLoginTime,
    required this.receiverName,
    required this.receiverProfilePicture,
    this.receiverLoginTime,
    required this.messageTime,
    required this.senderProfilePictureUrl,
    required this.receiverProfilePictureUrl,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      id: json["id"] ?? 0,
      message: json["message"],

      user1: json["user1"] ?? 0,
      user2: json["user2"] ?? 0,

      isSticker: json["is_sticker"] ?? 0,
      isPhoto: json["is_photo"] ?? 0,
      stickerId: json["sticker_id"] ?? 0,

      time: json["time"] ?? 0,

      isFirst: json["is_first"] ?? 0,
      isSeen1: json["is_seen_1"] ?? 0,
      isSeen2: json["is_seen_2"] ?? 0,

      isVideo: json["is_video"] ?? 0,
      isNew: json["is_new"] ?? 0,
      isSeen: json["is_seen"] ?? 0,

      senderName: json["sender_name"] ?? "",
      senderProfilePicture: json["sender_profile_picture"] ?? "",
      senderLoginTime: json["sender_login_time"],

      receiverName: json["receiver_name"] ?? "",
      receiverProfilePicture: json["receiver_profile_picture"] ?? "",
      receiverLoginTime: json["receiver_login_time"],

      messageTime: json["message_time"] ?? "",

      senderProfilePictureUrl: json["sender_profile_picture_url"] ?? "",

      receiverProfilePictureUrl: json["receiver_profile_picture_url"] ?? "",
    );
  }
}
