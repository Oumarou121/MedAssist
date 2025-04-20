import 'package:med_assist/Models/treat.dart';

class AppUser {
  final String uid;

  AppUser(this.uid);
}

class AppUserData {
  final String uid;
  final String name;
  final String password;
  final String phoneNumber;
  final String pinCode;
  final List<Treat> treatments;
  final List<String> doctors;
  final List<String> appointments;
  final List<String> requests;
  final List<String> medicalRecords;
  final String profileUrl;

  AppUserData({
    required this.uid,
    required this.name,
    required this.password,
    required this.phoneNumber,
    required this.pinCode,
    required this.treatments,
    required this.doctors,
    required this.appointments,
    required this.requests,
    required this.medicalRecords,
    required this.profileUrl,
  });
}
