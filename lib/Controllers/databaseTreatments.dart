import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/treat.dart';

class TreatmentService {
  final CollectionReference<Map<String, dynamic>> treatmentCollection =
      FirebaseFirestore.instance.collection("treatments");

  Future<void> addTreatment(Treat treatment) async {
    try {
      await FirebaseFirestore.instance
          .collection("treatments")
          .doc(treatment.code)
          .set(treatment.toMap());
    } catch (e) {
      throw Exception("Failed to add treatment: $e");
    }
  }

  Future<void> updateTreatment(Treat treatment) async {
    try {
      await FirebaseFirestore.instance
          .collection("treatments")
          .doc(treatment.code)
          .update(treatment.toMap());
    } catch (e) {
      throw Exception("Failed to update treatment: $e");
    }
  }

  Future<void> deleteTreatment(String code) async {
    try {
      await FirebaseFirestore.instance
          .collection("treatments")
          .doc(code)
          .delete();
    } catch (e) {
      throw Exception("Failed to delete treatment: $e");
    }
  }

  Future<Treat> getTreatmentByCode(String code) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("treatments")
              .doc(code)
              .get();

      if (!snapshot.exists) {
        throw Exception("Treatment not found");
      }

      return Treat.fromMap(snapshot.data()!);
    } catch (e) {
      throw Exception("Failed to get treatment: $e");
    }
  }

  Stream<List<Treat>> get treatments {
    return FirebaseFirestore.instance.collection("treatments").snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => Treat.fromMap(doc.data())).toList();
    });
  }

  Future<List<Treat>> getPublicTreatments() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection("treatments")
              .where("isPublic", isEqualTo: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Treat.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Failed to get public treatments: $e");
    }
  }

  Future<void> addFollowerToTreatment(String code, String followerUid) async {
    try {
      final treatmentRef = FirebaseFirestore.instance
          .collection("treatments")
          .doc(code);

      await treatmentRef.update({
        "followers": FieldValue.arrayUnion([followerUid]),
      });
    } catch (e) {
      throw Exception("Failed to add follower: $e");
    }
  }

  Future<void> removeFollowerFromTreatment(
    String code,
    String followerUid,
  ) async {
    try {
      final treatmentRef = FirebaseFirestore.instance
          .collection("treatments")
          .doc(code);

      await treatmentRef.update({
        "followers": FieldValue.arrayRemove([followerUid]),
      });
    } catch (e) {
      throw Exception("Failed to remove follower: $e");
    }
  }
}
