import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/message.dart';

class MedicalMessageService {
  final CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore
      .instance
      .collection('medical-messages');

  Future<String> addMedicalMessage({
    required String doctorID,
    required String patientUid,
    required String message,
    required bool isRead,
    required bool isUrgent,
  }) async {
    final docRef = collection.doc();
    final id = docRef.id;

    await docRef.set({
      'id': id,
      'doctorID': doctorID,
      'patientUid': patientUid,
      'message': message,
      'response': '',
      'createdAt': DateTime.now().toIso8601String(),
      'isRead': isRead,
      'isUrgent': isUrgent,
    });

    return id;
  }

  Future<void> responseMedicalMessage({
    required String medicalMessageId,
    required String responseId,
  }) async {
    await collection.doc(medicalMessageId).update({"response": responseId});
  }

  Future<void> deleteMedicalMessage({required String medicalMessageId}) async {
    await collection.doc(medicalMessageId).delete();
  }

  Future<void> updateMedicalMessage(MedicalMessage medicalMessage) async {
    await collection.doc(medicalMessage.id).update(medicalMessage.toMap());
  }

  Future<MedicalMessage> getMedicalMessage({
    required String medicalMessageId,
  }) async {
    final snapshot = await collection.doc(medicalMessageId).get();
    return MedicalMessage.fromMap(snapshot.data()!);
  }

  Future<List<MedicalMessage>> getMedicalMessagesByIds({
    required List<String> ids,
  }) async {
    if (ids.isEmpty) return [];

    final snapshots = await Future.wait(
      ids.map((id) => collection.doc(id).get()),
    );

    return snapshots
        .where((snap) => snap.exists)
        .map((snap) => MedicalMessage.fromMap(snap.data()!))
        .toList();
  }
}
