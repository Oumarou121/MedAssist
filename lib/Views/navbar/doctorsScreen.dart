import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/components/appointmentsPage.dart';
import 'package:med_assist/Views/components/utils.dart';
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
          ManagersDoctors managersDoctors = ManagersDoctors(
            uid: userData.uid,
            name: userData.name,
            doctors: userData.doctors,
            appointments: userData.appointments,
            requests: userData.requests,
          );
          ManagersTreats managersTreats = ManagersTreats(
            uid: userData.uid,
            name: userData.name,
            treats: userData.treatments,
          );
          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding + 60),
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F7FB),
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 80,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'doctors_appointments'.tr(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
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
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Iconsax.user_search, color: Colors.white),
                      ),
                    ],
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
                            'my_doctors'.tr(),
                            Iconsax.profile_2user5,
                            true,
                            context,
                            managersDoctors,
                          ),
                          _buildDoctorsList(managersDoctors: managersDoctors),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            'my_queries'.tr(),
                            Iconsax.archive,
                            false,
                            context,
                            managersDoctors,
                          ),
                          _buildQueriesList(
                            managersDoctors: managersDoctors,
                            managersTreats: managersTreats,
                          ),
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

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    bool isDoc,
    BuildContext context,
    ManagersDoctors managersDoctors,
  ) {
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
                          _showJoinDoctorModal(managersDoctors);
                        },
                        icon: Icon(Iconsax.add, color: Colors.black),
                      ),
                    )
                    : TextButton(
                      onPressed: () {
                        _showAppointmentsModal(
                          context: context,
                          managersDoctors: managersDoctors,
                        );
                      },
                      child: Text(
                        'show_appointments'.tr(),
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

  Widget _buildEmptyStateDoctors() {
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
            Icon(
              Iconsax.user_cirlce_add,
              size: 40,
              color: Colors.blueGrey[200],
            ),
            const SizedBox(height: 8),
            Text(
              'no_doctors'.tr(),
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

  Widget _buildEmptyStateQueries() {
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
            Icon(Iconsax.archive, size: 40, color: Colors.blueGrey[200]),
            const SizedBox(height: 8),
            Text(
              'no_queries'.tr(),
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

  Widget _buildDoctorsList({required ManagersDoctors managersDoctors}) {
    return FutureBuilder<List<Doctor>>(
      future: managersDoctors.getDoctors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyStateDoctors();
        }

        final doctors = snapshot.data!;

        return SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder:
                (context, index) =>
                    _buildDoctorCard(doctors[index], managersDoctors),
          ),
        );
      },
    );
  }

  Widget _buildDoctorCard(Doctor doctor, ManagersDoctors managersDoctors) {
    return GestureDetector(
      onTap:
          () => _showDoctorInfosModal(
            doctor: doctor,
            managersDoctors: managersDoctors,
          ),
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
                        'available'.tr(),
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

  void _showDoctorInfosModal({
    required Doctor doctor,
    required ManagersDoctors managersDoctors,
  }) {
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
                                          ? 'available'.tr()
                                          : 'no_available'.tr(),
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          ElevatedButton.icon(
                            onPressed: () {
                              showDoctorAppointmentModal(
                                context: context,
                                doctor: doctor,
                                managersDoctors: managersDoctors,
                                onConfirm: (
                                  appointmentStart,
                                  appointmentEnd,
                                  appointmentReason,
                                ) async {
                                  Navigator.pop(context);
                                  await managersDoctors.sendAppointRequest(
                                    doctor.id,
                                    appointmentStart,
                                    appointmentReason,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('success_send_query'.tr()),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  setState(() {});
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
                              'reservation_now'.tr(),
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
                  title: 'professional_information'.tr(),
                  children: [
                    _buildInfoRow('from'.tr(), doctor.hospital),
                    _buildInfoRow('year_experience'.tr(), doctor.experience),
                    // _buildInfoRow('N° Licence', doctor.licenseNumber),
                  ],
                ),

                // Section Coordonnées
                _buildInfoSection(
                  icon: Iconsax.location,
                  title: 'contact_details'.tr(),
                  children: [
                    _buildInfoRow('address'.tr(), doctor.address),
                    _buildInfoRow('phone_number'.tr(), doctor.phoneNumber),
                    _buildInfoRow('email'.tr(), doctor.email),
                  ],
                ),

                // Section Disponibilités
                //Ajouter le btn demande de rendez-vous (si dispo)
                _buildInfoSection(
                  icon: Iconsax.calendar,
                  title: 'availability'.tr(),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'days'.tr()} :',
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
                              '${'hours'.tr()} :',
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
                  title: 'about'.tr(),
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
                    title: 'languages_spoken'.tr(),
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

  Widget _buildQueriesList({
    required ManagersDoctors managersDoctors,
    required ManagersTreats managersTreats,
  }) {
    return FutureBuilder<List<RequestData>>(
      future: managersDoctors.getRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyStateQueries();
        }

        final requestDatas = [...snapshot.data!]
          ..sort((a, b) => b.request.createdAt.compareTo(a.request.createdAt));

        return Column(
          children:
              requestDatas
                  .map(
                    (data) => _buildRequestCard(
                      context: context,
                      request: data.request,
                      doctor: data.doctor,
                      managersDoctors: managersDoctors,
                      managersTreats: managersTreats,
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildRequestCard({
    required BuildContext context,
    required Request request,
    required Doctor doctor,
    required ManagersDoctors managersDoctors,
    required ManagersTreats managersTreats,
  }) {
    // Couleur et texte du statut
    final statusColor =
        {
          RequestStatus.agreed: Colors.green,
          RequestStatus.pending: Colors.orange,
          RequestStatus.disagreed: Colors.red,
        }[request.status]!;

    final statusText =
        {
          RequestStatus.agreed: 'accepted'.tr(),
          RequestStatus.pending: 'on_hold'.tr(),
          RequestStatus.disagreed: 'denied'.tr(),
        }[request.status]!;

    return GestureDetector(
      onTap:
          () => _showDetailsModal(
            context: context,
            request: request,
            doctor: doctor,
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // En-tête
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(doctor.imageUrl),
              ),
              title: Text(
                doctor.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                request.requestType == RequestType.doctor
                    ? '${'request_follow_up'.tr()} ${request.senderType == SenderType.patient ? 'sent'.tr() : 'received'.tr()}'
                    : request.requestType == RequestType.appointment
                    ? '${'request_scheduled_appointment'.tr()} ${request.senderType == SenderType.patient ? 'sent'.tr() : 'received'.tr()}'
                    : '${'treatment'.tr()} : ${request.treatCode} ${'received'.tr()}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),

            // Détails
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.requestType == RequestType.appointment)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${Appointment.formattedDateStatic(request.startTime!)} • '
                            '${Appointment.formattedTimeStatic(request.startTime!)}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          doctor.hospital,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medical_services,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          doctor.specialty,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pied de carte
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        {
                          RequestStatus.agreed: Icons.check_circle,
                          RequestStatus.pending: Icons.access_time,
                          RequestStatus.disagreed: Icons.cancel,
                        }[request.status],
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (request.senderType == SenderType.doctor &&
                      request.status == RequestStatus.pending) ...[
                    TextButton(
                      onPressed:
                          () => _showStatusDialog(
                            context,
                            request,
                            managersDoctors,
                            managersTreats,
                          ),
                      child: Text(
                        'confirmation'.tr(),
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ] else if (request.status != RequestStatus.pending) ...[
                    TextButton(
                      onPressed: () {
                        showDialogConfirm(
                          isAlert: true,
                          context: context,
                          contextParent: null,
                          msg: 'delete_request'.tr(),
                          action1: () async {
                            await managersDoctors.removeRequest(request.id);
                          },
                          action2: () {},
                        );
                      },
                      child: Text(
                        'delete'.tr(),
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsModal({
    required BuildContext context,
    required Request request,
    required Doctor doctor,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder:
          (context) => _buildModalContent(request: request, doctor: doctor),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildModalContent({
    required Request request,
    required Doctor doctor,
  }) {
    final statusColor =
        {
          RequestStatus.agreed: Colors.green,
          RequestStatus.pending: Colors.orange,
          RequestStatus.disagreed: Colors.red,
        }[request.status]!;

    final statusText =
        {
          RequestStatus.agreed: 'accepted'.tr(),
          RequestStatus.pending: 'on_hold'.tr(),
          RequestStatus.disagreed: 'denied'.tr(),
        }[request.status]!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 75,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Icon(Icons.drag_handle, color: Colors.grey)),
          const SizedBox(height: 20),
          if (request.startTime != null) ...[
            _buildModalRow(
              'date'.tr(),
              Appointment.formattedDateStatic(request.startTime!),
            ),
            _buildModalRow(
              'hours'.tr(),
              Appointment.formattedTimeStatic(request.startTime!),
            ),
          ],

          _buildModalRow('status'.tr(), statusText, color: statusColor),
          _buildModalRow('from'.tr(), doctor.hospital),
          _buildModalRow('speciality'.tr(), doctor.specialty),
        ],
      ),
    );
  }

  Widget _buildModalRow(
    String label,
    String value, {
    Color color = Colors.grey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(
    BuildContext context,
    Request request,
    ManagersDoctors managersDoctors,
    ManagersTreats managersTreats,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('change_status'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  RequestStatus.values.map((status) {
                    final color =
                        {
                          RequestStatus.agreed: Colors.green,
                          RequestStatus.pending: Colors.orange,
                          RequestStatus.disagreed: Colors.red,
                        }[status]!;

                    return ListTile(
                      title: Text(
                        {
                          RequestStatus.agreed: 'accepted'.tr(),
                          RequestStatus.pending: 'on_hold'.tr(),
                          RequestStatus.disagreed: 'denied'.tr(),
                        }[status]!,
                        style: TextStyle(color: color),
                      ),
                      trailing:
                          request.status == status
                              ? Icon(Icons.check, color: color)
                              : null,
                      onTap: () {
                        if (request.status != status) {
                          showDialogConfirm(
                            context: context,
                            contextParent: context,
                            msg: 'change_the_status'.tr(),
                            action1: () async {
                              await managersDoctors.updateRequestStatus(
                                request,
                                status,
                                managersTreats,
                              );
                            },
                            action2: () {},
                          );
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void showDoctorAppointmentModal({
    required BuildContext context,
    required Doctor doctor,
    required ManagersDoctors managersDoctors,
    required Function(DateTime, DateTime, String) onConfirm,
  }) {
    DateTime selectedDate = DateTime.now();
    String appointmentReason = '';
    List<DateTime> availableDates = doctor.getAvailableDates();
    final parts = doctor.availableHours[0].split(':');
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    String error = "";
    bool isError = false;

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
                      title: 'choose_date'.tr(),
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
                      title: 'choose_schedule'.tr(),
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
                      title: 'appointment_reason'.tr(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) => appointmentReason = value,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'appointment_reason_describe'.tr(),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        errorText: isError ? error : null,
                        errorStyle: GoogleFonts.poppins(color: Colors.red),
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
                          'confirm_appointment'.tr(),
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
                        onPressed: () async {
                          if (appointmentReason.isEmpty) {
                            setState(() {
                              error = 'required_reason'.tr();
                              isError = true;
                            });
                            return;
                          }

                          setState(() {
                            isError = false;
                            error = '';
                          });

                          final appointmentStart = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          final appointmentEnd = appointmentStart.add(
                            const Duration(hours: 1),
                          );

                          final result = await managersDoctors
                              .checkSendAppointRequest(
                                doctor.id,
                                appointmentStart,
                              );

                          if (result == "Success") {
                            showDialogConfirm(
                              context: context,
                              contextParent: null,
                              msg: 'send_appointment'.tr(),
                              action1: () async {
                                onConfirm(
                                  appointmentStart,
                                  appointmentEnd,
                                  appointmentReason,
                                );
                              },
                              action2: () {
                                setState(() {});
                              },
                            );
                          } else {
                            setState(() {
                              error = result;
                              isError = true;
                            });
                          }
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

  void _showJoinDoctorModal(ManagersDoctors managersDoctors) {
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
        bool isLoading = false;

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
                    'send_request_title'.tr(),
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
                      labelText: 'doctor_id'.tr(),
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
                      icon:
                          isLoading
                              ? const SizedBox.shrink()
                              : Icon(
                                Iconsax.link,
                                size: 20,
                                color: Colors.white,
                              ),
                      label:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                              : Text(
                                'send'.tr(),
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        setModalState(() {
                          isLoading = true;
                          isError1 = false;
                        });
                        String code = _controller.text.trim();
                        if (code.isEmpty) {
                          setModalState(() {
                            error1 = 'required_doctor_id'.tr();
                            isError1 = true;
                            isLoading = false;
                          });
                          return;
                        }
                        String result = await managersDoctors
                            .checkSendJoinDoctorRequest(code);
                        List<String> parts = result.split('/');

                        if (parts.isNotEmpty && parts[0] == "Success") {
                          String doctorName =
                              parts.length > 1 ? parts[1] : "Inconnu";
                          setModalState(() {
                            isLoading = false;
                          });
                          showDialogConfirm(
                            context: context,
                            contextParent: contextParent,
                            msg: "${'tracking_request'.tr()} $doctorName ?",
                            action1: () async {
                              await managersDoctors.sendJoinDoctorRequest(code);
                            },
                            action2: () {
                              // setState(() {});
                            },
                          );
                        } else {
                          setModalState(() {
                            error1 = result;
                            isError1 = true;
                            isLoading = false;
                          });
                        }
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

  void _showAppointmentsModal({
    required BuildContext context,
    required ManagersDoctors managersDoctors,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F7FB), Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 35,
              top: 24,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
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
                  const SizedBox(height: 16),

                  Expanded(child: AppointmentsPage(manager: managersDoctors)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
