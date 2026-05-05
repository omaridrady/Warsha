// To parse this JSON data, do
//
//     final request = requestFromJson(jsonString);

import 'dart:convert';

import 'clsLocation.dart';

clsRequest requestFromJson(String str) => clsRequest.fromJson(json.decode(str));

String requestToJson(clsRequest data) => json.encode(data.toJson());

class clsRequest {
  static String collectionName = "requests";
  String id;
  String clientId;
  String technicianId;
  String description;
  clsLocation location;
  List<String> images;
  String status;
  String type;
  int price;
  DateTime createdAt;


  clsRequest({
    required this.id,
    required this.clientId,
    required this.technicianId,
    required this.description,
    required this.location,
    required this.images,
    required this.status,
    required this.type,
    required this.price,
    required this.createdAt,

  });

  factory clsRequest.fromJson(Map<String, dynamic> json) => clsRequest(
    id: json["id"],
    clientId: json["clientId"],
    technicianId: json["technicianId"],
    description: json["description"],
    location: clsLocation.fromJson(json["location"]),
    images: List<String>.from(json["images"].map((x) => x)),
    status: json["status"],
    type: json["type"],
    price: json["price"],
    createdAt: DateTime.parse(json["createdAt"]),

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "clientId": clientId,
    "technicianId": technicianId,
    "description": description,
    "location": location.toJson(),
    "images": List<dynamic>.from(images.map((x) => x)),
    "status": status,
    "type":type,
    "price": price,
    "createdAt": createdAt.toIso8601String(),

  };
}



