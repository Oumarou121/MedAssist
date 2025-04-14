import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Models/MedicationSchedule.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/components/myAppointments.dart';
import 'package:med_assist/Views/components/myDoctors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Doctor> doctors = [
    Doctor(
      id: 'doc1',
      imageUrl: 'https://i.pravatar.cc/150?img=3',
      name: 'Dr. Sophie Durand',
      specialty: 'Cardiologue',
      experience: '10 ans',
      phoneNumber: '0600000001',
      email: 'sophie.durand@mail.com',
      address: 'Clinique du Coeur, Paris',
      rating: 4.8,
      availableDays: ['Lundi', 'Mercredi', 'Vendredi'],
      availableHours: ['09:00', '14:00'],
      bio: 'Spécialiste des maladies cardiovasculaires.',
      languages: ['Français', 'Anglais'],
      gender: 'Femme',
      licenseNumber: 'CD123456',
      hospital: 'Clinique du Coeur',
    ),
    Doctor(
      id: 'doc2',
      imageUrl: 'https://i.pravatar.cc/150?img=5',
      name: 'Dr. Marc Lefevre',
      specialty: 'Dermatologue',
      experience: '7 ans',
      phoneNumber: '0600000002',
      email: 'marc.lefevre@mail.com',
      address: 'Hôpital Saint-Louis, Paris',
      rating: 4.6,
      availableDays: ['Mardi', 'Jeudi'],
      availableHours: ['10:00', '16:00'],
      bio: 'Expert en maladies de la peau.',
      languages: ['Français', 'Espagnol'],
      gender: 'Homme',
      licenseNumber: 'DL654321',
      hospital: 'Hôpital Saint-Louis',
    ),
    Doctor(
      id: 'doc3',
      imageUrl: 'https://i.pravatar.cc/150?img=8',
      name: 'Dr. Amélie Martin',
      specialty: 'Pédiatre',
      experience: '12 ans',
      phoneNumber: '0600000003',
      email: 'amelie.martin@mail.com',
      address: 'Centre Médical Enfants Santé, Lyon',
      rating: 4.9,
      availableDays: ['Lundi', 'Mardi', 'Jeudi'],
      availableHours: ['08:30', '13:30'],
      bio: 'Pédiatre passionnée par le bien-être des enfants.',
      languages: ['Français', 'Anglais'],
      gender: 'Femme',
      licenseNumber: 'PD456789',
      hospital: 'Centre Médical Enfants Santé',
    ),
  ];

  late List<Appointment> appointments;

  @override
  void initState() {
    super.initState();
    appointments = [
      Appointment(
        doctor: doctors[0],
        startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      ),
      Appointment(
        doctor: doctors[1],
        startTime: DateTime.now().add(const Duration(days: 2, hours: 14)),
        endTime: DateTime.now().add(const Duration(days: 2, hours: 15)),
      ),
      Appointment(
        doctor: doctors[2],
        startTime: DateTime.now().add(const Duration(days: 3, hours: 8)),
        endTime: DateTime.now().add(const Duration(days: 3, hours: 9)),
      ),
      Appointment(
        doctor: doctors[0],
        startTime: DateTime.now().add(const Duration(days: 5, hours: 11)),
        endTime: DateTime.now().add(const Duration(days: 5, hours: 12)),
      ),
    ];

    listenNotification();
  }

  listenNotification() {
    print("Listening to nootification");
    // NotiService.onClickNotification.stream.listen((event) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => AnotherPage(payload: event)),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    final user = Provider.of<AppUser?>(context);
    if (user == null) return const LoginScreen();
    final database = DatabaseService(user.uid);

    return StreamBuilder<AppUserData>(
      stream: database.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          AppUserData? userData = snapshot.data;
          if (userData == null) return const LoginScreen();
          ManagersTreats managersTreats = ManagersTreats(
            uid: userData.uid,
            name: userData.name,
            treats: userData.treatments,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding + 60),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _top(userData: userData),
                        SizedBox(height: size.height * 0.03),
                        _searchBar(),
                        SizedBox(height: size.height * 0.03),
                        MedicationScheduleList(managersTreats: managersTreats),
                        SizedBox(height: size.height * 0.03),
                        MyAppointmentsList(appointments: appointments),
                        SizedBox(height: size.height * 0.03),
                        MyDoctorsList(doctors: doctors),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const LoginScreen();
      },
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
