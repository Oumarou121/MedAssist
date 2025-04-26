import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/databaseDoctors.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/medicalRecord.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/components/utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final AppUserData userData;
  const MedicalRecordsScreen({super.key, required this.userData});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  List<MedicalRecordData> filteredRecords = [];
  String selectedCategory = 'all'.tr();
  bool isLoading = true;
  bool isPickingFile = false;
  File? selectedFile;
  String? fileType;

  // void _loadMedicalRecords() async {}

  List<MedicalRecordData> _filterRecords(
    List<MedicalRecordData> records,
    String category,
  ) {
    if (category == 'all'.tr()) return records;
    return records
        .where((r) => r.medicalRecord.category.toUpperCase() == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<AppUser?>(context);
    if (user == null) return const LoginScreen();
    final database = DatabaseService(user.uid);

    return StreamBuilder<AppUserData>(
      stream: database.user,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erreur utilisateur : ${userSnapshot.error}'),
            ),
          );
        }

        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Utilisateur non trouvé.")),
          );
        }

        final userData = userSnapshot.data!;
        final ManagersMedicalRecord managersMedicalRecord =
            ManagersMedicalRecord(
              uid: userData.uid,
              name: userData.name,
              medicalRecords: userData.medicalRecords,
            );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 80,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'my_medical_records'.tr(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
                    icon: Icon(Iconsax.search_status_1, color: Colors.white),
                  ),
                ],
              ),
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.03)),

              StreamBuilder<List<MedicalRecordData>>(
                stream: managersMedicalRecord.streamMedicalRecords(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text('Erreur : ${snapshot.error}')),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildEmptyState(),
                      ),
                    );
                  }

                  final myMedicalRecords = snapshot.data!;
                  int totalKB = managersMedicalRecord.totalUsedMemory(
                    myMedicalRecords,
                  );
                  double usedStorage = totalKB / 1024;
                  double maxStorage = ManagersMedicalRecord.maxMemory / 1024;
                  List<String> categories = managersMedicalRecord
                      .getAllCategories(myMedicalRecords);

                  if (filteredRecords.isEmpty ||
                      selectedCategory == 'all'.tr()) {
                    filteredRecords = _filterRecords(
                      myMedicalRecords,
                      selectedCategory,
                    );
                    filteredRecords.sort(
                      (a, b) => b.medicalRecord.createdAt.compareTo(
                        a.medicalRecord.createdAt,
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildCategoryFilter(
                          categories,
                          myMedicalRecords,
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildStorageIndicator(
                          managersMedicalRecord: managersMedicalRecord,
                          medicalRecords: myMedicalRecords,
                          usedStorage: usedStorage,
                          maxStorage: maxStorage,
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final inAnimation = Tween<double>(
                            begin: 0.8,
                            end: 1.0,
                          ).animate(animation);
                          final outAnimation = Tween<double>(
                            begin: 1.0,
                            end: 0.0,
                          ).animate(animation);

                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, childWidget) {
                              final isIncoming =
                                  animation.status != AnimationStatus.reverse;

                              return Opacity(
                                opacity:
                                    isIncoming
                                        ? animation.value.clamp(0.0, 1.0)
                                        : outAnimation.value.clamp(0.0, 1.0),
                                child: Transform.scale(
                                  scale: isIncoming ? inAnimation.value : 1.0,
                                  child: childWidget,
                                ),
                              );
                            },
                            child: child,
                          );
                        },

                        child: Padding(
                          key: ValueKey<String>(selectedCategory),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            spacing: 15,
                            runSpacing: 15,
                            children:
                                filteredRecords.map((record) {
                                  return SizedBox(
                                    width:
                                        (MediaQuery.of(context).size.width -
                                            55) /
                                        2,
                                    child: _buildMedicalRecordCard(
                                      managersMedicalRecord:
                                          managersMedicalRecord,
                                      record: record,
                                      myMedicalRecords: myMedicalRecords,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(
    List<String> categories,
    List<MedicalRecordData> myMedicalRecords,
  ) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder:
            (_, index) => ChoiceChip(
              label: Text(categories[index]),
              selected: selectedCategory == categories[index],
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedCategory = categories[index];
                    filteredRecords = _filterRecords(
                      myMedicalRecords,
                      selectedCategory,
                    );
                    filteredRecords.sort(
                      (a, b) => b.medicalRecord.createdAt.compareTo(
                        a.medicalRecord.createdAt,
                      ),
                    );
                  });
                }
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.green[100],
              labelStyle: TextStyle(
                color:
                    selectedCategory == categories[index]
                        ? Colors.green[800]
                        : Colors.grey[600],
              ),
            ),
      ),
    );
  }

  Widget _buildStorageIndicator({
    required ManagersMedicalRecord managersMedicalRecord,
    required List<MedicalRecordData> medicalRecords,
    required double usedStorage,
    required double maxStorage,
  }) {
    final double usedPercentage = usedStorage / maxStorage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: usedPercentage,
                  strokeWidth: 8,
                  color: Colors.green[800],
                  backgroundColor: Colors.grey[200],
                ),
              ),
              Text(
                '${(usedPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'used_space'.tr(),
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${usedStorage.toStringAsFixed(1)} Mo / ${maxStorage.toStringAsFixed(1)} Mo',
                      style: GoogleFonts.poppins(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
                  child: IconButton(
                    onPressed: () {
                      _showAddMedicalRecordModal(
                        managersMedicalRecord: managersMedicalRecord,
                        medicalRecords: medicalRecords,
                      );
                    },
                    icon: Icon(Iconsax.folder_add, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.folder, size: 40, color: Colors.blueGrey[200]),
            const SizedBox(height: 8),
            Text(
              'no_medical_record'.tr(),
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

  Widget _buildMedicalRecordCard({
    required ManagersMedicalRecord managersMedicalRecord,
    required MedicalRecordData record,
    required List<MedicalRecordData> myMedicalRecords,
  }) {
    final totalSizeMB = record.medicalRecord.totalSizeInKo / 1024;
    final progressValue = (totalSizeMB / 50) * myMedicalRecords.length;

    return GestureDetector(
      onTap:
          () => _showMedicalRecordInfosModal(
            managersMedicalRecord: managersMedicalRecord,
            medicalRecord: record,
            myMedicalRecords: myMedicalRecords,
          ),
      child: Container(
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
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 0,
                right: 16,
                left: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            record.medicalRecord.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: const Color(0xFF00C853),
                            ),
                          ),
                        ),
                        _buildRecordStatus(record),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey[200],
                      color:
                          progressValue > 0.9
                              ? Colors.red
                              : const Color(0xFF00C853),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${totalSizeMB.toStringAsFixed(1)} Mo',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    record.medicalRecord.medicalFiles.isNotEmpty
                        ? Text(
                          '+ ${record.medicalRecord.medicalFiles.length} ${'files'.tr()}...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        )
                        : Center(
                          child: Text(
                            'no_file'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
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

  Widget _buildEmptyStateMedicalFile() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.document, size: 40, color: Colors.blueGrey[200]),
            const SizedBox(height: 8),
            Text(
              'no_medical_file'.tr(),
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

  void _showAddMedicalRecordModal({
    required List<MedicalRecordData> medicalRecords,
    required ManagersMedicalRecord managersMedicalRecord,
  }) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isError = false;
    String error = '';
    // bool _isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext contextParent) {
        final screenHeight = MediaQuery.of(contextParent).size.height;
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
            bottom: MediaQuery.of(contextParent).viewInsets.bottom + 75,
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
                            // Iconsax.health,
                            Icons.description_rounded,
                            color: Color(0xFF00C853),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'general_information'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildModernFormField(
                        controller: titleController,
                        label: 'title'.tr(),
                        icon: Iconsax.document,
                        validator:
                            (value) => value!.isEmpty ? 'required'.tr() : null,
                      ),
                      const SizedBox(height: 20),
                      _buildModernFormField(
                        controller: categoryController,
                        label: 'category'.tr(),
                        icon: Iconsax.category,
                        validator:
                            (value) => value!.isEmpty ? 'required'.tr() : null,
                      ),
                      const SizedBox(height: 10),
                      isError
                          ? Center(
                            child: Text(
                              error,
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              String title = titleController.text.trim();
                              String category = categoryController.text.trim();
                              String exist = await managersMedicalRecord
                                  .checkCanAddMedicalRecord(
                                    title,
                                    medicalRecords,
                                  );
                              if (exist == 'Success') {
                                showDialogConfirm(
                                  context: context,
                                  contextParent: contextParent,
                                  msg:
                                      "${'create_medical_record'.tr()} : $title ?",
                                  action1: () async {
                                    await managersMedicalRecord
                                        .addMedicalRecord(title, category);
                                  },
                                  action2: () {
                                    // setState(() {
                                    //   _loadMedicalRecords();
                                    // });
                                  },
                                );
                              } else {
                                setModalState(() {
                                  error = exist;
                                  isError = true;
                                });
                              }
                            }
                          },
                          child: Text(
                            'create_medical_record_btn'.tr(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
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

  Widget _buildRecordStatus(MedicalRecordData record) {
    final isUpdated = record.medicalRecord.createdAt.isAfter(
      DateTime.now().subtract(Duration(days: 7)),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUpdated ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isUpdated ? 'recent'.tr() : 'archive'.tr(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: isUpdated ? Colors.green[800] : Colors.grey[600],
        ),
      ),
    );
  }

  void _showMedicalRecordInfosModal({
    required ManagersMedicalRecord managersMedicalRecord,
    required MedicalRecordData medicalRecord,
    required List<MedicalRecordData> myMedicalRecords,
  }) {
    final totalSizeMB = medicalRecord.medicalRecord.totalSizeInKo / 1024;
    bool isFromMe =
        medicalRecord.medicalRecord.creatorType == CreatorType.patient;
    String creator =
        isFromMe ? 'me'.tr() : medicalRecord.doctors[0].doctorDescription;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext contextParent) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxModalHeight = screenHeight * .95;

        return Container(
          width: MediaQuery.of(contextParent).size.width,
          height: maxModalHeight,
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
                    Icon(Iconsax.folder, color: Color(0xFF00C853), size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'medical_record_details'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          PopupMenuButton(
                            color: Colors.white,
                            itemBuilder:
                                (context) => [
                                  if (medicalRecord.medicalRecord.canBeShared)
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: const Icon(Iconsax.share),
                                        title: Text('share'.tr()),
                                        onTap: () {
                                          Navigator.pop(context);
                                          shareAction(
                                            managersMedicalRecord:
                                                managersMedicalRecord,
                                            medicalRecord:
                                                medicalRecord.medicalRecord,
                                          );
                                        },
                                      ),
                                    ),
                                  PopupMenuItem(
                                    child: ListTile(
                                      leading: const Icon(
                                        Iconsax.document_download,
                                        color: Colors.blue,
                                      ),
                                      title: Text('download'.tr()),
                                      onTap: () async {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.highlight_remove_outlined,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        'delete'.tr(),
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        deleteMedicalRecord(
                                          managersMedicalRecord:
                                              managersMedicalRecord,
                                          medicalRecord: medicalRecord,
                                          contextParent: contextParent,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _buildInfoSection(
                  children: [
                    _buildDetailItem(
                      Iconsax.activity,
                      '${'title'.tr()} : ',
                      medicalRecord.medicalRecord.title,
                    ),
                    _buildDetailItem(
                      Iconsax.category,
                      '${'category'.tr()} : ',
                      medicalRecord.medicalRecord.category.toUpperCase(),
                    ),
                    _buildDetailItem(
                      Iconsax.size,
                      '${'size'.tr()} : ',
                      '${totalSizeMB.toStringAsFixed(1)} Mo',
                    ),
                  ],
                ),

                //Creator Infos
                Row(
                  children: <Widget>[
                    Icon(
                      Iconsax.creative_commons,
                      color: Color(0xFF00C853),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'creator_share_infos'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _buildInfoSection(
                  children: [
                    _buildDetailItem(
                      Iconsax.personalcard,
                      '${'create_by'.tr()} : ',
                      creator,
                    ),

                    _buildDetailItem(
                      Iconsax.timer,
                      '${'created_at'.tr()} : ',
                      medicalRecord.medicalRecord.formattedDate,
                    ),
                    if (isFromMe) ...[
                      for (int i = 0; i < medicalRecord.doctors.length; i++)
                        _buildDetailItem(
                          Iconsax.personalcard,
                          '${'share_with'.tr()} : ',
                          medicalRecord.doctors[i].doctorDescription,
                        ),
                    ] else ...[
                      for (int i = 1; i < medicalRecord.doctors.length; i++)
                        _buildDetailItem(
                          Iconsax.personalcard,
                          '${'share_with'.tr()} : ',
                          medicalRecord.doctors[i].doctorDescription,
                        ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'medical_files'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isFromMe)
                      ElevatedButton.icon(
                        icon: const Icon(
                          Iconsax.add,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          'add_file'.tr(),
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
                          _showAddMedicalFileModal(
                            managersMedicalRecord: managersMedicalRecord,
                            myMedicalRecords: myMedicalRecords,
                            medicalRecord: medicalRecord,
                            onFileAdded: () {
                              // _loadMedicalRecords();
                              // setState(() {});

                              Future.delayed(Duration(milliseconds: 10), () {
                                _showMedicalRecordInfosModal(
                                  managersMedicalRecord: managersMedicalRecord,
                                  myMedicalRecords: myMedicalRecords,
                                  medicalRecord: medicalRecord,
                                );
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                medicalRecord.medicalRecord.medicalFiles.isEmpty
                    ? _buildEmptyStateMedicalFile()
                    : _buildDocumentsList(
                      managersMedicalRecord: managersMedicalRecord,
                      myMedicalRecords: myMedicalRecords,
                      isFromMe: isFromMe,
                      medicalRecord: medicalRecord,
                      medicalFiles: medicalRecord.medicalRecord.medicalFiles,
                      onFileAdded: () {
                        // _loadMedicalRecords();
                        // setState(() {});
                        Future.delayed(Duration(milliseconds: 10), () {
                          _showMedicalRecordInfosModal(
                            managersMedicalRecord: managersMedicalRecord,
                            myMedicalRecords: myMedicalRecords,
                            medicalRecord: medicalRecord,
                          );
                        });
                        Navigator.pop(context);
                      },
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: label,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void shareAction({
    required MedicalRecord medicalRecord,
    required ManagersMedicalRecord managersMedicalRecord,
  }) async {
    final allDoctors = widget.userData.doctors;
    final availableDoctors =
        allDoctors
            .where((doctor) => !medicalRecord.doctorIDs.contains(doctor))
            .toList();
    final doctors = await DoctorService().getDoctorsByIds(availableDoctors);
    if (!context.mounted) return;
    showShareModal(
      doctors: doctors,
      medicalRecord: medicalRecord,
      managersMedicalRecord: managersMedicalRecord,
    );
  }

  void showShareModal({
    required ManagersMedicalRecord managersMedicalRecord,
    required List<Doctor> doctors,
    required MedicalRecord medicalRecord,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext contextParent) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: MediaQuery.of(context).size.height * .5,
            color: Color(0x66000000),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                ),
                padding: EdgeInsets.only(
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 75,
                  right: 24,
                  left: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 24),

                    Row(
                      children: [
                        Icon(Iconsax.share, color: Color(0xFF00C853), size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'select_doctor'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    if (doctors.isNotEmpty) ...[
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: doctors.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            final doctor = doctors[index];

                            return _buildDoctorCardMove(
                              managersMedicalRecord: managersMedicalRecord,
                              doctor: doctor,
                              medicalRecord: medicalRecord,
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      _buildEmptyStateMoveAndShare(
                        icon: Iconsax.user_cirlce_add,
                        title: 'no_doctor_found'.tr(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateMoveAndShare({
    required IconData icon,
    required String title,
  }) {
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
            Icon(icon, size: 40, color: Colors.blueGrey[200]),
            const SizedBox(height: 8),
            Text(
              title,
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

  Widget _buildInfoSection({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
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
    );
  }

  Widget _buildDocumentsList({
    required ManagersMedicalRecord managersMedicalRecord,
    required bool isFromMe,
    required MedicalRecordData medicalRecord,
    required List<MedicalFile> medicalFiles,
    required VoidCallback onFileAdded,
    required List<MedicalRecordData> myMedicalRecords,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: medicalFiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder:
          (_, index) => _buildDocumentCard(
            managersMedicalRecord: managersMedicalRecord,
            isFromMe: isFromMe,
            medicalRecord: medicalRecord,
            medicalFile: medicalFiles[index],
            onFileAdded: onFileAdded,
            myMedicalRecords: myMedicalRecords,
          ),
    );
  }

  Widget _buildDocumentCard({
    required ManagersMedicalRecord managersMedicalRecord,
    required bool isFromMe,
    required MedicalRecordData medicalRecord,
    required MedicalFile medicalFile,
    required VoidCallback onFileAdded,
    required List<MedicalRecordData> myMedicalRecords,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getFileTypeColor(medicalFile.fileType),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileTypeIcon(medicalFile.fileType),
            color: Colors.white,
          ),
        ),
        title: Text(
          medicalFile.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${medicalRecord.medicalRecord.category} • ${medicalFile.formattedDate}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${medicalFile.FSize} Ko',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          offset: const Offset(0, -150),
          color: Colors.white,
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.remove_red_eye_outlined),
                    title: Text('Preview'),
                    onTap: () {
                      Navigator.pop(context);
                      previewFile(
                        context,
                        medicalFile.fileUrl,
                        medicalFile.fileType,
                      );
                    },
                  ),
                ),

                if (isFromMe)
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(
                        Icons.move_down_outlined,
                        color: Colors.blue[800],
                      ),
                      title: Text(
                        'move_folder'.tr(),
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                          ),
                          builder: (BuildContext contextParent) {
                            final currentFolder = medicalRecord;
                            final availableFolders =
                                myMedicalRecords
                                    .where(
                                      (f) =>
                                          f != currentFolder &&
                                          f.medicalRecord.creatorType ==
                                              CreatorType.patient,
                                    )
                                    .toList();

                            return GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: MediaQuery.of(context).size.height * .5,
                                color: Color(0x66000000),
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(0),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                      top: 24,
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom +
                                          75,
                                      right: 24,
                                      left: 24,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 24),

                                        Row(
                                          children: [
                                            Icon(
                                              Iconsax.folder,
                                              color: Color(0xFF00C853),
                                              size: 28,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'select_folder'.tr(),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        if (availableFolders.isNotEmpty) ...[
                                          Expanded(
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              itemCount:
                                                  availableFolders.length,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    mainAxisSpacing: 8,
                                                    crossAxisSpacing: 8,
                                                    childAspectRatio: 1,
                                                  ),
                                              itemBuilder: (context, index) {
                                                final folder =
                                                    availableFolders[index];
                                                return _buildMedicalRecordCardMove(
                                                  managersMedicalRecord:
                                                      managersMedicalRecord,
                                                  myMedicalRecords:
                                                      myMedicalRecords,
                                                  record: folder,
                                                  medicalRecordOld:
                                                      medicalRecord,
                                                  medicalFile: medicalFile,
                                                  onFileAdded: onFileAdded,
                                                  contextParent: contextParent,
                                                );
                                              },
                                            ),
                                          ),
                                        ] else ...[
                                          // Text('no_doctor_found'.tr()),
                                          _buildEmptyStateMoveAndShare(
                                            icon: Iconsax.folder,
                                            title: 'no_folder_found'.tr(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(
                      Iconsax.document_download,
                      color: Colors.blue,
                    ),
                    title: Text(
                      'download'.tr(),
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await _downloadFile(
                        medicalRecord: medicalRecord,
                        medicalFile: medicalFile,
                      );
                    },
                  ),
                ),
                if (isFromMe)
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(
                        Icons.highlight_remove_outlined,
                        color: Colors.red,
                      ),
                      title: Text(
                        'delete'.tr(),
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Future.delayed(Duration.zero, () {
                          showDialogConfirm(
                            context: context,
                            isAlert: true,
                            contextParent: null,
                            msg:
                                "${'delete_medical_file'.tr()} : ${medicalFile.title} ?",
                            action1: () async {
                              await managersMedicalRecord.removeMedicalFile(
                                medicalRecord.medicalRecord,
                                medicalFile,
                              );
                            },
                            action2: () {
                              onFileAdded();
                            },
                          );
                        });
                      },
                    ),
                  ),
              ],
        ),
      ),
    );
  }

  Widget _buildMedicalRecordCardMove({
    required ManagersMedicalRecord managersMedicalRecord,
    required List<MedicalRecordData> myMedicalRecords,
    required MedicalRecordData record,
    required MedicalRecordData medicalRecordOld,
    required MedicalFile medicalFile,
    required VoidCallback onFileAdded,
    required BuildContext contextParent,
  }) {
    final totalSizeMB = record.medicalRecord.totalSizeInKo / 1024;
    final progressValue = (totalSizeMB / 50) * myMedicalRecords.length;

    return GestureDetector(
      onTap: () {
        showDialogConfirm(
          context: context,
          contextParent: contextParent,
          msg:
              "${'move_medical_file'.tr()} : ${medicalFile.title} ${'to'.tr()} ${record.medicalRecord.title} ?",
          action1: () async {
            await managersMedicalRecord.moveMedicalFile(
              medicalFile,
              medicalRecordOld.medicalRecord,
              record.medicalRecord.id,
              record.medicalRecord.title,
            );
          },
          action2: () {
            onFileAdded();
          },
        );
      },
      child: Container(
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
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 0,
                right: 16,
                left: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            record.medicalRecord.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: const Color(0xFF00C853),
                            ),
                          ),
                        ),
                        _buildRecordStatus(record),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey[200],
                      color:
                          progressValue > 0.9
                              ? Colors.red
                              : const Color(0xFF00C853),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${totalSizeMB.toStringAsFixed(1)} Mo',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    record.medicalRecord.medicalFiles.isNotEmpty
                        ? Text(
                          '+ ${record.medicalRecord.medicalFiles.length} ${'files'.tr()}...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        )
                        : Center(
                          child: Text(
                            'no_file'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
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

  Color _getFileTypeColor(String type) {
    final lower = type.toLowerCase();

    if (lower == 'pdf') {
      return Colors.red[400]!;
    } else if ([
      'jpg',
      'jpeg',
      'png',
      'bmp',
      'tiff',
      'gif',
      'webp',
    ].contains(lower)) {
      return Colors.green[400]!;
    } else if (['doc', 'docx', 'txt'].contains(lower)) {
      return Colors.orange[400]!;
    } else if (['xls', 'xlsx', 'csv'].contains(lower)) {
      return Colors.teal[400]!;
    } else if (lower == 'dcm') {
      return Colors.purple[400]!;
    } else {
      return Colors.blue[400]!;
    }
  }

  IconData _getFileTypeIcon(String type) {
    final lower = type.toLowerCase();

    if (lower == 'pdf') {
      return Icons.picture_as_pdf;
    } else if ([
      'jpg',
      'jpeg',
      'png',
      'bmp',
      'tiff',
      'gif',
      'webp',
    ].contains(lower)) {
      return Icons.image;
    } else if (['doc', 'docx', 'txt'].contains(lower)) {
      return Icons.description;
    } else if (['xls', 'xlsx', 'csv'].contains(lower)) {
      return Icons.table_chart;
    } else if (lower == 'dcm') {
      return Icons.medical_information;
    } else {
      return Icons.insert_drive_file;
    }
  }

  void _showAddMedicalFileModal({
    required ManagersMedicalRecord managersMedicalRecord,
    required List<MedicalRecordData> myMedicalRecords,
    required MedicalRecordData medicalRecord,
    required VoidCallback onFileAdded,
  }) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isError = false;
    String error = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext contextParent) {
        final screenHeight = MediaQuery.of(contextParent).size.height;
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
            bottom: MediaQuery.of(contextParent).viewInsets.bottom + 75,
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
                            // Iconsax.health,
                            Iconsax.document,
                            color: Color(0xFF00C853),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'general_information'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildModernFormField(
                        controller: titleController,
                        label: 'title'.tr(),
                        icon: Iconsax.document,
                        validator:
                            (value) => value!.isEmpty ? 'required'.tr() : null,
                      ),
                      const SizedBox(height: 20),
                      if (selectedFile != null)
                        Center(
                          child:
                              isPickingFile
                                  ? const CircularProgressIndicator()
                                  : selectedFile != null
                                  ? Text(
                                    '${'selected_file'.tr()} : ${selectedFile!.path.split('/').last}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                        ),

                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upload_rounded),
                          label: Text('import_file'.tr()),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _pickFile(setModalState),
                        ),
                      ),

                      const SizedBox(height: 10),
                      isError
                          ? Center(
                            child: Text(
                              error,
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              String title = titleController.text.trim();
                              if (selectedFile != null && fileType != null) {
                                String exist = managersMedicalRecord
                                    .checkCanAddMedicalFile(
                                      medicalRecord.medicalRecord,
                                      title,
                                    );
                                if (exist == 'Success') {
                                  String canAdd = await managersMedicalRecord
                                      .checkCanAddFile(
                                        selectedFile!,
                                        myMedicalRecords,
                                      );
                                  if (canAdd == 'Success') {
                                    showDialogConfirm(
                                      context: context,
                                      contextParent: contextParent,
                                      msg:
                                          "${'add_medical_file'.tr()} : $title ?",
                                      action1: () async {
                                        await managersMedicalRecord
                                            .addMedicalFile(
                                              medicalRecord.medicalRecord,
                                              title,
                                              fileType!,
                                              selectedFile!,
                                            );
                                      },
                                      action2: () {
                                        onFileAdded();
                                      },
                                    );
                                  } else {
                                    setModalState(() {
                                      error = canAdd;
                                      isError = true;
                                    });
                                  }
                                } else {
                                  setModalState(() {
                                    error = exist;
                                    isError = true;
                                  });
                                }
                              } else {
                                setModalState(() {
                                  error = 'invalid_file'.tr();
                                  isError = true;
                                });
                              }
                            }
                          },
                          child: Text(
                            'add_medical_file'.tr(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
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

  Future<void> _pickFile(StateSetter setModalState) async {
    try {
      setModalState(() => isPickingFile = true);

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'jpg',
          'jpeg',
          'png',
          'bmp',
          'tiff',
          'dcm',
          'xls',
          'xlsx',
          'csv',
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        if (file.path != null) {
          setState(() {
            selectedFile = File(file.path!);
            fileType = file.extension;
          });
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setModalState(() => isPickingFile = false);
    }
  }

  void previewFile(BuildContext context, String url, String extension) async {
    if (['jpg', 'jpeg', 'png', 'bmp', 'tiff'].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => Scaffold(
                appBar: AppBar(title: Text('image_preview'.tr())),
                body: PhotoView(imageProvider: NetworkImage(url)),
              ),
        ),
      );
    } else if (extension == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PDFViewerPage(url: url)),
      );
    } else if ([
      'doc',
      'docx',
      'xls',
      'xlsx',
      'csv',
      'txt',
      'dcm',
    ].contains(extension)) {
      // Redirection vers Google Docs Viewer
      final viewerUrl = 'https://docs.google.com/viewer?url=$url';
      if (await canLaunchUrl(Uri.parse(viewerUrl))) {
        await launchUrl(
          Uri.parse(viewerUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        Text('Impossible d’ouvrir le fichier.');
      }
    } else {
      print('Type de fichier non pris en charge.');
    }
  }

  Future<bool> _requestPermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<void> _downloadFile({
    required MedicalRecordData medicalRecord,
    required MedicalFile medicalFile,
  }) async {
    if (!await _requestPermission()) {
      openAppSettings();
      return;
    }
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final filePath =
          '$selectedDirectory/${medicalFile.title}.${medicalFile.fileType}';

      final dio = Dio();
      await dio.download(medicalFile.fileUrl, filePath);

      print('Téléchargement terminé dans : $filePath');
    } else {
      print('Aucun dossier sélectionné.');
    }
  }

  // Future<void> _downloadFile({
  //   required MedicalRecordData medicalRecord,
  //   required MedicalFile medicalFile,
  // }) async {
  //   if (!await _requestPermission()) {
  //     openAppSettings(); // Ouvre les paramètres de l'appli
  //     return;
  //   }

  //   final directory = await getExternalStorageDirectory();
  //   if (directory != null) {
  //     final path =
  //         '${directory.path}/${medicalFile.title}.${medicalFile.fileType}';
  //     final file = File(path);

  //     final dio = Dio();
  //     try {
  //       await dio.download(medicalFile.fileUrl, file.path);
  //       print('Téléchargement terminé dans : ${file.path}');
  //     } catch (e) {
  //       print('Erreur de téléchargement : $e');
  //     }
  //   } else {
  //     print('Impossible d\'obtenir le répertoire.');
  //   }
  // }

  void deleteMedicalRecord({
    required ManagersMedicalRecord managersMedicalRecord,
    required MedicalRecordData medicalRecord,
    required BuildContext contextParent,
  }) {
    showDialogConfirm(
      isAlert: true,
      context: context,
      contextParent: contextParent,
      msg:
          "${'delete_medical_record'.tr()} : ${medicalRecord.medicalRecord.title} ?",
      action1: () async {
        await managersMedicalRecord.removeMedicalRecord(
          medicalRecord.medicalRecord,
        );
      },
      action2: () {
        // setState(() {
        //   _loadMedicalRecords();
        // });
      },
    );
  }

  Widget _buildDoctorCardMove({
    required ManagersMedicalRecord managersMedicalRecord,
    required Doctor doctor,
    required MedicalRecord medicalRecord,
  }) {
    return GestureDetector(
      onTap: () {
        shareMedicalRecord(
          managersMedicalRecord: managersMedicalRecord,
          contextParent: context,
          doctor: doctor,
          medicalRecord: medicalRecord,
        );
      },
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void shareMedicalRecord({
    required ManagersMedicalRecord managersMedicalRecord,
    required MedicalRecord medicalRecord,
    required Doctor doctor,
    required BuildContext contextParent,
  }) {
    showDialogConfirm(
      context: context,
      contextParent: contextParent,
      msg:
          "${'share_medical_record'.tr()} ${medicalRecord.title} ${'to'.tr()} ${doctor.name} ?",
      action1: () async {
        await managersMedicalRecord.shareMedicalRecord(
          doctor.id,
          medicalRecord,
        );
      },
      action2: () {
        // setState(() {
        //   _loadMedicalRecords();
        // });
      },
    );
  }
}

class PDFViewerPage extends StatefulWidget {
  final String url;
  const PDFViewerPage({required this.url});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    _downloadPDF();
  }

  Future<void> _downloadPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(response.bodyBytes, flush: true);

      setState(() {
        localPath = file.path;
      });
    } catch (e) {
      print('Erreur de téléchargement : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('pdf_preview'.tr())),
      body:
          localPath == null
              ? const Center(child: CircularProgressIndicator())
              : PDFView(
                filePath: localPath!,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: true,
                pageFling: true,
              ),
    );
  }
}
