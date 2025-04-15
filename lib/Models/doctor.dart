import 'package:intl/intl.dart';

class ManagersDoctors {
  final String uid;
  final String name;
  final List<Doctor> doctors;
  final List<Request> requests;
  final List<Appointment> appointments;

  ManagersDoctors({
    required this.uid,
    required this.name,
    required this.doctors,
    required this.requests,
    required this.appointments,
  });

  Future<String> checkSendJoinDoctorRequest(String doctorID) async {
    //Recuperation de la liste des doctors sur Firebase
    List<Doctor> docs = [];

    bool exists = docs.any((doc) => doc.id == doctorID);
    if (!exists) return "This Doctor ID is invalid";

    bool alreadyExists = doctors.any((doc) => doc.id == doctorID);
    if (alreadyExists) return "This Doctor is already exist";

    bool alreadyRequest = requests.any(
      (req) =>
          req.doctor!.id == doctorID &&
          req.requestType == RequestType.doctor &&
          req.agreed == RequestStatus.pending,
    );
    if (alreadyRequest) {
      return "You already send a request please wait until the doctor give a answer";
    }

    return "Success";
  }

  Future<void> sendJoinDoctorRequest(String doctorID) async {
    //Recuperation de la liste des doctors sur Firebase
    List<Doctor> docs = [];
    Doctor doctor = docs.firstWhere((doc) => doc.id == doctorID);
    Request request = Request(
      id: requests.length,
      requestType: RequestType.doctor,
      doctor: doctor,
      isFromMe: true,
      agreed: RequestStatus.pending,
    );
    requests.add(request);
    //Firebase
  }

  Future<String> checkSendAppointRequest(
    Doctor doctor,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final alreadyRequested = requests.any(
      (req) =>
          req.appointment?.doctor.id == doctor.id &&
          req.requestType == RequestType.appointment &&
          req.agreed == RequestStatus.pending,
    );

    if (alreadyRequested) {
      return "Vous avez déjà envoyé une demande. Veuillez attendre la réponse du docteur.";
    }

    return "Success";
  }

  Future<void> sendAppointRequest(
    Doctor doctor,
    DateTime startTime,
    DateTime endTime,
    String reason,
  ) async {
    Request request = Request(
      id: requests.length,
      requestType: RequestType.appointment,
      appointment: Appointment(
        doctor: doctor,
        startTime: startTime,
        endTime: endTime,
      ),
      appointmentReason: reason,
      isFromMe: true,
      agreed: RequestStatus.pending,
    );
    requests.add(request);
    //Firebase
  }

  Future<void> removeRequest(Request request) async {
    requests.remove(request);
    print(requests.length);
    //Firebase
  }

  Future<void> updateRequestStatus(
    Request request,
    RequestStatus newStatus,
  ) async {
    if (newStatus == RequestStatus.agreed) {
      if (request.requestType == RequestType.doctor) {
        final doctor = request.doctor;
        if (doctor != null) {
          doctors.add(doctor);
        }
      } else {
        final appointment = request.appointment;
        if (appointment != null) {
          appointments.add(appointment);
        }
      }

      await removeRequest(request);
    } else {
      request.updateStatus(newStatus);
    }

    //Firebase
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
}

class Appointment {
  final Doctor doctor;
  final DateTime startTime;
  final DateTime endTime;

  Appointment({
    required this.doctor,
    required this.startTime,
    required this.endTime,
  });

  String get formattedDate {
    return DateFormat('EEE, d MMM yyyy').format(startTime);
  }

  String get formattedTime {
    String start = DateFormat('hh:mm a').format(startTime);
    String end = DateFormat('hh:mm a').format(endTime);
    return "$start - $end";
  }
}

class Request {
  final int id;
  final RequestType requestType;
  final Doctor? doctor;
  final Appointment? appointment;
  final String? appointmentReason;
  RequestStatus agreed;
  final bool isFromMe;

  Request({
    required this.id,
    required this.requestType,
    this.doctor,
    this.appointment,
    this.appointmentReason,
    required this.isFromMe,
    required this.agreed,
  });

  Doctor? getDoctor() {
    if (doctor != null && doctor!.name.isNotEmpty) {
      return doctor;
    } else if (appointment != null) {
      return appointment!.doctor;
    }
    return null;
  }

  void updateStatus(RequestStatus status) {
    agreed = status;
  }
}

enum RequestType { doctor, appointment }

enum RequestStatus { pending, agreed, disagreed }
