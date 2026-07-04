// class FilterMatchModel {
//   final int id;
//   final String name;
//   final int age;
//   final String location;
//   final String city;
//   final String matchPercent;
//   final String imagePath;
//   final bool isOnline;
//   bool isFavorite;
//   bool isInterested;
//
//   FilterMatchModel({
//     required this.id,
//     required this.name,
//     required this.age,
//     required this.location,
//     required this.city,
//     required this.matchPercent,
//     required this.imagePath,
//     this.isOnline = false,
//     this.isFavorite = false,
//     this.isInterested = false,
//   });
//
//   // ✅ ADD THIS METHOD
//   FilterMatchModel copyWith({
//     int? id,
//     String? name,
//     int? age,
//     String? location,
//     String? city,
//     String? matchPercent,
//     String? imagePath,
//     bool? isOnline,
//     bool? isFavorite,
//     bool? isInterested,
//   }) {
//     return FilterMatchModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       age: age ?? this.age,
//       location: location ?? this.location,
//       city: city ?? this.city,
//       matchPercent: matchPercent ?? this.matchPercent,
//       imagePath: imagePath ?? this.imagePath,
//       isOnline: isOnline ?? this.isOnline,
//       isFavorite: isFavorite ?? this.isFavorite,
//       isInterested: isInterested ?? this.isInterested,
//     );
//   }
//
//   factory FilterMatchModel.fromJson(Map<String, dynamic> json) {
//     return FilterMatchModel(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       name: json['full_name'] ?? "",
//       age: int.tryParse(json['age']?.toString() ?? '0') ?? 0,
//       location: json['country'] ?? "Unknown",
//       city: json['city'] ?? "",
//       matchPercent: "${json['percent_match']}%",
//       imagePath: json['profile_picture'] ?? "", // Raw filename from DB
//       isOnline: json['is_online'] == 1 || json['is_online'] == true,
//       isFavorite: json['is_favorite'] ?? false,
//       isInterested: json['is_interested'] ?? false,
//     );
//   }
// }
class FilterMatchModel {
  final int id;
  final String name;
  final int age;
  final String location;
  final String city;
  final String matchPercent;
  final String imagePath;
  final bool isOnline;
  bool isFavorite;
  bool isInterested;
  bool isDislike;

  FilterMatchModel({
    required this.id, required this.name, required this.age,
    required this.location, required this.city, required this.matchPercent,
    required this.imagePath, this.isOnline = false,
    this.isFavorite = false, this.isInterested = false, this.isDislike = false,
  });

  FilterMatchModel copyWith({String? imagePath,
    bool? isFavorite, bool? isInterested, bool? isDislike,
    bool? isOnline,}) {
    return FilterMatchModel(
      id: id, name: name, age: age, location: location,
      city: city,
      matchPercent: matchPercent,
      isOnline: isOnline?? this.isOnline,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      isInterested: isInterested ?? this.isInterested,
      isDislike: isDislike ?? this.isDislike,
    );
  }
// lib/models/user_match_model.dart

  factory FilterMatchModel.fromJson(Map<String, dynamic> json) {
    return FilterMatchModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['full_name'] ?? json['name'] ?? "Unknown",
      age: int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      location: json['country'] ?? "Unknown",
      city: json['city'] ?? "",
      // ✅ Fix: Robustly parse the match percentage
      matchPercent: "${json['percent_match'] ?? '0'}%",
      imagePath: json['profile_picture'] ?? "",
      isOnline: json['is_online'] == 1 || json['is_online'] == true || json['is_online'] == "true",
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      isInterested: json['is_interested'] == true || json['is_interested'] == 1,
      isDislike: json['is_block'] ==true || json['is_block'] == 1,
    );
  }

}

