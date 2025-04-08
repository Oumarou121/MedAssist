import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/appointment.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/treat.dart';
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

  late final ManagersTreats _managersTreats;

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

    _managersTreats = ManagersTreats(
      uid: 'user_uid',
      name: widget.userData.name,
      treats: [
        // Cas 1 : Médicament quotidien, 3 prises par jour, durée 2 jours
        Treat(
          authorUid: 'user1',
          authorName: 'Dr. Jean',
          code: 'T001',
          title: 'Traitement CO2 quotidien',
          createdAt: DateTime.now(),
          medicines: [
            Medicine(
              name: 'CO2',
              dose: '1g',
              frequency: 3,
              intervale: 3,
              duration: 7,
              frequencyType: FrequencyType.daily,
              createAt: DateTime.now(),
            ),
          ],
        ),

        // Cas 2 : Médicament hebdomadaire, 2 prises par jour, durée 10 jours
        Treat(
          authorUid: 'user2',
          authorName: 'Dr. Alice',
          code: 'T002',
          title: 'Vitamine hebdomadaire',
          createdAt: DateTime(2025, 4, 7, 10, 0),
          medicines: [
            Medicine(
              name: 'Vitamine C',
              dose: '500mg',
              frequency: 2,
              intervale: 8,
              duration: 10,
              frequencyType: FrequencyType.weekly,
              createAt: DateTime(2025, 4, 7, 10, 0),
            ),
          ],
        ),

        // Cas 3 : Médicament bihebdomadaire, 1 prise par jour, durée 30 jours
        Treat(
          authorUid: 'user3',
          authorName: 'Dr. Karim',
          code: 'T003',
          title: 'Antibiotique long terme',
          createdAt: DateTime(2025, 4, 1),
          medicines: [
            Medicine(
              name: 'Antibiotique',
              dose: '250mg',
              frequency: 1,
              intervale: 24,
              duration: 30,
              frequencyType: FrequencyType.biweekly,
              createAt: DateTime(2025, 4, 1, 7, 0),
            ),
          ],
        ),

        // Cas 4 : Médicament mensuel, 1 prise, durée 60 jours
        Treat(
          authorUid: 'user4',
          authorName: 'Dr. Leïla',
          code: 'T004',
          title: 'Injection mensuelle B12',
          createdAt: DateTime(2025, 4, 1),
          medicines: [
            Medicine(
              name: 'Injection B12',
              dose: '1ml',
              frequency: 1,
              intervale: 24,
              duration: 60,
              frequencyType: FrequencyType.monthly,
              createAt: DateTime(2025, 4, 1, 9, 0),
            ),
          ],
        ),

        // Cas 5 : Médicament trimestriel, 1 prise, durée 100 jours
        Treat(
          authorUid: 'user5',
          authorName: 'Dr. Nadir',
          code: 'T005',
          title: 'Vaccination préventive',
          createdAt: DateTime(2025, 3, 20),
          medicines: [
            Medicine(
              name: 'Vaccin',
              dose: '5ml',
              frequency: 1,
              intervale: 24,
              duration: 100,
              frequencyType: FrequencyType.quarterly,
              createAt: DateTime(2025, 3, 20, 14, 0),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final schedule = _managersTreats.generateSchedule();

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
                  // MedicationList(medications: _medication),
                  _treatmentSchedule(schedule),
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

  Widget _treatmentSchedule(ManagersSchedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          schedule.schedules.map((scheduleItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date d'affichage
                      Text(
                        'Date: ${_formatDate(scheduleItem.date)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                      // Médicaments et horaires associés
                      ...scheduleItem.scheduleItems.map((item) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.name} - ${item.dose}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            ...item.times.map((time) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  'À: $time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              );
                            }).toList(),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
