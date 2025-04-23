import 'package:intl/intl.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/databaseAppointments.dart';
import 'package:med_assist/Controllers/databaseDoctors.dart';
import 'package:med_assist/Controllers/databaseRequests.dart';
import 'package:med_assist/Controllers/databaseTreatments.dart';
import 'package:med_assist/Models/treat.dart';

class ManagersDoctors {
  final String uid;
  final String name;
  final List<String> doctors;
  final List<String> requests;
  final List<String> appointments;

  ManagersDoctors({
    required this.uid,
    required this.name,
    required this.doctors,
    required this.requests,
    required this.appointments,
  });

  Future<List<Doctor>> getDoctors() async {
    return await DoctorService().getDoctorsByIds(doctors);
  }

  Future<List<Appointment>> getAppointments() async {
    return await AppointmentService().getAppointmentsByIds(appointments);
  }

  Future<List<Request>> getRequests() async {
    return await RequestService().getRequestsByIds(requests);
  }

  Future<String> checkSendJoinDoctorRequest(String doctorID) async {
    List<Doctor> docs = await DoctorService().getAllDoctors();
    if (docs.isEmpty) return "This Doctor ID is invalid";

    bool exists = docs.any((doc) => doc.id == doctorID);
    if (!exists) return "This Doctor ID is invalid";

    bool alreadyExists = doctors.any((doc) => doc == doctorID);
    if (alreadyExists) return "This Doctor is already follow you";

    List<Request> myRequests = await RequestService().getRequestsByIds(
      requests,
    );

    bool alreadyRequest = myRequests.any(
      (req) =>
          req.doctorUid == doctorID &&
          req.patientUid == uid &&
          req.requestType == RequestType.doctor &&
          req.status == RequestStatus.pending,
    );

    if (alreadyRequest) {
      return "You already send a request please wait until the doctor give a answer";
    }

    Doctor doctor = docs.firstWhere((doc) => doc.id == doctorID);
    return "Success/${doctor.name}";
  }

  Future<void> sendJoinDoctorRequest(String doctorID) async {
    Request request = Request(
      requestType: RequestType.doctor,
      status: RequestStatus.pending,
      doctorUid: doctorID,
      patientUid: uid,
      senderType: SenderType.patient,
    );

    requests.add(request.id);
    //Firebase
    final db = DatabaseService(uid);
    await db.updateDataOfValue("requests", requests);
    await RequestService().addRequest(request);
  }

  Future<String> checkSendAppointRequest(
    String doctorID,
    DateTime startTime,
  ) async {
    List<Request> myRequests = await RequestService().getRequestsByIds(
      requests,
    );
    bool alreadyRequested = myRequests.any(
      (req) =>
          req.doctorUid == doctorID &&
          req.patientUid == uid &&
          req.requestType == RequestType.appointment &&
          req.status == RequestStatus.pending,
    );

    if (alreadyRequested) {
      return "You have already submitted a request. Please wait for the doctor's response.";
    }

    return "Success";
  }

  Future<void> sendAppointRequest(
    String doctorID,
    DateTime startTime,
    String reason,
  ) async {
    Request request = Request(
      requestType: RequestType.appointment,
      status: RequestStatus.pending,
      doctorUid: doctorID,
      patientUid: uid,
      startTime: startTime,
      appointmentReason: reason,
      senderType: SenderType.patient,
    );

    requests.add(request.id);
    //Firebase
    final db = DatabaseService(uid);
    await db.updateDataOfValue("requests", requests);
    await RequestService().addRequest(request);
  }

  Future<void> removeRequest(String requestId) async {
    requests.remove(requestId);
    //Firebase
    final db = DatabaseService(uid);
    await db.updateDataOfValue("requests", requests);
    await RequestService().deleteRequest(requestId);
  }

