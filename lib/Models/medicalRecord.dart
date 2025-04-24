import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/databaseDoctors.dart';
import 'package:med_assist/Controllers/databaseMedicalRecords.dart';
import 'package:med_assist/Controllers/storageService.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:med_assist/Models/doctor.dart';

class ManagersMedicalRecord {
  final String uid;
  final String name;
  final List<String> medicalRecords;

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

  Future<String> checkCanAddMedicalRecord(
    String title,
    List<MedicalRecord> medicalRecordsData,
  ) async {
    bool exist = medicalRecordsData.any((r) => r.title == title);

    if (exist) return 'exist_medical_record'.tr();
    return 'Success';
  }

  Future<void> addMedicalRecord(String title, String category) async {
    String medicalRecordId = await database.addMedicalRecord(
      title: title,
      category: category.toUpperCase(),
      patientUid: uid,
      doctorIDs: [],
      creatorType: CreatorType.patient,
      canBeShared: true,
    );

    medicalRecords.add(medicalRecordId);
    //Firebase
    final db = DatabaseService(uid);
    await db.updateDataOfValue("medicalRecords", medicalRecords);
  }

  Future<void> removeMedicalRecord(MedicalRecord medicalRecord) async {
    if (medicalRecord.creatorType == CreatorType.patient) {
      await database.removeMedicalRecord(medicalRecord, uid);
    }

    medicalRecords.remove(medicalRecord.id);
    //Firebase
    final db = DatabaseService(uid);
    await db.updateDataOfValue("medicalRecords", medicalRecords);
  }

  String checkCanAddMedicalFile(MedicalRecord medicalRecord, String title) {
    if (kIsWeb) return 'invalid_device'.tr();
    bool exist = medicalRecord.medicalFiles.any((f) => f.title == title);

    if (exist) return 'exist_medical_file'.tr();
    return 'Success';
  }

  Future<String> checkCanAddFile(
    File file,
    List<MedicalRecord> medicalRecords,
  ) async {
    int size = await file.length();
    size = (size / 1024).ceil();
    bool canAdd = canAddFile(size, medicalRecords);

    if (!canAdd) return 'insufficient_space'.tr();
    return 'Success';
  }

  Future<void> addMedicalFile(
    MedicalRecord medicalRecord,
    String title,
    String fileType,
    File file,
  ) async {
    int size = await file.length();
    String fileUrl = await storage.uploadMedicalFile(
      file: file,
      uid: uid,
      medicalRecordTitle: medicalRecord.title,
      fileTitle: title,
    );
    MedicalFile medicalFile = MedicalFile(
      title: title,
      fileType: fileType,
      fileUrl: fileUrl,
      fileSize: size,
      createdAt: DateTime.now(),
    );

    await database.addMedicalFile(medicalRecord.id, medicalFile);
    medicalRecord.medicalFiles.add(medicalFile);
  }

  Future<void> moveMedicalFile(
    MedicalFile medicalFile,
    MedicalRecord medicalRecordOld,
    String medicalRecordNewId,
    String newMedicalRecordTitle,
  ) async {
    await database.moveMedicalFile(
      medicalFile,
      medicalRecordOld.id,
      uid,
      medicalRecordNewId,
      newMedicalRecordTitle,
    );
    medicalRecordOld.medicalFiles.remove(medicalFile);
  }

  Future<void> removeMedicalFile(
    MedicalRecord medicalRecord,
    MedicalFile medicalFile,
  ) async {
    await database.removeMedicalFile(medicalRecord.id, medicalFile);
    medicalRecord.medicalFiles.remove(medicalFile);
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
    final categories =
        medicalRecords.map((r) => r.category.toUpperCase()).toSet().toList();
    categories.sort();

    categories.insert(0, 'all'.tr());

    return categories;
  }

  Future<void> shareMedicalRecord(
    String doctorID,
    MedicalRecord medicalRecord,
  ) async {
    await database.shareMedicalRecord(medicalRecord.id, doctorID);

    medicalRecord.doctorIDs.add(doctorID);
  }
}

class MedicalRecord {
  final String id;
  final String title;
  final String category;
  final String patientUid;
  final List<String> doctorIDs;
  final List<MedicalFile> medicalFiles;
  final DateTime createdAt;
  final bool canBeShared;
  final CreatorType creatorType;

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.patientUid,
    required this.doctorIDs,
    required this.medicalFiles,
    required this.createdAt,
    required this.canBeShared,
    required this.creatorType,
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
      'doctorIDs': doctorIDs,
      'medicalFiles': medicalFiles.map((file) => file.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'canBeShared': canBeShared,
      'creatorType': creatorType.name,
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    final creatorType = CreatorType.values.firstWhere(
      (e) => e.name == map['creatorType'],
    );
    return MedicalRecord(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      patientUid: map['patientUid'] ?? '',
      doctorIDs: List<String>.from(map['doctorIDs']),
      medicalFiles: List<MedicalFile>.from(
        (map['medicalFiles'] as List).map((item) => MedicalFile.fromMap(item)),
      ),
      createdAt: DateTime.parse(map['createdAt']),
      canBeShared:
          map['canBeShared'] is bool
              ? map['canBeShared']
              : map['canBeShared'].toString().toLowerCase() == 'true',
      creatorType: creatorType,
    );
  }

  String get formattedDate {
    return DateFormat('EEE, d MMM yyyy').format(createdAt);
  }

  Future<List<Doctor>> getDoctors() async {
    return await DoctorService().getDoctorsByIds(doctorIDs);
  }
}

class MedicalFile {
  final String title;
  final String fileType;
  final String fileUrl;
  final int fileSize; //Bytes
  final DateTime createdAt;

  const MedicalFile({
    required this.title,
    required this.fileType,
    required this.fileUrl,
    required this.fileSize,
    required this.createdAt,
  });

  int get FSize {
    return (fileSize / 1024).ceil();
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicalFile.fromMap(Map<String, dynamic> map) {
    return MedicalFile(
      title: map['title'] ?? '',
      fileType: map['fileType'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String get formattedDate {
    return DateFormat('EEE, d MMM yyyy').format(createdAt);
  }
}

enum CreatorType { doctor, patient }
