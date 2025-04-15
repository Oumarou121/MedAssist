import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/Models/doctor.dart';

class AppointmentsView extends StatelessWidget {
  final List<Appointment> appointments;

  const AppointmentsView({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final allAppointments = appointments.toList();

    if (allAppointments.isEmpty) {
      return Center(
        child: Text(
          'Aucun rendez-vous disponible.',
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allAppointments.length,
      itemBuilder: (context, index) {
        final appointment = allAppointments[index];
        return _buildAppointmentItem(appointment: appointment);
      },
    );
  }
}

class DailyAppointmentsView extends StatelessWidget {
  final List<Appointment> appointments;

  const DailyAppointmentsView({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayAppointments =
        appointments
            .where(
              (a) =>
                  a.startTime.year == now.year &&
                  a.startTime.month == now.month &&
                  a.startTime.day == now.day,
            )
            .toList();

    if (todayAppointments.isEmpty) {
      return Center(
        child: Text(
          'Aucun rendez-vous prévu pour aujourd\'hui.',
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todayAppointments.length,
      itemBuilder: (context, index) {
        final appointment = todayAppointments[index];
        return _buildAppointmentItem(appointment: appointment);
      },
    );
  }
}

Widget _buildAppointmentItem({required Appointment appointment}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 60,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(appointment.startTime),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              DateFormat('HH:mm').format(appointment.endTime),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
      title: Text(
        appointment.doctor.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        appointment.doctor.specialty,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            appointment.formattedDate,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            appointment.doctor.hospital,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    ),
  );
}

// String _formatDate(DateTime date) {
//   final days = [
//     'Lundi',
//     'Mardi',
//     'Mercredi',
//     'Jeudi',
//     'Vendredi',
//     'Samedi',
//     'Dimanche',
//   ];
//   final months = [
//     'Janvier',
//     'Février',
//     'Mars',
//     'Avril',
//     'Mai',
//     'Juin',
//     'Juillet',
//     'Août',
//     'Septembre',
//     'Octobre',
//     'Novembre',
//     'Décembre',
//   ];

//   final dayName = days[date.weekday - 1];
//   final monthName = months[date.month - 1];
//   return '$dayName ${date.day} $monthName ${date.year}';
// }
