import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MyAppointmentsList extends StatelessWidget {
  final List<Appointment> appointments;
  final PageController _pageController = PageController();

  MyAppointmentsList({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Appointments",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: PageView(
            controller: _pageController,
            children:
                appointments
                    .map((data) => AppointmentCard(appointment: data))
                    .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: SmoothPageIndicator(
            controller: _pageController,
            count: appointments.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Colors.green.shade700,
              dotColor: Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(appointment.doctor.imageUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctor.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      softWrap: true,
                    ),
                    Text(
                      appointment.doctor.specialty,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar, color: Colors.white, size: 20),
                const SizedBox(width: 5),
                Text(
                  appointment.formattedDate,
                  style: GoogleFonts.poppins(color: Colors.white),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
                const SizedBox(width: 15),
                const Icon(Iconsax.clock, color: Colors.white, size: 20),
                const SizedBox(width: 5),
                Text(
                  appointment.formattedTime,
                  style: GoogleFonts.poppins(color: Colors.white),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
