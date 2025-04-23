import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/databaseTreatments.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/components/schedulePage.dart';
import 'package:med_assist/Views/components/utils.dart';
import 'package:provider/provider.dart';

class TreatScreen extends StatefulWidget {
  const TreatScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _TreatScreenState createState() => _TreatScreenState();
}

class _TreatScreenState extends State<TreatScreen> {
  List<Treat> publicTreatments = [];
  List<Medicine> medicines = [];
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> durationControllers = [];
  List<TextEditingController> doseControllers = [];
  List<TextEditingController> frequencyControllers = [];
  List<TextEditingController> intervaleControllers = [];

  @override
  void initState() {
    super.initState();
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
          final userData = snapshot.data!;
          final managersTreats = ManagersTreats(
            uid: userData.uid,
            name: userData.name,
            treats: userData.treatments,
          );

          return FutureBuilder<List<Treat>>(
            future: TreatmentService().getPublicTreatments(),
            builder: (context, treatSnapshot) {
              if (treatSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (treatSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text("Error: ${treatSnapshot.error}")),
                );
              }

              publicTreatments = treatSnapshot.data ?? [];

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
                            'my_treatments'.tr(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
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
                            icon: Icon(
                              Iconsax.search_status_1,
                              color: Colors.white,
                            ),
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
                              _buildTreatmentStatusSection(
                                title: 'active_treatments'.tr(),
                                icon: Iconsax.health,
                                treatments: managersTreats.activeTreatments(),
                                statusColor: const Color(0xFF00C853),
                                userData: userData,
                                managersTreats: managersTreats,
                                isTop: true,
                              ),
                              _buildTreatmentStatusSection(
                                title: 'failed_treatments'.tr(),
                                icon: Iconsax.close_circle,
                                treatments: managersTreats.failedTreatments(),
                                statusColor: Colors.red,
                                userData: userData,
                                managersTreats: managersTreats,
                              ),
                              _buildTreatmentStatusSection(
                                title: 'completed_treatments'.tr(),
                                icon: Iconsax.tick_circle,
                                treatments: managersTreats.finishedTreatments(),
                                statusColor: Colors.grey,
                                userData: userData,
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
            },
          );
        }

        return const LoginScreen();
      },
    );
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
            Icon(
              Icons.health_and_safety,
              size: 40,
              color: Colors.blueGrey[200],
            ),
            const SizedBox(height: 8),
            Text(
              'no_treatment'.tr(),
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

  Widget _buildTreatmentStatusSection({
    required String title,
    required IconData icon,
    required List<Treat> treatments,
    required Color statusColor,
    required AppUserData userData,
    required ManagersTreats managersTreats,
    bool isTop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: statusColor, size: 24),
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
              if (isTop)
                IconButton(
                  onPressed:
                      () => _showTreatmentOptionsModal(
                        userData: userData,
                        managersTreats: managersTreats,
                      ),
                  icon: Icon(Iconsax.more, color: Colors.black),
                ),
            ],
          ),
        ),

        if (treatments.isEmpty) ...[
          _buildEmptyState(),
        ] else ...[
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: treatments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder:
                  (context, index) => _buildTreatmentCard(
                    treat: treatments[index],
                    userData: userData,
                    managersTreats: managersTreats,
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildTreatmentCard({
    required Treat treat,
    required AppUserData userData,
    required ManagersTreats managersTreats,
  }) {
    final progressValue = treat.progressValue();

    return GestureDetector(
      onTap:
          () => _showTreatmentInfosModal(
            contextParent: context,
            treat: treat,
            userData: userData,
            managersTreats: managersTreats,
          ),
      child: Container(
        width: 280,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF3366FF).withOpacity(0.1),
                // color: const Color(0xFF00C853).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          treat.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            //  color: const Color(0xFF00C853),
                            color: const Color(0xFF3366FF),
                          ),
                        ),
                      ),
                      _buildStatusIndicator(treat),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[200],
                    color:
                        treat.isMissing ? Colors.red : const Color(0xFF3366FF),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progressValue * 100).toStringAsFixed(1)}% complété',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'medicines'.tr()} :',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...treat.medicines
                        .take(2)
                        .map(
                          (med) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.health,
                                  color: Colors.green.shade400,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${med.name} (${med.dose})',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (treat.medicines.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+ ${treat.medicines.length - 2} ${'others'.tr()}...',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
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

  Widget _buildStatusIndicator(Treat treat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        treat.isMissing
            ? 'failed'.tr()
            : !treat.isActive()
            ? 'completed'.tr()
            : 'in_progress'.tr(),
        style: GoogleFonts.poppins(
          color:
              treat.isMissing
                  ? Colors.red
                  : treat.isActive()
                  ? const Color(0xFF00C853)
                  : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    List<String> months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    int day = date.day;
    String month = months[date.month - 1];
    int year = date.year;
    return '$day $month $year';
  }

  void _addMedicine() {
    setState(() {
      medicines.add(
        Medicine(
          name: "",
          duration: 0,
          count: 0,
          dose: "",
          frequencyType: FrequencyType.daily,
          frequency: 0,
          intervale: 0,
          createAt: DateTime.now(),
        ),
      );
      nameControllers.add(TextEditingController());
      durationControllers.add(TextEditingController());
      doseControllers.add(TextEditingController());
      frequencyControllers.add(TextEditingController());
      intervaleControllers.add(TextEditingController());
    });
  }

  void _showTreatmentOptionsModal({
    required AppUserData userData,
    required ManagersTreats managersTreats,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
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
              Text(
                'processing_management'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Bouton Nouveau Traitement
              _buildOptionButton(
                icon: Iconsax.add,
                label: 'create_treatment'.tr(),
                color: const Color(0xFF3366FF),
                onPressed: () {
                  Navigator.pop(context);
                  _showAddTreatmentModal(
                    userData: userData,
                    managersTreats: managersTreats,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Bouton Rejoindre Traitement
              _buildOptionButton(
                icon: Iconsax.link,
                label: 'join_treatment'.tr(),
                color: const Color(0xFF00CCFF),
                onPressed: () {
                  Navigator.pop(context);
                  _showJoinTreatmentModal(managersTreats: managersTreats);
                },
              ),
              const SizedBox(height: 12),

              // Bouton Planning
              _buildOptionButton(
                icon: Iconsax.calendar,
                label: 'treatment_planning'.tr(),
                color: const Color(0xFF00C853),
                onPressed: () {
                  Navigator.pop(context);
                  _showScheduleModal(context, managersTreats: managersTreats);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Iconsax.arrow_right_3, size: 20, color: color),
        ],
      ),
    );
  }

  void _showScheduleModal(
    BuildContext context, {
    required ManagersTreats managersTreats,
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
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24, // Ajouté pour l'espace du handle
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // Handle en haut
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

                  // Contenu principal
                  Expanded(child: SchedulePage(manager: managersTreats)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTreatmentInfosModal({
    required BuildContext contextParent,
    required Treat treat,
    required AppUserData userData,
    required ManagersTreats managersTreats,
  }) {
    showModalBottomSheet(
      context: contextParent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        final progressValue = treat.progressValue();
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 60,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    Icon(Iconsax.health, color: Color(0xFF00C853), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'treatments_details'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialogConfirm(
                                isAlert: true,
                                context: context,
                                contextParent: contextParent,
                                msg:
                                    treat.authorUid == userData.uid
                                        ? "${'delete_treatment'.tr} ${treat.title} ?"
                                        : "${'leave_treatment'.tr()} ${treat.title} ${'of'.tr()} ${treat.authorName} ?",
                                action1: () async {
                                  setState(() {
                                    managersTreats.removeTreatment(treat);
                                    TreatmentService()
                                        .removeFollowerFromTreatment(
                                          treat.code,
                                          managersTreats.uid,
                                        );
                                  });
                                },
                                action2: () {},
                              );
                            },
                            icon: Icon(Iconsax.heart_remove, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Colors.grey.shade200,
                        color:
                            treat.isMissing
                                ? Colors.red
                                : const Color(0xFF3366FF),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progressValue * 100).toStringAsFixed(1)}% ${'completed'.tr()}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          _buildStatusBadge(treat),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Treatment Details
                _buildDetailItem(Iconsax.tag, 'Code : ', treat.code),
                _buildDetailItem(
                  Iconsax.activity,
                  '${'treatment'.tr()} : ',
                  treat.title,
                ),
                _buildDetailItem(
                  Iconsax.calendar,
                  '${'start_date'.tr()} : ',
                  formatDate(treat.createdAt),
                ),
                _buildDetailItem(
                  Iconsax.clock,
                  '${'total_duration'.tr()} : ',
                  '${treat.duration} ${'days'.tr()}',
                ),
                const SizedBox(height: 24),

                // Medications Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'prescribed_medications'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (treat.authorUid == userData.uid && !treat.isMissing)
                      ElevatedButton.icon(
                        icon: const Icon(
                          Iconsax.add,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          'add'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3366FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onPressed:
                            () => _showAddMedicineModal(
                              treat: treat,
                              managersTreats: managersTreats,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Medications List
                ...treat.medicines.map(
                  (medicine) => _buildMedicineCard(medicine, treat.isMissing),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Treat treat) {
    final status =
        treat.isMissing
            ? 'failed'.tr()
            : treat.isActive()
            ? 'in_progress'.tr()
            : 'finished'.tr();

    final color =
        treat.isMissing
            ? Colors.red
            : treat.isActive()
            ? const Color(0xFF00C853)
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine, bool isMissing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.health, color: Color(0xFF00CCFF), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medicine.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                medicine.dose,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: medicine.count / medicine.maxCount,
            backgroundColor: Colors.grey.shade200,
            color: isMissing ? Colors.red : const Color(0xFF3366FF),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${medicine.count}/${medicine.maxCount} ${'intakes'.tr()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                medicine.formattedFrequency,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showJoinTreatmentModal({required ManagersTreats managersTreats}) {
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
        String error2 = "";
        bool isError1 = false;
        bool isError2 = false;
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
                    'join_treatment2'.tr(),
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
                      labelText: 'treatment_code'.tr(),
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
                                'join'.tr(),
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
                        setModalState(() {
                          isLoading = true;
                          isError1 = false;
                          isError2 = false;
                        });
                        String code = _controller.text.trim();
                        if (code.isEmpty) {
                          setModalState(() {
                            error1 = "Please enter a code";
                            isError1 = true;
                            isLoading = false;
                          });
                          return;
                        }

                        // TODO: vérifie l'existence du code / traitement
                        // setModalState pour update l'erreur si non trouvé
                        bool exists = publicTreatments.any(
                          (treat) => treat.code == code,
                        );

                        if (!exists) {
                          setModalState(() {
                            error1 = "No such public treatment.";
                            isError1 = true;
                            isLoading = false;
                          });
                          return;
                        }

                        Treat treatment = publicTreatments.firstWhere(
                          (treat) => treat.code == code,
                        );

                        bool alreadyExists = managersTreats.alreadyExists(code);

                        if (alreadyExists) {
                          setModalState(() {
                            error1 = "This treatment is already added";
                            isError1 = true;
                            isLoading = false;
                          });
                          return;
                        }

                        showDialogConfirm(
                          context: context,
                          contextParent: contextParent,
                          msg: "Add The Treatment ${treatment.title} ?",
                          action1: () async {
                            setState(() {
                              List<Medicine> ms = [];

                              Treat t = Treat(
                                authorName: treatment.authorName,
                                authorUid: treatment.authorName,
                                code: treatment.code,
                                title: treatment.title,
                                medicines: ms,
                                createdAt: DateTime.now(),
                                isPublic: treatment.isPublic,
                                followers: [],
                              );

                              for (Medicine m in treatment.medicines) {
                                t.addMedicineWithoutSave(m);
                              }

                              managersTreats.addTreatment(t);

                              TreatmentService().addFollowerToTreatment(
                                treatment.code,
                                managersTreats.uid,
                              );
                            });
                          },
                          action2: () {},
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Séparateur
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade400)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text("OR", style: GoogleFonts.poppins()),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade400)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Dropdown stylisé
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<Treat>(
                      isExpanded: true,
                      hint: Text(
                        "Select a treatment",
                        style: GoogleFonts.poppins(),
                      ),
                      underline: const SizedBox(),
                      items:
                          publicTreatments.map((Treat treat) {
                            return DropdownMenuItem<Treat>(
                              value: treat,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Iconsax.health,
                                  color: const Color(0xFF00C853),
                                ),
                                title: Text(
                                  treat.title,
                                  style: GoogleFonts.poppins(),
                                ),
                                subtitle: Text(
                                  treat.authorName,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (Treat? selected) {
                        if (selected == null) return;
                        if (managersTreats.alreadyExists(selected.code)) {
                          setModalState(() {
                            error2 = "This treatment is already added";
                            isError2 = true;
                          });
                          return;
                        }

                        showDialogConfirm(
                          context: context,
                          contextParent: contextParent,
                          msg: "Add The Treatment ${selected.title} ?",
                          action1: () async {
                            setState(() {
                              List<Medicine> ms = [];

                              Treat t = Treat(
                                authorName: selected.authorName,
                                authorUid: selected.authorName,
                                code: selected.code,
                                title: selected.title,
                                medicines: ms,
                                createdAt: DateTime.now(),
                                isPublic: selected.isPublic,
                                followers: [],
                              );

                              for (Medicine m in selected.medicines) {
                                t.addMedicineWithoutSave(m);
                              }
                              managersTreats.addTreatment(t);
                              TreatmentService().addFollowerToTreatment(
                                selected.code,
                                managersTreats.uid,
                              );
                            });
                          },
                          action2: () {},
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (isError2 && error2.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        error2,
                        style: GoogleFonts.poppins(color: Colors.red),
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

  void _showAddMedicineModal({
    required Treat treat,
    required ManagersTreats managersTreats,
  }) {
    final Medicine medicine = Medicine(
      name: "",
      duration: 0,
      dose: "",
      frequency: 0,
      frequencyType: FrequencyType.daily,
      intervale: 0,
      createAt: DateTime.now(),
    );

    final TextEditingController nameController = TextEditingController();
    final TextEditingController doseController = TextEditingController();
    final TextEditingController frequencyController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController intervalController = TextEditingController();

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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 75,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    Row(
                      children: [
                        Icon(
                          Iconsax.health,
                          color: Color(0xFF00C853),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Nouveau Médicament',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: medicine.formKey,
                      child: Column(
                        children: [
                          _buildModernFormField(
                            controller: nameController,
                            label: 'Nom du médicament',
                            icon: Iconsax.heart,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Champ obligatoire' : null,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildModernFormField(
                                  controller: doseController,
                                  label: 'Dose',
                                  icon: Iconsax.d_cube_scan,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Champ obligatoire'
                                              : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildModernFormField(
                                  controller: durationController,
                                  label: 'Durée (jours)',
                                  icon: Iconsax.calendar,
                                  keyboardType: TextInputType.number,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Champ obligatoire'
                                              : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildModernFormField(
                            controller: frequencyController,
                            label: 'Fréquence',
                            icon: Iconsax.clock,
                            keyboardType: TextInputType.number,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Champ obligatoire' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildModernFormField(
                            controller: intervalController,
                            label: 'Intervalle (heures)',
                            icon: Iconsax.timer,
                            keyboardType: TextInputType.number,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Champ obligatoire' : null,
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<FrequencyType>(
                            value: medicine.frequencyType,
                            decoration: InputDecoration(
                              labelText: 'Type de fréquence',
                              prefixIcon: Icon(Iconsax.repeat),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            items:
                                FrequencyType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.unitLabel),
                                  );
                                }).toList(),
                            onChanged:
                                (value) => setModalState(() {
                                  medicine.frequencyType = value!;
                                }),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Iconsax.add,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Ajouter le médicament',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C853),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {
                                final isValid =
                                    medicine.formKey.currentState?.validate() ??
                                    false;
                                if (isValid) {
                                  final newMedicine = Medicine(
                                    name: nameController.text.trim(),
                                    dose: doseController.text.trim(),
                                    duration: int.parse(
                                      durationController.text.trim(),
                                    ),
                                    frequency: int.parse(
                                      frequencyController.text.trim(),
                                    ),
                                    intervale: int.parse(
                                      intervalController.text.trim(),
                                    ),
                                    frequencyType: medicine.frequencyType,
                                    createAt: DateTime.now(),
                                  );

                                  setState(() {
                                    treat.addMedicine(
                                      newMedicine,
                                      managersTreats.uid,
                                      managersTreats.treats,
                                    );
                                  });
                                  managersTreats.checkAlarm();
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModernFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  void _showAddTreatmentModal({
    required AppUserData userData,
    required ManagersTreats managersTreats,
  }) {
    medicines = [];
    nameControllers = [];
    intervaleControllers = [];
    durationControllers = [];
    doseControllers = [];
    frequencyControllers = [];
    final formKey = GlobalKey<FormState>();
    _addMedicine();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 75,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      Row(
                        children: [
                          Icon(
                            Iconsax.health,
                            color: Color(0xFF00C853),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ajouter un traitement',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildModernFormField(
                        controller: titleController,
                        label: "Titre du traitement",
                        icon: Iconsax.health,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Champ obligatoire' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Médicaments prescrits',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Iconsax.add,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Ajouter',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () {
                              setModalState(() {
                                _addMedicine();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: List.generate(medicines.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildMedicineForm(
                              medicines[index],
                              index,
                              setModalState,
                            ),
                          );
                        }),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Iconsax.add,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Ajouter le traitement',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              bool allValid = true;

                              // Valider tous les formulaires de médicaments
                              for (var medicine in medicines) {
                                final isValid =
                                    medicine.formKey.currentState?.validate() ??
                                    false;
                                if (!isValid) {
                                  allValid = false;
                                }
                              }

                              if (allValid) {
                                List<Medicine> meds = [];

                                for (
                                  int i = 0;
                                  i < nameControllers.length;
                                  i++
                                ) {
                                  final name = nameControllers[i].text.trim();
                                  final durationText =
                                      durationControllers[i].text.trim();
                                  final dose = doseControllers[i].text.trim();
                                  final frequencyText =
                                      frequencyControllers[i].text.trim();
                                  final intervaleText =
                                      intervaleControllers[i].text.trim();

                                  final duration = int.tryParse(durationText);
                                  final frequency = int.tryParse(frequencyText);
                                  final interval = int.parse(intervaleText);

                                  if (name.isNotEmpty &&
                                      dose.isNotEmpty &&
                                      duration != null &&
                                      frequency != null) {
                                    meds.add(
                                      Medicine(
                                        name: name,
                                        duration: duration,
                                        count: 0,
                                        dose: dose,
                                        frequency: frequency,
                                        frequencyType:
                                            medicines[i].frequencyType,
                                        intervale: interval,
                                        createAt: DateTime.now(),
                                      ),
                                    );
                                  }
                                }

                                if (meds.isNotEmpty) {
                                  Treat newTreatment = Treat(
                                    authorUid: userData.uid,
                                    authorName: 'Mr/Mm ${userData.name}',
                                    code:
                                        'TREAT-${DateTime.now().millisecondsSinceEpoch}',
                                    title: titleController.text.trim(),
                                    medicines: meds,
                                    createdAt: DateTime.now(),
                                    isPublic: false,
                                    followers: [managersTreats.uid],
                                  );

                                  Navigator.pop(context);
                                  setState(() {
                                    managersTreats.addTreatment(newTreatment);
                                    titleController.clear();
                                    medicines.clear();
                                    nameControllers.clear();
                                    durationControllers.clear();
                                    doseControllers.clear();
                                    frequencyControllers.clear();
                                    intervaleControllers.clear();
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Traitement ajouté avec succès !",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMedicineForm(
    Medicine medicine,
    int index,
    StateSetter setModalState,
  ) {
    return Form(
      key: medicine.formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Médicament ${index + 1}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setModalState(() {
                    medicines.removeAt(index);
                    nameControllers.removeAt(index);
                    intervaleControllers.removeAt(index);
                    durationControllers.removeAt(index);
                    doseControllers.removeAt(index);
                    frequencyControllers.removeAt(index);
                  });
                },
                icon: Icon(Iconsax.note_remove),
                color: Colors.red,
              ),
            ],
          ),
          _buildModernFormField(
            controller: nameControllers[index],
            label: 'Nom du médicament',
            icon: Iconsax.heart,
            validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildModernFormField(
                  controller: doseControllers[index],
                  label: 'Dose',
                  icon: Iconsax.d_cube_scan,
                  validator:
                      (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernFormField(
                  controller: durationControllers[index],
                  label: 'Durée (jours)',
                  icon: Iconsax.calendar,
                  keyboardType: TextInputType.number,
                  validator:
                      (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildModernFormField(
            controller: frequencyControllers[index],
            label: 'Fréquence',
            icon: Iconsax.clock,
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: 16),

          _buildModernFormField(
            controller: intervaleControllers[index],
            label: 'Intervalle (heures)',
            icon: Iconsax.timer,
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<FrequencyType>(
            value: medicine.frequencyType,
            decoration: InputDecoration(
              labelText: 'Type de fréquence',
              prefixIcon: Icon(Iconsax.repeat),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            items:
                FrequencyType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.unitLabel),
                  );
                }).toList(),
            onChanged:
                (value) => setModalState(() {
                  medicine.frequencyType = value!;
                }),
          ),
        ],
      ),
    );
  }
}
