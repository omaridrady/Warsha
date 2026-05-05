// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

clsReview reviewFromJson(String str) => clsReview.fromJson(json.decode(str));

String reviewToJson(clsReview data) => json.encode(data.toJson());

class clsReview {
  static String collectionName = "reviews";
  String id;
  String requestId;
  String clientId;
  String technicianId;
  int rating;
  String? comment;
  DateTime createdAt;

  clsReview({
    required this.id,
    required this.requestId,
    required this.clientId,
    required this.technicianId,
    required this.rating,
     this.comment,
    required this.createdAt,
  });

  factory clsReview.fromJson(Map<String, dynamic> json) => clsReview(
    id: json["id"],
    requestId: json["requestId"],
    clientId: json["clientId"],
    technicianId: json["technicianId"],
    rating: json["rating"],
    comment: json["comment"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "requestId": requestId,
    "clientId": clientId,
    "technicianId": technicianId,
    "rating": rating,
    "comment": comment,
    "createdAt": createdAt.toIso8601String(),
  };
}
