import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Controllers/storageService.dart';
import 'package:med_assist/Models/medicalRecord.dart';
import 'package:rxdart/rxdart.dart';

class ServiceMedicalRecord {
  final CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore
      .instance
      .collection("medical-records");
  final storage = StorageService();

  Future<String> addMedicalRecord({
    required String title,
    required String category,
    required String patientUid,
    required List<String> doctorIDs,
    required bool canBeShared,
    required CreatorType creatorType,
  }) async {
    final docRef = collection.doc();
    final id = docRef.id;

    await docRef.set({
      'id': id,
      'title': title,
      'category': category,
      'patientUid': patientUid,
      'doctorIDs': doctorIDs,
      'medicalFiles': [],
      'createdAt': DateTime.now().toIso8601String(),
      'canBeShared': canBeShared,
      'creatorType': creatorType.name,
    });

    return id;
  }

  Future<void> removeMedicalRecord(
    MedicalRecord medicalRecord,
    String patientUid,
  ) async {
    try {
      await collection.doc(medicalRecord.id).delete();

      await storage.deleteMedicalRecordFolder(patientUid, medicalRecord.title);

      print('Dossier médical supprimé avec succès.');
    } catch (e) {
      throw Exception("Échec de la suppression du dossier médical : $e");
    }
  }

  Future<void> addMedicalFile(
    String medicalRecordId,
    MedicalFile medicalFile,
  ) async {
    try {
      await collection.doc(medicalRecordId).update({
        'medicalFiles': FieldValue.arrayUnion([medicalFile.toMap()]),
      });
    } catch (e) {
      throw Exception("Failed to update data: $e");
    }
  }

  Future<void> shareMedicalRecord(
    String medicalRecordId,
    String doctorID,
  ) async {
    try {
      await collection.doc(medicalRecordId).update({
        'doctorIDs': FieldValue.arrayUnion([doctorID]),
      });
    } catch (e) {
      throw Exception("Failed to update data: $e");
    }
  }

  Future<void> removeMedicalFile(
    String medicalRecordId,
    MedicalFile medicalFile,
  ) async {
    try {
      await collection.doc(medicalRecordId).update({
        'medicalFiles': FieldValue.arrayRemove([medicalFile.toMap()]),
      });
      await storage.deleteMedicalFileFromUrl(medicalFile.fileUrl);
    } catch (e) {
      throw Exception("Failed to remove file: $e");
    }
  }

  Future<void> moveMedicalFile(
    MedicalFile medicalFile,
    String medicalRecordOldId,
    String newUid,
    String medicalRecordNewId,
    String newMedicalRecordTitle,
  ) async {
    try {
      // Étape 1 : Déplacement du fichier dans le storage
      final newFileUrl = await storage.moveMedicalFileFromUrl(
        publicUrl: medicalFile.fileUrl,
        newUid: newUid,
        newMedicalRecordTitle: newMedicalRecordTitle,
      );

      // Étape 2 : Enregistrement du nouveau fichier en base
      final newMedicalFile = MedicalFile(
        title: medicalFile.title,
        fileType: medicalFile.fileType,
        fileUrl: newFileUrl,
        fileSize: medicalFile.fileSize,
        createdAt: DateTime.now(),
      );

      await addMedicalFile(medicalRecordNewId, newMedicalFile);

      // Étape 3 : Suppression de l'ancien fichier en base
      await collection.doc(medicalRecordOldId).update({
        'medicalFiles': FieldValue.arrayRemove([medicalFile.toMap()]),
      });
      print('Fichier "${medicalFile.title}" déplacé avec succès.');
    } catch (e) {
      print('Erreur lors du déplacement du fichier : $e');
      rethrow;
    }
  }

  Future<List<MedicalRecord>> getMedicalRecordByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshots = await Future.wait(
      ids.map((id) => collection.doc(id).get()),
    );

    return snapshots
        .where((snap) => snap.exists)
        .map((snap) => MedicalRecord.fromMap(snap.data()!))
        .toList();
  }

  Stream<List<MedicalRecord>> streamMedicalRecordsByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);

    final streams = ids.map((id) => collection.doc(id).snapshots());

    return CombineLatestStream.list(streams).map((snapshots) {
      return snapshots
          .where((snap) => snap.exists)
          .map((snap) => MedicalRecord.fromMap(snap.data()!))
          .toList();
    });
  }
}
