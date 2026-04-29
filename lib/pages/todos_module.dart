import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Todosmodule {
  String? userId;
  String? id;
  String? title;
  bool? completed;
  DateTime? time;

  Todosmodule({
    required this.userId,
    this.id,
    required this.title,
    required this.completed,
    this.time
  });

  factory Todosmodule.fromJson(Map<String, dynamic> json,String docId) => Todosmodule(
    userId: json["UserId"],
    id: docId,
    title: json["Title"],
    completed: json["Completed"],
    time: json["CreatedTime"].toDate()
  );

  Map<String, dynamic> toJson() => {
    "UserId": userId,
    "Title": title,
    "Completed": completed,
    "CreatedTime":DateTime.now()
  };
}
