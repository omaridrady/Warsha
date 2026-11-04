// To parse this JSON data, do
//
//     final request = requestFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../modules/clsLocation.dart';

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

  DateTime createdAt;

  clsRequest({
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

    "createdAt": createdAt.toIso8601String(),
  };

  IconData get getWarshaIcon {
    switch (requestType) {
      case "Plumbing":
        return Icons.plumbing;

      case "Electrical":
        return Icons.bolt;

      case "HVAC":
        return Icons.ac_unit;

      case "Painting":
        return Icons.format_paint;

      case "Carpentry":
        return Icons.carpenter_outlined;

      case "Cleaning":
        return Icons.cleaning_services_outlined;
    }
    return Icons.error_outline;
  }



  String get formatedDate {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    String formatedMonth = months[createdAt.month - 1];
    String formatedDay = createdAt.day.toString().padLeft(2, '0');

    return "$formatedMonth $formatedDay";
  }
}