  Future<void> updateRequestStatus(
    Request request,
    RequestStatus newStatus,
    ManagersTreats managersTreats,
  ) async {
    if (newStatus == RequestStatus.agreed) {
      if (request.requestType == RequestType.doctor) {
        doctors.add(request.doctorUid);
        final db = DatabaseService(uid);
        await db.updateDataOfValue("doctors", doctors);
      } else if (request.requestType == RequestType.appointment) {
        DateTime date = request.startTime!;
        final appointment = Appointment(
          doctorUid: request.doctorUid,
          patientUid: request.patientUid,
          startTime: date,
        );
        appointments.add(appointment.id);
        //Firebase
        final db = DatabaseService(uid);
        await db.updateDataOfValue("appointments", appointments);
        await AppointmentService().addAppointment(appointment);
      } else {
        //Recuperation de la list des treatments sur firebase
        String code = request.treatCode!;

        Treat treat = await TreatmentService().getTreatmentByCode(code);

        List<Medicine> ms = [];

        Treat t = Treat(
          authorName: treat.authorName,
          authorUid: treat.authorName,
          code: treat.code,
          title: treat.title,
          medicines: ms,
          createdAt: DateTime.now(),
          isPublic: treat.isPublic,
          followers: [],
        );

        for (Medicine m in treat.medicines) {
          t.addMedicineWithoutSave(m);
        }
        managersTreats.addTreatment(t);
      }

      requests.remove(request.id);
      //Firebase
      final db = DatabaseService(uid);
      await db.updateDataOfValue("requests", requests);
      await RequestService().deleteRequest(request.id);
    } else {
      request.updateStatus(newStatus);
      //Firebase
      await RequestService().updateRequest(request);
    }
  }
}

class Doctor {
  final String id;
  final String imageUrl;
  final String name;
  final String specialty;
  final String experience;
  final String phoneNumber;
  final String email;
  final String address;
  final double rating;
  final List<String> availableDays;
  final List<String> availableHours;
  final String bio;
  final List<String> languages;
  final String gender;
  final String licenseNumber;
  final String hospital;

  Doctor({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.rating,
    required this.availableDays,
    required this.availableHours,
    required this.bio,
    required this.languages,
    required this.gender,
    required this.licenseNumber,
    required this.hospital,
  });

  List<String> weekdays = [
    '',
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  bool isAvailable() {
    DateTime now = DateTime.now();

    String today = weekdays[now.weekday];
    return availableDays.contains(today);
  }

  List<DateTime> getAvailableDates() {
    final now = DateTime.now();
    List<DateTime> dates = [];

    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final dayName = weekdays[date.weekday];
      if (availableDays.contains(dayName)) {
        dates.add(date);
        if (dates.length >= 14) break;
      }
    }

    return dates;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'specialty': specialty,
      'experience': experience,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'rating': rating,
      'availableDays': availableDays,
      'availableHours': availableHours,
      'bio': bio,
      'languages': languages,
      'gender': gender,
      'licenseNumber': licenseNumber,
      'hospital': hospital,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      imageUrl: map['imageUrl'],
      name: map['name'],
      specialty: map['specialty'],
      experience: map['experience'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      address: map['address'],
      rating: (map['rating'] ?? 0).toDouble(),
      availableDays: List<String>.from(map['availableDays']),
      availableHours: List<String>.from(map['availableHours']),
      bio: map['bio'],
      languages: List<String>.from(map['languages']),
      gender: map['gender'],
      licenseNumber: map['licenseNumber'],
      hospital: map['hospital'],
    );
  }
}

class Appointment {
  final String id;
  final String doctorUid;
  final String patientUid;
  final DateTime startTime;

  Appointment({
    required this.doctorUid,
    required this.patientUid,
    required this.startTime,
  }) : id = generateAppointmentId(
         doctorUid: doctorUid,
         patientUid: patientUid,
         startTime: startTime,
       );

