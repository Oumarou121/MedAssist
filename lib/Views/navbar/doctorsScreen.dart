import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:provider/provider.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final List<String> frenchWeekdaysShort = [
    '',
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];

  List<Doctor> doctors = [
    Doctor(
      id: 'doc1',
      imageUrl:
          "https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMzQwLXBhaTI1MzAuanBn.jpg",
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
      imageUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuuglfNWvcq31xl6m59EILUlrc8vmav-d3UQ&s",
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
      imageUrl:
          "https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvMzQwLXBhaTI1MzAuanBn.jpg",
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
  }

  @override
  Widget build(BuildContext context) {
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
          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding + 60),
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F7FB),
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 80,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'My Doctors & Appointments',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFFB2FF59)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            'My Doctors',
                            Iconsax.profile_2user5,
                            true,
                          ),
                          _buildDoctorsList(),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            'My Appointments',
                            Iconsax.calendar_25,
                            false,
                          ),
                          _buildAppointmentsList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const LoginScreen();
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDoc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00C853), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                isDoc
                    ? Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _showJoinDoctorModal();
                        },
                        icon: Icon(Iconsax.add, color: Colors.black),
                      ),
                    )
                    : TextButton(
                      onPressed: () {},
                      child: Text(
                        "Show History",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return GestureDetector(
      onTap: () => _showDoctorInfosModal(doctor: doctor),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    doctor.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (doctor.isAvailable())
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Disponible',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialty,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.star1,
                        color: Colors.amber.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${doctor.rating}',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const Spacer(),
                      Icon(
                        Iconsax.video,
                        color: Colors.blue.shade400,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorInfosModal({required Doctor doctor}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxModalHeight = screenHeight * .95;
        return Container(
          constraints: BoxConstraints(maxHeight: maxModalHeight),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F7FB), Colors.white],
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(doctor.imageUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            doctor.specialty,
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Iconsax.star1,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${doctor.rating}',
                                style: GoogleFonts.poppins(),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      doctor.isAvailable()
                                          ? Colors.green.shade100
                                          : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color:
                                            doctor.isAvailable()
                                                ? Colors.green
                                                : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      doctor.isAvailable()
                                          ? 'Disponible'
                                          : 'Non Disponible',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (doctor.isAvailable()) const SizedBox(height: 10),
                          if (doctor.isAvailable())
                            ElevatedButton.icon(
                              onPressed: () {
                                showDoctorAppointmentModal(
                                  context: context,
                                  doctor: doctor,
                                  onConfirm: (
                                    DateTime date,
                                    TimeOfDay time,
                                    String reason,
                                  ) {
                                    print(
                                      'Rendez-vous confirmé le $date à $time - Motif: $reason',
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Iconsax.calendar_add, size: 16),
                              label: Text(
                                "Reservation Now",
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section Contact
                _buildInfoSection(
                  icon: Iconsax.profile_2user,
                  title: 'Informations professionnelles',
                  children: [
                    _buildInfoRow('Hôpital', doctor.hospital),
                    _buildInfoRow('Années d\'expérience', doctor.experience),
                    _buildInfoRow('N° Licence', doctor.licenseNumber),
                  ],
                ),

                // Section Coordonnées
                _buildInfoSection(
                  icon: Iconsax.location,
                  title: 'Coordonnées',
                  children: [
                    _buildInfoRow('Adresse', doctor.address),
                    _buildInfoRow('Téléphone', doctor.phoneNumber),
                    _buildInfoRow('Email', doctor.email),
                  ],
                ),

                // Section Disponibilités
                //Ajouter le btn demande de rendez-vous (si dispo)
                _buildInfoSection(
                  icon: Iconsax.calendar,
                  title: 'Disponibilités',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jours :',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.availableDays.join(', '),
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Heures :',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children:
                                  doctor.availableHours
                                      .map(
                                        (h) => Chip(
                                          label: Text(h),
                                          backgroundColor: Color(
                                            0xFF3366FF,
                                          ).withOpacity(0.1),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // Section Bio
                _buildInfoSection(
                  icon: Iconsax.info_circle,
                  title: 'À propos',
                  children: [
                    Text(
                      doctor.bio,
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                  ],
                ),

                // Section Langues
                if (doctor.languages.isNotEmpty)
                  _buildInfoSection(
                    icon: Iconsax.language_square,
                    title: 'Langues parlées',
                    children: [
                      Wrap(
                        spacing: 8,
                        children:
                            doctor.languages
                                .map(
                                  (lang) => Chip(
                                    label: Text(lang),
                                    backgroundColor: Color(
                                      0xFF00CCFF,
                                    ).withOpacity(0.1),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF00C853), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Column(
      children: appointments.map((rdv) => _buildAppointmentCard(rdv)).toList(),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(appointment.doctor.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          appointment.doctor.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${appointment.formattedDate} • ${appointment.formattedTime}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            Text(
              appointment.doctor.hospital,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3366FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Confirmé',
            style: GoogleFonts.poppins(
              color: const Color(0xFF3366FF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // void _showDoctorsOptionsModal({required AppUserData userData}) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     backgroundColor: Colors.white,
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(context).viewInsets.bottom + 75,
  //           left: 20,
  //           right: 20,
  //           top: 20,
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               "Options de traitement",
  //               style: GoogleFonts.poppins(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 10),

  //             // Ajouter un nouveau médecin
  //             ListTile(
  //               leading: const Icon(
  //                 Icons.medical_services_outlined,
  //                 color: Colors.blue,
  //               ),
  //               title: Text(
  //                 "Ajouter un nouveau docteur",
  //                 style: GoogleFonts.poppins(),
  //               ),
  //               onTap: () {
  //                 Navigator.pop(context);
  //               },
  //             ),

  //             // Prendre un rendez-vous
  //             ListTile(
  //               leading: const Icon(Icons.calendar_today, color: Colors.green),
  //               title: Text(
  //                 "Prendre rendez-vous",
  //                 style: GoogleFonts.poppins(),
  //               ),
  //               onTap: () {
  //                 Navigator.pop(context);
  //               },
  //             ),

  //             // Consulter le planning
  //             ListTile(
  //               leading: const Icon(Icons.schedule, color: Colors.purple),
  //               title: Text(
  //                 "Planning des rendez-vous",
  //                 style: GoogleFonts.poppins(),
  //               ),
  //               onTap: () {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void showDoctorAppointmentModal({
    required BuildContext context,
    required Doctor doctor,
    required Function(DateTime, TimeOfDay, String) onConfirm,
  }) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    String appointmentReason = '';
    List<DateTime> availableDates = doctor.getAvailableDates();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5F7FB), Colors.white],
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 75,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(doctor.imageUrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                doctor.specialty,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sélection de date
                    _buildSectionTitle(
                      icon: Iconsax.calendar,
                      title: 'Choisir une date',
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableDates.length,
                        itemBuilder: (context, index) {
                          final date = availableDates[index];
                          final isSelected =
                              date.day == selectedDate.day &&
                              date.month == selectedDate.month;

                          return GestureDetector(
                            onTap: () => setState(() => selectedDate = date),
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Color(0xFF00C853).withOpacity(0.1)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Color(0xFF00C853)
                                          : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    frenchWeekdaysShort[date.weekday],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isSelected
                                              ? Color(0xFF00C853)
                                              : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    date.day.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? Color(0xFF00C853)
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sélection d'horaire
                    _buildSectionTitle(
                      icon: Iconsax.clock,
                      title: 'Choisir un horaire',
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: doctor.availableHours.length,
                      itemBuilder: (context, index) {
                        final time = doctor.availableHours[index];
                        final isSelected =
                            time ==
                            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                        return GestureDetector(
                          onTap: () {
                            final parts = time.split(':');
                            setState(() {
                              selectedTime = TimeOfDay(
                                hour: int.parse(parts[0]),
                                minute: int.parse(parts[1]),
                              );
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Color(0xFF00C853).withOpacity(0.1)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Color(0xFF00C853)
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                time,
                                style: GoogleFonts.poppins(
                                  color:
                                      isSelected
                                          ? Color(0xFF00C853)
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Raison du rendez-vous
                    _buildSectionTitle(
                      icon: Iconsax.note,
                      title: 'Motif du rendez-vous',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) => appointmentReason = value,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Décrivez la raison de votre visite...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        // style: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bouton de confirmation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Iconsax.calendar_add,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Confirmer le rendez-vous',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          final appointmentDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          onConfirm(
                            appointmentDateTime,
                            selectedTime,
                            appointmentReason,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF00C853)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showJoinDoctorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController();
        String error1 = "";
        bool isError1 = false;

        return StatefulBuilder(
          builder: (BuildContext contextParent, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(contextParent).viewInsets.bottom + 75,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Titre
                  Text(
                    "Send a request",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Champ de code
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "Doctor ID",
                      prefixIcon: Icon(
                        Iconsax.code,
                        color: Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      errorText: isError1 ? error1 : null,
                      errorStyle: GoogleFonts.poppins(color: Colors.red),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    style: GoogleFonts.poppins(),
                  ),

                  const SizedBox(height: 16),

                  // Bouton Rejoindre
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Iconsax.link, size: 20, color: Colors.white),
                      label: Text(
                        "Send",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        String code = _controller.text.trim();
                        if (code.isEmpty) {
                          setModalState(() {
                            error1 = "Please enter a Doctor ID.";
                            isError1 = true;
                          });
                          return;
                        }

                        // // TODO: vérifie l'existence du code / traitement
                        // // setModalState pour update l'erreur si non trouvé
                        // bool exists = defaultTreatments.any(
                        //   (treat) => treat.code == code,
                        // );

                        // if (!exists) {
                        //   setModalState(() {
                        //     error1 = "Traitement non trouvé";
                        //     isError1 = true;
                        //   });
                        //   return;
                        // }

                        // Treat treatment = defaultTreatments.firstWhere(
                        //   (treat) => treat.code == code,
                        // );

                        // bool alreadyExists = managersTreats.alreadyExists(code);

                        // if (alreadyExists) {
                        //   setModalState(() {
                        //     error1 = "Ce traitement existe déjà";
                        //     isError1 = true;
                        //   });
                        //   return;
                        // }

                        // showDialog(
                        //   context: context,
                        //   builder:
                        //       (context) => Dialog(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(20),
                        //         ),
                        //         child: Container(
                        //           padding: const EdgeInsets.all(24),
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(20),
                        //             gradient: LinearGradient(
                        //               begin: Alignment.topCenter,
                        //               end: Alignment.bottomCenter,
                        //               colors: [Color(0xFFF5F7FB), Colors.white],
                        //             ),
                        //           ),
                        //           child: Column(
                        //             mainAxisSize: MainAxisSize.min,
                        //             children: [
                        //               const Icon(
                        //                 Iconsax.info_circle,
                        //                 size: 40,
                        //                 color: Color(0xFF3366FF),
                        //               ),
                        //               const SizedBox(height: 16),
                        //               Text(
                        //                 "Confirmer l'ajout",
                        //                 style: GoogleFonts.poppins(
                        //                   fontSize: 18,
                        //                   fontWeight: FontWeight.w600,
                        //                 ),
                        //               ),
                        //               const SizedBox(height: 8),
                        //               Text(
                        //                 "Ajouter le traitement\n${treatment.title} ?",
                        //                 textAlign: TextAlign.center,
                        //                 style: GoogleFonts.poppins(),
                        //               ),
                        //               const SizedBox(height: 24),
                        //               Row(
                        //                 children: [
                        //                   Expanded(
                        //                     child: TextButton(
                        //                       child: const Text("Annuler"),
                        //                       onPressed:
                        //                           () => Navigator.pop(context),
                        //                     ),
                        //                   ),
                        //                   const SizedBox(width: 16),
                        //                   Expanded(
                        //                     child: ElevatedButton(
                        //                       style: ElevatedButton.styleFrom(
                        //                         backgroundColor: const Color(
                        //                           0xFF3366FF,
                        //                         ),
                        //                       ),
                        //                       child: const Text(
                        //                         "Confirmer",
                        //                         style: TextStyle(
                        //                           color: Colors.white,
                        //                         ),
                        //                       ),
                        //                       onPressed: () {
                        //                         setState(() {
                        //                           List<Medicine> ms = [];

                        //                           Treat t = Treat(
                        //                             authorName:
                        //                                 treatment.authorName,
                        //                             authorUid:
                        //                                 treatment.authorName,
                        //                             code: treatment.code,
                        //                             title: treatment.title,
                        //                             medicines: ms,
                        //                             createdAt: DateTime.now(),
                        //                           );

                        //                           for (Medicine m
                        //                               in treatment.medicines) {
                        //                             t.addMedicineWithoutSave(m);
                        //                           }

                        //                           managersTreats.addTreatment(
                        //                             t,
                        //                           );
                        //                         });
                        //                         ScaffoldMessenger.of(
                        //                           context,
                        //                         ).showSnackBar(
                        //                           SnackBar(
                        //                             content: Text(
                        //                               "Traitement ajouté avec succès !",
                        //                             ),
                        //                             backgroundColor:
                        //                                 Colors.green,
                        //                           ),
                        //                         );
                        //                         Navigator.pop(context);
                        //                         Navigator.pop(contextParent);
                        //                       },
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        // );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
