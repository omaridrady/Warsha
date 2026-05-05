// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

clsUser userFromJson(String str) => clsUser.fromJson(json.decode(str));

String userToJson(clsUser data) => json.encode(data.toJson());

class clsUser {
  static String collectionName = "users";
  String? id;
  String name;
  String phone;
  String role;
  DateTime birthdate;
  String? profileImage;
  String? specialty;
  double? rating;
  int? reviewsCount;
  int? totalJobsDone;
  double? totalEarnings;
  bool? isAvailable;
  DateTime createdAt;

  clsUser({
     this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.birthdate,
     this.profileImage,
    this.specialty,
    this.rating,
    this.reviewsCount,
    this.totalJobsDone,
    this.totalEarnings,
    this.isAvailable,
    required this.createdAt,
  });

  factory clsUser.fromJson(Map<String, dynamic> json) => clsUser(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    role: json["role"],
    birthdate: DateTime.parse(json["birthdate"]),

    profileImage: json["profileImage"] ?? "",

    specialty: json["specialty"] ?? "",
    rating: json["rating"]?.toDouble(),
    reviewsCount: json["reviewsCount"] ?? null,
    totalJobsDone: json["totalJobsDone"] ?? null,
    totalEarnings: json["totalEarnings"]?.toDouble(),
    isAvailable: json["isAvailable"] ?? false,
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() {
    final data = {

      "name": name,
      "phone": phone,
      "role": role,
      "birthdate": birthdate.toIso8601String(),
      "profileImage": profileImage,
      "specialty": specialty,
      "rating": rating,
      "reviewsCount": reviewsCount,
      "totalJobsDone": totalJobsDone,
      "totalEarnings": totalEarnings,
      "isAvailable": isAvailable,
      "createdAt": createdAt.toIso8601String(),
    };
    data.removeWhere((key,value) => value == null);
    return data;
  }
}