  static String generateAppointmentId({
    required String doctorUid,
    required String patientUid,
    required DateTime startTime,
  }) {
    return "${doctorUid}_${patientUid}_${startTime.toIso8601String()}";
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorUid': doctorUid,
      'patientUid': patientUid,
      'startTime': startTime.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      doctorUid: map['doctorUid'],
      patientUid: map['patientUid'],
      startTime: DateTime.parse(map['startTime']),
    );
  }

  String get formattedDate {
    return DateFormat('EEE, d MMM yyyy').format(startTime);
  }

  String get formattedTime {
    String start = DateFormat('hh:mm a').format(startTime);
    return start;
  }

  static String formattedDateStatic(startTime) {
    return DateFormat('EEE, d MMM yyyy').format(startTime);
  }

  static String formattedTimeStatic(startTime) {
    String start = DateFormat('hh:mm a').format(startTime);
    return start;
  }
}

class Request {
  final String id;
  final RequestType requestType;
  RequestStatus status;
  final String doctorUid;
  final String patientUid;
  final String? treatCode;
  final String? appointmentReason;
  final DateTime? startTime;
  final SenderType senderType;
  final DateTime createdAt;

  Request({
    required this.requestType,
    required this.status,
    required this.doctorUid,
    required this.patientUid,
    this.treatCode,
    this.startTime,
    this.appointmentReason,
    required this.senderType,
  }) : createdAt = DateTime.now(),
       id =
           (() {
             final now = DateTime.now();
             return generateRequestId(
               requestType: requestType,
               status: status,
               doctorUid: doctorUid,
               patientUid: patientUid,
               senderType: senderType,
               createdAt: now,
             );
           })();

  Request._({
    required this.id,
    required this.requestType,
    required this.status,
    required this.doctorUid,
    required this.patientUid,
    this.treatCode,
    this.startTime,
    this.appointmentReason,
    required this.senderType,
    required this.createdAt,
  });

  static String generateRequestId({
    required RequestType requestType,
    required RequestStatus status,
    required String doctorUid,
    required String patientUid,
    required SenderType senderType,
    required DateTime createdAt,
  }) {
    return "${requestType.name}_${doctorUid}_${patientUid}_${senderType.name}_${createdAt.toIso8601String()}";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestType': requestType.name,
      'status': status.name,
      'doctorUid': doctorUid,
      'patientUid': patientUid,
      'treatCode': treatCode,
      'appointmentReason': appointmentReason,
      'startTime': startTime?.toIso8601String(),
      'senderType': senderType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Request.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.parse(map['createdAt']);
    final requestType = RequestType.values.firstWhere(
      (e) => e.name == map['requestType'],
    );
    final status = RequestStatus.values.firstWhere(
      (e) => e.name == map['status'],
    );
    final senderType = SenderType.values.firstWhere(
      (e) => e.name == map['senderType'],
    );

    final id = generateRequestId(
      requestType: requestType,
      status: status,
      doctorUid: map['doctorUid'],
      patientUid: map['patientUid'],
      senderType: senderType,
      createdAt: createdAt,
    );

    return Request._(
      id: id,
      requestType: requestType,
      status: status,
      doctorUid: map['doctorUid'],
      patientUid: map['patientUid'],
      treatCode: map['treatCode'] is String ? map['treatCode'] : null,
      appointmentReason:
          map['appointmentReason'] is String ? map['appointmentReason'] : null,
      startTime:
          map['startTime'] is String
              ? DateTime.tryParse(map['startTime'])
              : null,
      senderType: senderType,
      createdAt: createdAt,
    );
  }

  void updateStatus(RequestStatus newStatus) {
    status = newStatus;
  }

  Future<Appointment> getAppointment() {
    // String id =
    //     "appointment_${doctorUid}_${patientUid}_${createdAt.toIso8601String()}";
    return AppointmentService().getAppointment(id);
  }
}

enum RequestType { doctor, appointment, treat }

enum RequestStatus { pending, agreed, disagreed }

enum SenderType { doctor, patient }
