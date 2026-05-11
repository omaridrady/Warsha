import 'dart:convert';

clsProposal proposalFromJson(String str) => clsProposal.fromJson(json.decode(str), "");

class clsProposal {
  static String collectionName = "proposals";
  String? id; // The document ID (usually the technician's UID)
  String requestId;
  String technicianId;
  String technicianName;
  String? technicianPhoto;
  double rating;
  DateTime createdAt;
  String status; // e.g., "pending", "accepted", "rejected"

  clsProposal({
    this.id,
    required this.requestId,
    required this.technicianId,
    required this.technicianName,
    this.technicianPhoto,
    required this.rating,
    required this.createdAt,
    required this.status,
  });

  factory clsProposal.fromJson(Map<String, dynamic> json, String documentId) => clsProposal(
    id: documentId,
    requestId: json["requestId"],
    technicianId: json["technicianId"] ?? "",
    technicianName: json["technicianName"] ?? "Unknown Tech",
    technicianPhoto: json["technicianPhoto"],
    rating: (json["rating"] ?? 0.0).toDouble(),
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : DateTime.now(),
    status: json["status"] ?? "pending",
  );

  Map<String, dynamic> toJson() => {
    "technicianId": technicianId,
    "requestId" : requestId,
    "technicianName": technicianName,
    "technicianPhoto": technicianPhoto,
    "rating": rating,
    "createdAt": createdAt.toIso8601String(),
    "status": status,
  };
}