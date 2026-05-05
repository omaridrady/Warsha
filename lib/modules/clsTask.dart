// To parse this JSON data, do
//
//     final task = taskFromJson(jsonString);

import 'dart:convert';

clsTask taskFromJson(String str) => clsTask.fromJson(json.decode(str));

String taskToJson(clsTask data) => json.encode(data.toJson());

class clsTask {
  static String collectionName = "tasks";
  String id;
  String? requestId;
  String title;
  String description;
  bool isDone;
  DateTime createdAt;

  clsTask({
    required this.id,
    required this.requestId,
    required this.title,
    required this.description,
    required this.isDone,
    required this.createdAt,
  });

  factory clsTask.fromJson(Map<String, dynamic> json) => clsTask(
    id: json["id"],
    requestId: json["requestId"],
    title: json["title"],
    description: json["description"],
    isDone: json["isDone"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "requestId":requestId,
    "title": title,
    "description": description,
    "isDone": isDone,
    "createdAt": createdAt.toIso8601String(),
  };
}
