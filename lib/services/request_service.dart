import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/modules/clsProposals.dart';

import '../modules/clsLocation.dart';
import '../modules/clsRequest.dart';
import '../modules/clsTask.dart';

class RequestService {
  static Future<bool> addRequest({required clsRequest request}) async {
    try {
      await FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .add(request.toJson());
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
        return clsRequest.fromJson(doc.data()!, doc.id);
      } else {
        print('Request not found');
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  static Future<List<clsRequest>> getAllRequestsByType(String type) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("requests") // Ensure this matches your collection name
          .where("requestType", isEqualTo: type) // Corrected from "type" to "requestType"
          .get();

      return snapshot.docs
          .map((doc) => clsRequest.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  static Future<List<clsRequest>?> getAllUserRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<clsRequest>? requests;
    try {
      final data = await FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .where("clientId", isEqualTo: prefs.getString("uid"))
          .get();
      requests = data.docs.map((doc) {
        try {
          return clsRequest.fromJson(doc.data(), doc.id);
        } catch (e) {
          print("!!! Mapping Error on document ${doc.id}: $e");
         return [];
        }
      }).cast<clsRequest>().toList();
    }catch (e){
      print(e);
      return [];
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
      await FirebaseFirestore.instance
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
     await FirebaseFirestore.instance
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
    static Future<bool> sendProposal(clsProposal proposal) async {
    try {
      await FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(proposal.requestId)
          .collection('proposals')
          .doc(proposal.technicianId) // Use techId as Doc ID to prevent duplicate applications
          .set(proposal.toJson());

      return true;
    } catch (e) {
      print("Error sending proposal: $e");
      return false;
    }
  }

  static Future<List<clsProposal>> getProposalsForRequest(String requestId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("requests")
        .doc(requestId)
        .collection("proposals")
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => clsProposal.fromJson(doc.data(), doc.id))
        .toList();
  }

  static Future<bool> updateProposal(clsProposal proposal,String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection(clsRequest.collectionName)
          .doc(requestId)
          .collection(clsProposal.collectionName)
          .doc(proposal.id)
          .update(proposal.toJson());
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
  static Future<List<clsProposal>> getProposalsByTechnician(String techId) async {
    // Use a QueryGroup to find all 'proposals' subcollections where technicianId matches
    QuerySnapshot query = await FirebaseFirestore.instance
        .collectionGroup('proposals')
        .where('technicianId', isEqualTo: techId)
        .get();

    return query.docs.map((doc) => clsProposal.fromJson(doc.data() as Map<String, dynamic>,doc.id)).toList();
  }

  static Future<clsRequest?> getRequestById(String requestId) async {
    var doc = await FirebaseFirestore.instance.collection('requests').doc(requestId).get();
    if (doc.exists) {
      return clsRequest.fromJson(doc.data() as Map<String, dynamic>,doc.id);
    }
    return null;
  }
}
