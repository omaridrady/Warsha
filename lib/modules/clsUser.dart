// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

clsUser userFromJson(String str) => clsUser.fromJson(json.decode(str),"");

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
  List <String>? portfolio;

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
    this.portfolio
  });

  factory clsUser.fromJson(Map<String, dynamic> json,String docId) => clsUser(
    id : docId,
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
    portfolio: json["portfolio"] != null
  ? List<String>.from(json["portfolio"]) : [],
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
      // FIX: Check if portfolio is null before mapping, otherwise return null
      "portfolio": List<dynamic>.from((portfolio ?? []).map((x) => x)),
    };

    // This safely removes all null keys so Firestore doesn't get empty/null fields
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
