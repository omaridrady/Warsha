import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warsha/modules/clsReview.dart';

import '../modules/clsUser.dart';

class UserService {
  static Future<bool> addUser(clsUser user) async {
    try {
      await FirebaseFirestore.instance
          .collection("users").doc(user.id)
          .set(user.toJson());
    } catch (e) {
      print("Error adding user: $e");
      return false;
    }
    return true;
  }

  static Future<clsUser?> getUser(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(clsUser.collectionName)
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) {
        return clsUser.fromJson(doc.data()!,doc.id);
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  static Future<bool> updateUser(clsUser user) async {
    try {
      FirebaseFirestore.instance
          .collection(clsUser.collectionName)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  static Future<bool> addReview(clsReview review) async {
    try {
      await FirebaseFirestore.instance
          .collection(clsUser.collectionName)
          .doc(review.technicianId)
          .collection(clsReview.collectionName)
          .add(review.toJson());
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  static Future<List<clsReview>?> getAllReviewsOnTechnician(
    String technicianId,
  ) async {
    List<clsReview>? reviews;
    try {
      FirebaseFirestore.instance
          .collection(clsUser.collectionName)
          .doc(technicianId)
          .collection(clsReview.collectionName)
          .snapshots()
          .listen((snapshot) {
            final data = snapshot.docs
                .map((doc) => clsReview.fromJson(doc.data()))
                .toList();

            reviews = data;
          });
    } catch (e) {
      print(e);
      return null;
    }
    return reviews;
  }

  static Future<bool> deleteReview(String technicianId, String reviewId) async {
    try {
      FirebaseFirestore.instance
          .collection(clsUser.collectionName)
          .doc(technicianId)
          .collection(clsReview.collectionName)
          .doc(reviewId)
          .delete();
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
