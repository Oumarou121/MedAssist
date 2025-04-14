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

  Future<String> sendJoinDoctorRequest(String doctorID) async {
    //Recuperation de la liste des doctors sur Firebase
    List<Doctor> docs = [];

    bool exists = docs.any((doc) => doc.id == doctorID);
    if (!exists) return "This Doctor ID is invalid";

    bool alreadyExists = doctors.any((doc) => doc.id == doctorID);
    if (alreadyExists) return "This Doctor is already exist";

    bool alreadyRequest = requests.any(
      (req) =>
          req.doctorID == doctorID &&
          req.requestType == RequestType.doctor &&
          req.agreed == RequestStatus.pending,
    );
    if (alreadyRequest) {
      return "You already send a request please wait until the doctor give a answer";
    }

    Request request = Request(
      requestType: RequestType.doctor,
      doctorID: doctorID,
      isFromMe: true,
      agreed: RequestStatus.pending,
    );
    requests.add(request);
    //Firebase
    return "Success";
  }

  void sendAppointRequest(
    Doctor doctor,
    DateTime startTime,
    DateTime endTime,
  ) {}
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
  final RequestType requestType;
  final String? doctorID;
  final DateTime? startTime;
  final DateTime? endTime;
  final RequestStatus agreed;
  final bool isFromMe;

  Request({
    required this.requestType,
    this.doctorID,
    this.startTime,
    this.endTime,
    required this.isFromMe,
    required this.agreed,
  });
}

enum RequestType { doctor, appointment }

enum RequestStatus { pending, agreed, disagreed }
