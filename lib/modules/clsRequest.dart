// To parse this JSON data, do
//
//     final request = requestFromJson(jsonString);

import 'dart:convert';

import 'clsLocation.dart';

clsRequest requestFromJson(String str) =>
    clsRequest.fromJson(json.decode(str), "");

String requestToJson(clsRequest data) => json.encode(data.toJson());

class clsRequest {
  static String collectionName = "requests";
  String? id;
  String clientId;
  String clientName; // Add this
  String clientPhone;
  String? technicianId;
  String description;
  clsLocation location;
  List<String> images;
  String status;
  String requestType;
  double price;
  DateTime createdAt;

  clsRequest(   {
    this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    this.technicianId,
    required this.description,
    required this.location,
    required this.images,
    required this.status,
    required this.requestType,
    required this.price,
    required this.createdAt,
  });

  factory clsRequest.fromJson(Map<String, dynamic> json, String documentId) {
    return clsRequest(
      id: documentId,
      // If clientId is null in Firestore, use an empty string instead of crashing
      clientId: json["clientId"] ?? "",

      clientName: json["clientName"],

      clientPhone: json["clientPhone"],

      technicianId: json["technicianId"], // This is String?, so null is okay

      description: json["description"] ?? "",

      // Ensure location parsing is safe
      location: json["location"] != null
          ? clsLocation.fromJson(json["location"])
          : clsLocation(lat: 0.0, lng: 0.0),

      images: json["images"] != null ? List<String>.from(json["images"]) : [],

      // Your screenshot shows 'isComplete', but your model wants 'status'
      // This fallback checks both possibilities
      status:
          json["status"] ??
          (json["isComplete"] == true ? "Completed" : "Pending"),

      requestType: json["requestType"] ?? "Unknown",

      price: (json["price"] ?? 0).toDouble(),

      // Safe DateTime parsing
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "clientId": clientId,
    "clientName": clientName,
    "clientPhone": clientPhone,
    "technicianId": technicianId,
    "description": description,
    "location": location.toJson(),
    "images": List<dynamic>.from(images.map((x) => x)),
    "status": status,
    "requestType": requestType,
    "price": price,
    "createdAt": createdAt.toIso8601String(),
  };
}
