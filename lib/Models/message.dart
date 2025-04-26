import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/databaseDoctors.dart';
import 'package:med_assist/Controllers/databaseMedicalMessage.dart';
import 'package:med_assist/Models/doctor.dart';

class ManagersMedicalMessage {
  final String uid;
  final String name;
  final List<String> medicalMessages;

  ManagersMedicalMessage({
    required this.uid,
    required this.name,
    required this.medicalMessages,
  });

  final database = MedicalMessageService();
  final databaseDoctor = DoctorService();

  Stream<List<MedicalMessageData>> getMedicalMessagesStream() {
    final doctorService = DoctorService();

    return database.getMedicalMessagesByIds(ids: medicalMessages).asyncMap((
      messages,
    ) async {
      final doctorIds = messages.map((m) => m.doctorID).toSet().toList();

      final doctors = await doctorService.getDoctorsByIds(doctorIds);

      final doctorMap = {for (var doc in doctors) doc.id: doc};

      return messages.map((m) {
        final doctor = doctorMap[m.doctorID];
        return MedicalMessageData(medicalMessage: m, doctor: doctor!);
      }).toList();
    });
  }

  Future<void> sendMedicalMessage({
    required String doctorID,
    required String patientUid,
    required String message,
    required bool isRead,
    required bool isUrgent,
  }) async {
    String id = await database.addMedicalMessage(
      doctorID: doctorID,
      patientUid: patientUid,
      message: message,
      isRead: isRead,
      isUrgent: isUrgent,
    );

    medicalMessages.add(id);
    final db = DatabaseService(uid);
    await db.updateDataOfValue("medicalMessages", medicalMessages);
  }

  Future<void> responseMedicalMessage({
    required String medicalMessageId,
    required ResponseMedicalMessage response,
  }) async {
    await database.responseMedicalMessage(
      medicalMessageId: medicalMessageId,
      response: response,
    );
  }

  Future<void> deleteMedicalMessage({required String medicalMessageId}) async {
    await database.deleteMedicalMessage(medicalMessageId: medicalMessageId);
  }

  Future<void> readMedicalMessage({
    required String medicalMessageId,
    required bool read,
  }) async {
    await database.readMedicalMessage(
      medicalMessageId: medicalMessageId,
      read: read,
    );
  }
}

class MedicalMessage {
  final String id;
  final String patientUid;
  final String doctorID;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final bool isUrgent;
  final ResponseMedicalMessage response;

  MedicalMessage({
    required this.id,
    required this.patientUid,
    required this.doctorID,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.isUrgent = false,
    required this.response,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      'patientUid': patientUid,
      'doctorID': doctorID,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isUrgent': isUrgent,
      'response': response.toMap(),
    };
  }

  factory MedicalMessage.fromMap(Map<String, dynamic> map) {
    return MedicalMessage(
      id: map['id'] ?? '',
      patientUid: map['patientUid'] ?? '',
      doctorID: map['doctorID'] ?? '',
      message: map['message'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
      isUrgent: map['isUrgent'] ?? false,
      response: ResponseMedicalMessage.fromMap(map['response']),
    );
  }
}

class ResponseMedicalMessage {
  final String message;
  final DateTime createdAt;

  ResponseMedicalMessage({required this.message, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {'message': message, 'createdAt': createdAt.toIso8601String()};
  }

  factory ResponseMedicalMessage.fromMap(Map<String, dynamic> map) {
    return ResponseMedicalMessage(
      message: map['message'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class MedicalMessageData {
  final MedicalMessage medicalMessage;
  final Doctor doctor;

  MedicalMessageData({required this.medicalMessage, required this.doctor});
}
