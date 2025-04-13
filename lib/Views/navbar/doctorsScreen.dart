import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Models/appointment.dart';
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
      isOnline: true,
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
      isOnline: false,
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
      isOnline: true,
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
    final size = MediaQuery.of(context).size;
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
                          ),
                          _buildDoctorsList(),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            'My Appointments',
                            Iconsax.calendar_25,
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00C853), size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
                if (doctor.isOnline)
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
                        'En ligne',
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
        final maxModalHeight = screenHeight * 0.95;
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
                                      doctor.isOnline
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
                                            doctor.isOnline
                                                ? Colors.green
                                                : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      doctor.isOnline
                                          ? 'En ligne'
                                          : 'Hors ligne',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
              Icon(icon, color: Color(0xFF3366FF), size: 20),
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

  void _showDoctorsOptionsModal({required AppUserData userData}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 75,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Options de traitement",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Ajouter un nouveau médecin
              ListTile(
                leading: const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.blue,
                ),
                title: Text(
                  "Ajouter un nouveau docteur",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Prendre un rendez-vous
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: Text(
                  "Prendre rendez-vous",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Consulter le planning
              ListTile(
                leading: const Icon(Icons.schedule, color: Colors.purple),
                title: Text(
                  "Planning des rendez-vous",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
