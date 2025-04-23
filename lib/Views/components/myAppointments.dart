import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_assist/Controllers/databaseDoctors.dart';
import 'package:med_assist/Models/doctor.dart';

class MyAppointmentsList extends StatefulWidget {
  final ManagersDoctors managersDoctors;

  const MyAppointmentsList({
    super.key,
    required this.managersDoctors,
  });

  @override
  State<MyAppointmentsList> createState() => _MyAppointmentsListState();
}

class _MyAppointmentsListState extends State<MyAppointmentsList> {
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    appointments = await widget.managersDoctors.getAppointments();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              'today_appointment'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildAppointmentsList(context),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(BuildContext context) {
    final todayAppointments = _getTodayAppointments(appointments);

    if (todayAppointments.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: todayAppointments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder:
            (context, index) =>
                _AppointmentCard(appointment: todayAppointments[index]),
      ),
    );
  }

  List<Appointment> _getTodayAppointments(List<Appointment> appointments) {
    final now = DateTime.now();
    return appointments
        .where(
          (a) =>
              a.startTime.year == now.year &&
              a.startTime.month == now.month &&
              a.startTime.day == now.day,
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 40, color: Colors.blueGrey[200]),
            const SizedBox(height: 8),
            Text(
              'no_today_appointment'.tr(),
              style: GoogleFonts.poppins(
                color: Colors.blueGrey[300],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Doctor?>(
      future: DoctorService().getDoctorById(appointment.doctorUid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final doctor = snapshot.data!;

        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Time Section
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(appointment.startTime),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        doctor.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialty,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blueGrey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.blueGrey[300],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              doctor.hospital,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.blueGrey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[100]!),
                        ),
                        child: Text(
                          'confirmed'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Doctor Image
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(doctor.imageUrl),
                    backgroundColor: Colors.blue[50],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
