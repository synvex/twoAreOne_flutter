
class UserModel {
  final Map<String, dynamic> raw;

  const UserModel(this.raw);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(json);

  Map<String, dynamic> toJson() => raw;

  dynamic operator [](String key) => raw[key];

  String? get id => raw['id']?.toString() ?? raw['user_id']?.toString();
  String? get name => raw['name']?.toString() ?? raw['full_name']?.toString();
  String? get email => raw['email']?.toString();
  String? get phone => raw['phone']?.toString() ?? raw['phone_no']?.toString();
  String? get profilePhoto => raw['profile_photo']?.toString() ?? raw['photo']?.toString();


  String get completeQuestion => raw['complete_question']?.toString() ?? 'false';
  String get screenType => raw['screen_type']?.toString() ?? '0';

  UserModel copyWithMerge(Map<String, dynamic> patch) => UserModel({...raw, ...patch});
}
