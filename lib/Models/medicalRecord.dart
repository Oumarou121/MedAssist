import 'dart:io';

import 'package:intl/intl.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/databaseMedicalRecords.dart';
import 'package:med_assist/Controllers/storageService.dart';
import 'package:mime/mime.dart';

class ManagersMedicalRecord {
  final String uid;
  final String name;
  List<String> medicalRecords;

  static const double maxMemory = 50 * 1024;

  ManagersMedicalRecord({
    required this.uid,
    required this.name,
    required this.medicalRecords,
  });

  final database = ServiceMedicalRecord();
  final storage = StorageService();

  Future<List<MedicalRecord>> getMedicalRecords() async {
    return await database.getMedicalRecordByIds(medicalRecords);
  }

  Future<String> checkMedicalRecord(
    String title,
    List<MedicalRecord> medicalRecordsData,
  ) async {
    bool exist = medicalRecordsData.any((r) => r.title == title);

    if (exist) return 'This Medical Record already exist';
    return 'Success';
  }

  Future<void> addMedicalRecord(String title, String category) async {
    String medicalRecordId = await database.addMedicalRecord(
      title,
      category,
      uid,
      '',
    );

    medicalRecords.add(medicalRecordId);
    //Firebase
    final db = DatabaseService(uid);
    await db.updateDataOfValue("medicalRecords", medicalRecords);
  }

  Future<void> removeMedicalRecord(MedicalRecord medicalRecord) async {
    await database.removeMedicalRecord(medicalRecord, uid);
  }

  String checkMedicalFile(MedicalRecord medicalRecord, String title) {
    bool exist = medicalRecord.medicalFiles.any((f) => f.title == title);

    if (exist) return 'This Medical File already exist in this folder';
    return 'Success';
  }

  Future<String> checkCanAdd(
    File file,
    List<MedicalRecord> medicalRecords,
  ) async {
    int size = await file.length();
    size = (size / 1024).ceil();
    bool canAdd = canAddFile(size, medicalRecords);

    if (canAdd) return 'Insufficient space. 50MB limit exceeded.';
    return 'Success';
  }

  Future<void> addMedicalFile(
    String medicalRecordTitle,
    String medicalRecordId,
    String title,
    // String type,
    File file,
  ) async {
    int size = await file.length();
    String? fileType = lookupMimeType(file.path);
    String fileUrl = await storage.uploadMedicalFile(
      file: file,
      uid: uid,
      medicalRecordTitle: medicalRecordTitle,
      fileTitle: title,
    );
    MedicalFile medicalFile = MedicalFile(
      title: title,
      // type: type,
      fileType: fileType!,
      fileUrl: fileUrl,
      fileSize: size,
      createdAt: DateTime.now(),
    );

    await database.addMedicalFile(medicalRecordId, medicalFile);
  }

  Future<void> moveMedicalFile(
    MedicalFile medicalFile,
    String medicalRecordOldId,
    String medicalRecordNewId,
    String newMedicalRecordTitle,
  ) async {
    await database.moveMedicalFile(
      medicalFile,
      medicalRecordOldId,
      uid,
      medicalRecordNewId,
      newMedicalRecordTitle,
    );
  }

  Future<void> removeMedicalFile(
    String medicalRecordId,
    MedicalFile medicalFile,
  ) async {
    await database.removeMedicalFile(medicalRecordId, medicalFile);
  }

  int totalUsedMemory(List<MedicalRecord> myMedicalRecords) {
    return myMedicalRecords.fold(
      0,
      (sum, record) => sum + record.totalSizeInKo,
    );
  }

  bool canAddFile(int size, List<MedicalRecord> myMedicalRecords) {
    int currentMemory = totalUsedMemory(myMedicalRecords);
    return (currentMemory + size) <= maxMemory;
  }

  List<String> getAllCategories(List<MedicalRecord> medicalRecords) {
    final categories = medicalRecords.map((r) => r.category).toSet().toList();
    categories.sort();

    categories.insert(0, 'All');

    return categories;
  }
}

class MedicalRecord {
  final String id;
  final String title;
  final String category;
  final String patientUid;
  final String doctorID;
  final List<MedicalFile> medicalFiles;
  final DateTime createdAt;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.patientUid,
    required this.doctorID,
    required this.medicalFiles,
    required this.createdAt,
  });

  int get totalSizeInKo {
    int totalBytes = medicalFiles.fold(0, (sum, file) => sum + file.fileSize);
    return (totalBytes / 1024).ceil();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'patientUid': patientUid,
      'doctorID': doctorID,
      'medicalFiles': medicalFiles.map((file) => file.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      patientUid: map['patientUid'] ?? '',
      doctorID: map['doctorID'] ?? '',
      medicalFiles: List<MedicalFile>.from(
        (map['medicalFiles'] as List).map((item) => MedicalFile.fromMap(item)),
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String get formattedDate {
    return DateFormat('EEE, d MMM yyyy').format(createdAt);
  }
}

class MedicalFile {
  final String title;
  // final String type;
  final String fileType;
  final String fileUrl;
  final int fileSize; //Bytes
  final DateTime createdAt;

  const MedicalFile({
    required this.title,
    // required this.type,
    required this.fileType,
    required this.fileUrl,
    required this.fileSize,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      // 'type': type,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicalFile.fromMap(Map<String, dynamic> map) {
    return MedicalFile(
      title: map['title'] ?? '',
      // type: map['type'] ?? '',
      fileType: map['fileType'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
