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

  Future<List<MedicalMessageData>> getMedicalMessages() async {
    List<MedicalMessage> medicalMessagesList = await database
        .getMedicalMessagesByIds(ids: medicalMessages);

    List<MedicalMessageData> medicalMessagesData = [];

    for (final message in medicalMessagesList) {
      final doctor = await databaseDoctor.getDoctorById(message.doctorID);
      if (doctor != null) {
        medicalMessagesData.add(
          MedicalMessageData(medicalMessage: message, doctor: doctor),
        );
      } else {
        print("⚠️ Aucun docteur trouvé pour l'ID: ${message.doctorID}");
      }
    }

    return medicalMessagesData;
  }

  Future<void> responseMedicalMessage({
    required String medicalMessageId,
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

    await database.responseMedicalMessage(
      medicalMessageId: medicalMessageId,
      responseId: id,
    );
  }

  Future<void> deleteMedicalMessage({required String medicalMessageId}) async {
    await database.deleteMedicalMessage(medicalMessageId: medicalMessageId);
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
  final String response;

  MedicalMessage({
    required this.id,
    required this.patientUid,
    required this.doctorID,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.isUrgent = false,
    this.response = '',
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      'patientUid': patientUid,
      'doctorID': doctorID,
      'message': message,
      'response': response,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isUrgent': isUrgent,
    };
  }

  factory MedicalMessage.fromMap(Map<String, dynamic> map) {
    return MedicalMessage(
      id: map['id'] ?? '',
      patientUid: map['patientUid'] ?? '',
      doctorID: map['doctorID'] ?? '',
      message: map['message'] ?? '',
      response: map['response'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
      isUrgent: map['isUrgent'] ?? false,
    );
  }
}

class MedicalMessageData {
  final MedicalMessage medicalMessage;
  final Doctor doctor;

  MedicalMessageData({required this.medicalMessage, required this.doctor});
}
