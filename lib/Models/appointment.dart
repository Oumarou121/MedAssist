import 'package:med_assist/Models/doctor.dart';
import 'package:intl/intl.dart';

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
