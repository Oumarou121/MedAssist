import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/appointment.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/components/myMedications.dart';
import 'package:med_assist/Views/components/myAppointments.dart';
import 'package:med_assist/Views/components/myDoctors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userData});
  final AppUserData userData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Doctor> _doctors = [
    Doctor(
      imageUrl:
          "https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMzQwLXBhaTI1MzAuanBn.jpg",
      name: "Dr. Warner",
      specialty: "Neurology",
      experience: "5 years experience",
    ),
    Doctor(
      imageUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuuglfNWvcq31xl6m59EILUlrc8vmav-d3UQ&s",
      name: "Dr. Patel",
      specialty: "Cardiology",
      experience: "10 years experience",
    ),
    Doctor(
      imageUrl:
          "https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMzQwLXBhaTI1MzAuanBn.jpg",
      name: "Dr. Warner",
      specialty: "Neurology",
      experience: "5 years experience",
    ),
    Doctor(
      imageUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuuglfNWvcq31xl6m59EILUlrc8vmav-d3UQ&s",
      name: "Dr. Patel",
      specialty: "Cardiology",
      experience: "10 years experience",
    ),
  ];

  late final List<Appointment> _appointments;

  final List<Medication> _medication = [
    Medication(name: "Paracétamol", time: "08:00 AM"),
    Medication(name: "Ibuprofène", time: "12:00 PM"),
    Medication(name: "Vitamine C", time: "06:00 PM"),
  ];

  @override
  void initState() {
    super.initState();
    _appointments = [
      Appointment(
        doctor: _doctors[0],
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ),
      Appointment(
        doctor: _doctors[1],
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ),
      Appointment(
        doctor: _doctors[2],
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ),
      Appointment(
        doctor: _doctors[3],
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding + 60),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _top(userData: widget.userData),
                  SizedBox(height: size.height * 0.03),
                  _searchBar(),
                  SizedBox(height: size.height * 0.03),
                  MedicationList(medications: _medication),
                  SizedBox(height: size.height * 0.03),
                  MyAppointmentsList(appointments: _appointments),
                  SizedBox(height: size.height * 0.03),
                  MyDoctorsList(doctors: _doctors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _top({required AppUserData userData}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Hello,",
              style: GoogleFonts.poppins(fontSize: 24, color: Colors.black),
            ),
            Text(
              "${userData.name}!",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.notification, color: Colors.black),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    "https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMzQwLXBhaTI1MzAuanBn.jpg",
                  ),
                  radius: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (text) {},
      decoration: InputDecoration(
        hintText: 'Search for a doctor or specialty',
        prefixIcon: Icon(Iconsax.search_normal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}
