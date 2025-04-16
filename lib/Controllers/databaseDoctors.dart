import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/doctor.dart';

class DoctorService {
  final CollectionReference<Map<String, dynamic>> userCollectionDoctors =
      FirebaseFirestore.instance
          .collection("users")
          .doc("doctors")
          .collection("users");

  Future<List<Doctor>> getAllDoctors() async {
    final snapshot = await userCollectionDoctors.get();
    return snapshot.docs.map((doc) => Doctor.fromMap(doc.data())).toList();
  }

  Future<List<Doctor>> getDoctorsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshots = await Future.wait(
      ids.map((id) => userCollectionDoctors.doc(id).get()),
    );

    return snapshots
        .where((snap) => snap.exists)
        .map((snap) => Doctor.fromMap(snap.data()!))
        .toList();
  }

  Future<Doctor?> getDoctorById(String id) async {
    final docSnap = await userCollectionDoctors.doc(id).get();

    if (docSnap.exists && docSnap.data() != null) {
      return Doctor.fromMap(docSnap.data()!);
    } else {
      return null;
    }
  }

  Future<void> addDoctor(Doctor doctor) async {
    try {
      await userCollectionDoctors.doc(doctor.id).set(doctor.toMap());
    } catch (e) {
      throw Exception("Failed to add doctor: $e");
    }
  }
}
