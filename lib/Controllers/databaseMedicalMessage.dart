import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/message.dart';
import 'package:rxdart/rxdart.dart';

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
    ResponseMedicalMessage responseMedicalMessage = ResponseMedicalMessage(
      message: '',
      createdAt: DateTime.now(),
    );

    await docRef.set({
      'id': id,
      'doctorID': doctorID,
      'patientUid': patientUid,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
      'isRead': isRead,
      'isUrgent': isUrgent,
      'response': responseMedicalMessage.toMap(),
    });

    return id;
  }

  Future<void> responseMedicalMessage({
    required String medicalMessageId,
    required ResponseMedicalMessage response,
  }) async {
    await collection.doc(medicalMessageId).update({
      "response": response.toMap(),
    });
  }

  Future<void> readMedicalMessage({
    required String medicalMessageId,
    required bool read,
  }) async {
    await collection.doc(medicalMessageId).update({"isRead": read});
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

  Stream<List<MedicalMessage>> getMedicalMessagesByIds({
    required List<String> ids,
  }) {
    if (ids.isEmpty) return Stream.value([]);

    const chunkSize = 10;
    List<List<String>> chunks = [];

    for (var i = 0; i < ids.length; i += chunkSize) {
      chunks.add(
        ids.sublist(i, i + chunkSize > ids.length ? ids.length : i + chunkSize),
      );
    }

    List<Stream<List<MedicalMessage>>> streams =
        chunks.map((chunk) {
          return collection
              .where(FieldPath.documentId, whereIn: chunk)
              .snapshots()
              .map(
                (snapshot) =>
                    snapshot.docs
                        .map((doc) => MedicalMessage.fromMap(doc.data()))
                        .toList(),
              );
        }).toList();

    return Rx.combineLatestList<List<MedicalMessage>>(streams).map((lists) {
      return lists.expand((list) => list).toList();
    });
  }

  Stream<bool> hasUnreadMessagesStream({required List<String> ids}) {
    return getMedicalMessagesByIds(ids: ids).map((messages) {
      return messages.any((message) => !message.isRead);
    });
  }
}
