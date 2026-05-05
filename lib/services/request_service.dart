import 'package:cloud_firestore/cloud_firestore.dart';

import '../modules/clsRequest.dart';
import '../modules/clsTask.dart';

class RequestService {
  static Future<bool> addRequest(clsRequest Request) async {
    try {
      await FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .add(Request.toJson());
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  static Future<clsRequest?> getRequest(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) {
        return clsRequest.fromJson(doc.data()!);
      } else {
        print('Request not found');
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  static Future<List<clsRequest>?> getAllRequestsByType(String type) async {
    List<clsRequest>? requests;
    try {
      FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .where("type", isEqualTo: type)
          .snapshots()
          .listen((snapshot) {
            final data = snapshot.docs
                .map((doc) => clsRequest.fromJson(doc.data()))
                .toList();

            requests = data;
          });
    } catch (e) {
      print(e);
      return null;
    }
    return requests;
  }

  static Future<bool> updateRequest(clsRequest Request) async {
    try {
      FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(Request.id)
          .update(Request.toJson());
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  static Future<bool> deleteRequest(String requestId) async {
    try {
      FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(requestId)
          .delete();
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  static Future<bool> addTask(clsTask task) async {
    try {
      await FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(task.requestId)
          .collection(clsTask.collectionName)
          .add(task.toJson());
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  static Future<List<clsTask>?> getAllTasksOnRequest(String requestId) async {
    List<clsTask>? tasks;
    try {
      FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(requestId)
          .collection(clsTask.collectionName)
          .snapshots()
          .listen((snapshot) {
            final data = snapshot.docs
                .map((doc) => clsTask.fromJson(doc.data()))
                .toList();

            tasks = data;
          });
    } catch (e) {
      print(e);
      return null;
    }
    return tasks;
  }

  static Future<bool> updateTask(clsTask task) async {
    try {
      FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(task.requestId)
          .collection(clsTask.collectionName)
          .doc(task.id)
          .update(task.toJson());
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  static Future<bool> deleteTask(String requestId, String taskId) async {
    try {
      FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(requestId)
          .collection(clsTask.collectionName)
          .doc(taskId)
          .delete();
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
