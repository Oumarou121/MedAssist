import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/databaseDoctors.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/medicalRecord.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/components/utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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
  late ManagersMedicalRecord managersMedicalRecord;
  List<MedicalRecord> myMedicalRecords = [];
  List<MedicalRecord> filteredRecords = [];
  List<String> categories = [];
  String selectedCategory = 'ALL';
  double usedStorage = 0;
  double maxStorage = 0;
  bool isLoading = true;
  bool isPickingFile = false;
  File? selectedFile;
  String? fileType;

  void _loadMedicalRecords(ManagersMedicalRecord managersMedicalRecord) async {
    List<MedicalRecord> records =
        await managersMedicalRecord.getMedicalRecords();
    int totalKB = managersMedicalRecord.totalUsedMemory(records);
    double totalMB = totalKB / 1024;

    setState(() {
      myMedicalRecords = records;
      categories = managersMedicalRecord.getAllCategories(myMedicalRecords);
      filteredRecords = _filterRecords(records, selectedCategory);
      usedStorage = totalMB;
      maxStorage = ManagersMedicalRecord.maxMemory / 1024;
      isLoading = false;
    });
  }

  @override
  void initState() {
    managersMedicalRecord = ManagersMedicalRecord(
      uid: widget.userData.uid,
      name: widget.userData.name,
      medicalRecords: widget.userData.medicalRecords,
    );
    _loadMedicalRecords(managersMedicalRecord);
    super.initState();
  }

  List<MedicalRecord> _filterRecords(
    List<MedicalRecord> records,
    String category,
  ) {
    if (category == 'ALL') return records;
    return records.where((r) => r.category.toUpperCase() == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + 60),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(color: Colors.green[800]),
                )
                : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 80,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'My Medical records',
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
                          icon: Icon(
                            Iconsax.search_status_1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: size.height * 0.03),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildCategoryFilter(categories),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: size.height * 0.03),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildStorageIndicator(
                          medicalRecords: myMedicalRecords,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: size.height * 0.03),
                    ),
                    filteredRecords.isEmpty
                        ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildEmptyState(),
                          ),
                        )
                        : SliverToBoxAdapter(
                          child: AnimatedSwitcher(
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
                                      animation.status !=
                                      AnimationStatus.reverse;

                                  return Opacity(
                                    opacity:
                                        isIncoming
                                            ? animation.value.clamp(0.0, 1.0)
                                            : outAnimation.value.clamp(
                                              0.0,
                                              1.0,
                                            ),
                                    child: Transform.scale(
                                      scale:
                                          isIncoming ? inAnimation.value : 1.0,
                                      child: childWidget,
                                    ),
                                  );
                                },
                                child: child,
                              );
                            },
                            child: Wrap(
                              key: ValueKey<String>(selectedCategory),
                              spacing: 15,
                              runSpacing: 15,
                              children:
                                  filteredRecords.map((record) {
                                    return SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width -
                                              55) /
                                          2,
                                      child: _buildMedicalRecordCard(record),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                  ],
                ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
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
              onSelected:
                  (selected) => setState(() {
                    selectedCategory = categories[index];
                    _loadMedicalRecords(managersMedicalRecord);
                  }),
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

  Widget _buildStorageIndicator({required List<MedicalRecord> medicalRecords}) {
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
                      'Espace utilisé',
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
              'No medical record',
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
              'No medical file',
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
    required List<MedicalRecord> medicalRecords,
  }) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isError = false;
    String error = '';
    bool _isLoading = false;

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
                            'General information',
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
                        label: 'Title',
                        icon: Iconsax.document,
                        validator:
                            (value) => value!.isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildModernFormField(
                        controller: categoryController,
                        label: 'Category',
                        icon: Iconsax.category,
                        validator:
                            (value) => value!.isEmpty ? 'Required field' : null,
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
                                      "The creation of Medical Record : $title ?",
                                  action1: () async {
                                    await managersMedicalRecord
                                        .addMedicalRecord(title, category);
                                  },
                                  action2: () {
                                    setState(() {
                                      _loadMedicalRecords(
                                        managersMedicalRecord,
                                      );
                                    });
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
                            'Create the medical record',
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

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    final totalSizeMB = record.totalSizeInKo / 1024;
    final progressValue = (totalSizeMB / 50) * myMedicalRecords.length;

    return GestureDetector(
      onTap: () => _showMedicalRecordInfosModal(medicalRecord: record),
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
                            record.title,
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
                    record.medicalFiles.isNotEmpty
                        ? Text(
                          '+ ${record.medicalFiles.length} files...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        )
                        : Center(
                          child: Text(
                            'Aucun Fichiers',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    // const SizedBox(height: 8),
                    // ...record.medicalFiles
                    //     .take(1)
                    //     .map(
                    //       (file) => Padding(
                    //         padding: const EdgeInsets.only(bottom: 4),
                    //         child: Row(
                    //           children: [
                    //             Icon(
                    //               Iconsax.document,
                    //               color: Colors.green.shade400,
                    //               size: 14,
                    //             ),
                    //             const SizedBox(width: 8),
                    //             Flexible(
                    //               child: Text(
                    //                 '${file.title} (${file.FSize} Ko)',
                    //                 style: GoogleFonts.poppins(fontSize: 12),
                    //                 overflow: TextOverflow.ellipsis,
                    //               ),
                    //             ),
                    //             const SizedBox(width: 8),
                    //             Text(
                    //               DateFormat('dd/MM').format(
                    //                 record.medicalFiles.last.createdAt,
                    //               ),
                    //               style: GoogleFonts.poppins(
                    //                 fontSize: 10,
                    //                 color: Colors.grey,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    // if (record.medicalFiles.length > 2)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 4),
                    //     child: Text(
                    //       '+ ${record.medicalFiles.length - 1} autres...',
                    //       style: GoogleFonts.poppins(
                    //         fontSize: 10,
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordStatus(MedicalRecord record) {
    final isUpdated = record.createdAt.isAfter(
      DateTime.now().subtract(Duration(days: 7)),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUpdated ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isUpdated ? 'Récent' : 'Archive',
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: isUpdated ? Colors.green[800] : Colors.grey[600],
        ),
      ),
    );
  }

  void _showMedicalRecordInfosModal({required MedicalRecord medicalRecord}) {
    final totalSizeMB = medicalRecord.totalSizeInKo / 1024;
    bool isFromMe = medicalRecord.creatorType == CreatorType.patient;
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
                            'Medical Record details',
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
                                  if (medicalRecord.canBeShared)
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: const Icon(Iconsax.share),
                                        title: Text('Share'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(25),
                                                  ),
                                            ),
                                            builder: (
                                              BuildContext contextParent,
                                            ) {
                                              ManagersDoctors managersDoctors =
                                                  ManagersDoctors(
                                                    uid: widget.userData.uid,
                                                    name: widget.userData.name,
                                                    doctors:
                                                        widget.userData.doctors,
                                                    appointments:
                                                        widget
                                                            .userData
                                                            .appointments,
                                                    requests:
                                                        widget
                                                            .userData
                                                            .requests,
                                                  );

                                              final availableDoctors =
                                                  managersDoctors.doctors
                                                      .where(
                                                        (doctor) =>
                                                            !medicalRecord
                                                                .doctorIDs
                                                                .contains(
                                                                  doctor,
                                                                ),
                                                      )
                                                      .toList();

                                              return GestureDetector(
                                                onTap:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: Container(
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      .5,
                                                  color: Color(0x66000000),
                                                  child: GestureDetector(
                                                    onTap: () {},
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    0,
                                                                  ),
                                                            ),
                                                      ),
                                                      padding: EdgeInsets.only(
                                                        top: 24,
                                                        bottom:
                                                            MediaQuery.of(
                                                                  context,
                                                                )
                                                                .viewInsets
                                                                .bottom +
                                                            75,
                                                        right: 24,
                                                        left: 24,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 48,
                                                            height: 4,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors
                                                                      .grey[300],
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    2,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 24),

                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Iconsax.share,
                                                                color: Color(
                                                                  0xFF00C853,
                                                                ),
                                                                size: 28,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Expanded(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Select Destination Doctor',
                                                                      style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color:
                                                                            Colors.black87,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 16),

                                                          FutureBuilder<
                                                            List<Doctor>
                                                          >(
                                                            future: DoctorService()
                                                                .getDoctorsByIds(
                                                                  availableDoctors,
                                                                ),
                                                            builder: (
                                                              context,
                                                              snapshot,
                                                            ) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                );
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Center(
                                                                  child: Text(
                                                                    'Erreur: ${snapshot.error}',
                                                                  ),
                                                                );
                                                              } else if (!snapshot
                                                                      .hasData ||
                                                                  snapshot
                                                                      .data!
                                                                      .isEmpty) {
                                                                return const Center(
                                                                  child: Text(
                                                                    'Aucun médecin trouvé.',
                                                                  ),
                                                                );
                                                              }

                                                              final doctors =
                                                                  snapshot
                                                                      .data!;

                                                              return Expanded(
                                                                child: GridView.builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  physics:
                                                                      const ClampingScrollPhysics(),
                                                                  itemCount:
                                                                      doctors
                                                                          .length,
                                                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                    crossAxisCount:
                                                                        2,
                                                                    mainAxisSpacing:
                                                                        15,
                                                                    crossAxisSpacing:
                                                                        15,
                                                                    childAspectRatio:
                                                                        1,
                                                                  ),
                                                                  itemBuilder: (
                                                                    context,
                                                                    index,
                                                                  ) {
                                                                    final doctor =
                                                                        doctors[index];

                                                                    return _buildDoctorCardMove(
                                                                      doctor:
                                                                          doctor,
                                                                      medicalRecord:
                                                                          medicalRecord,
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          ),
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
                                      title: Text('Download'),
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
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        deleteMedicalRecord(
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
                      'Title : ',
                      medicalRecord.title,
                    ),
                    _buildDetailItem(
                      Iconsax.category,
                      'Category : ',
                      medicalRecord.category.toUpperCase(),
                    ),
                    _buildDetailItem(
                      Iconsax.size,
                      'Size : ',
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
                      'Creator & Share Infos',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                FutureBuilder<List<Doctor>>(
                  future: medicalRecord.getDoctors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }

                    final doctors = snapshot.data!;
                    String creator =
                        isFromMe
                            ? 'Me'
                            : '${doctors[0].name} ${doctors[0].specialty} de l\'hôpital ${doctors[0].hospital}';

                    return _buildInfoSection(
                      children: [
                        _buildDetailItem(
                          Iconsax.personalcard,
                          'Create By : ',
                          creator,
                        ),

                        _buildDetailItem(
                          Iconsax.timer,
                          'CreatedAt : ',
                          medicalRecord.formattedDate,
                        ),
                        if (isFromMe) ...[
                          for (int i = 0; i < doctors.length; i++)
                            _buildDetailItem(
                              Iconsax.personalcard,
                              'Share with : ',
                              '${doctors[i].name} ${doctors[i].specialty} de l\'hôpital ${doctors[i].hospital}',
                            ),
                        ] else ...[
                          for (int i = 1; i < doctors.length; i++)
                            _buildDetailItem(
                              Iconsax.personalcard,
                              'Share with : ',
                              '${doctors[i].name} ${doctors[i].specialty} de l\'hôpital ${doctors[i].hospital}',
                            ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Medical Files',
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
                          'Add file',
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
                            medicalRecord: medicalRecord,
                            onFileAdded: () {
                              _loadMedicalRecords(managersMedicalRecord);
                              setState(() {});

                              Future.delayed(Duration(milliseconds: 10), () {
                                _showMedicalRecordInfosModal(
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

                medicalRecord.medicalFiles.isEmpty
                    ? _buildEmptyStateMedicalFile()
                    : _buildDocumentsList(
                      isFromMe: isFromMe,
                      medicalRecord: medicalRecord,
                      medicalFiles: medicalRecord.medicalFiles,
                      onFileAdded: () {
                        _loadMedicalRecords(managersMedicalRecord);
                        setState(() {});
                        Future.delayed(Duration(milliseconds: 10), () {
                          _showMedicalRecordInfosModal(
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
    required bool isFromMe,
    required MedicalRecord medicalRecord,
    required List<MedicalFile> medicalFiles,
    required VoidCallback onFileAdded,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: medicalFiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder:
          (_, index) => _buildDocumentCard(
            isFromMe: isFromMe,
            medicalRecord: medicalRecord,
            medicalFile: medicalFiles[index],
            onFileAdded: onFileAdded,
          ),
    );
  }

  Widget _buildDocumentCard({
    required bool isFromMe,
    required MedicalRecord medicalRecord,
    required MedicalFile medicalFile,
    required VoidCallback onFileAdded,
  }) {
    bool isDeletingMedicalFile = false;
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
              '${medicalRecord.category} • ${medicalFile.formattedDate}',
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
                        'Move to Folder',
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
                                          f.creatorType == CreatorType.patient,
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
                                                    'Select Destination Folder',
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
                                          Text("Aucun Dossier Trouve"),
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
                      'Download',
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
                        'Delete',
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
                                "The delete the Medical File : ${medicalFile.title} ?",
                            action1: () async {
                              await managersMedicalRecord.removeMedicalFile(
                                medicalRecord,
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
    required MedicalRecord record,
    required MedicalRecord medicalRecordOld,
    required MedicalFile medicalFile,
    required VoidCallback onFileAdded,
    required BuildContext contextParent,
  }) {
    final totalSizeMB = record.totalSizeInKo / 1024;
    final progressValue = (totalSizeMB / 50) * myMedicalRecords.length;
    bool _isLoading = false;

    return GestureDetector(
      onTap: () {
        showDialogConfirm(
          context: context,
          contextParent: contextParent,
          msg:
              "Move The Medical File: ${medicalFile.title} to ${record.title} ?",
          action1: () async {
            await managersMedicalRecord.moveMedicalFile(
              medicalFile,
              medicalRecordOld,
              record.id,
              record.title,
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
                            record.title,
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
                    record.medicalFiles.isNotEmpty
                        ? Text(
                          '+ ${record.medicalFiles.length} files...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        )
                        : Center(
                          child: Text(
                            'Aucun Fichiers',
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
    required MedicalRecord medicalRecord,
    required VoidCallback onFileAdded,
  }) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isError = false;
    String error = '';
    bool _isLoading = false;

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
                            'General information',
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
                        label: 'Title',
                        icon: Iconsax.document,
                        validator:
                            (value) => value!.isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 20),
                      if (selectedFile != null)
                        Center(
                          child:
                              isPickingFile
                                  ? const CircularProgressIndicator()
                                  : selectedFile != null
                                  ? Text(
                                    'Fichier sélectionné: ${selectedFile!.path.split('/').last}',
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
                          label: const Text('Import a file'),
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
                                      medicalRecord,
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
                                      msg: "Create The Medical File: $title ?",
                                      action1: () async {
                                        await managersMedicalRecord
                                            .addMedicalFile(
                                              medicalRecord,
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
                                  error = "Please select a valid file";
                                  isError = true;
                                });
                              }
                            }
                          },
                          child: Text(
                            'Add the medical file',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de sélection: $e')));
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
                appBar: AppBar(title: Text("Image Preview")),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d’ouvrir le fichier.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Type de fichier non pris en charge.')),
      );
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
    required MedicalRecord medicalRecord,
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
  //   required MedicalRecord medicalRecord,
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
    required MedicalRecord medicalRecord,
    required BuildContext contextParent,
  }) {
    showDialogConfirm(
      context: context,
      contextParent: contextParent,
      msg: "Delete the Medical Record : ${medicalRecord.title} ?",
      action1: () async {
        await managersMedicalRecord.removeMedicalRecord(medicalRecord);
      },
      action2: () {
        setState(() {
          _loadMedicalRecords(managersMedicalRecord);
        });
      },
    );
  }

  Widget _buildDoctorCardMove({
    required Doctor doctor,
    required MedicalRecord medicalRecord,
  }) {
    return GestureDetector(
      onTap: () {
        shareMedicalRecord(
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
    required MedicalRecord medicalRecord,
    required Doctor doctor,
    required BuildContext contextParent,
  }) {
    showDialogConfirm(
      context: context,
      contextParent: contextParent,
      msg:
          "Share the Medical Record ${medicalRecord.title} to ${doctor.name} ?",
      action1: () async {
        await managersMedicalRecord.shareMedicalRecord(
          doctor.id,
          medicalRecord,
        );
      },
      action2: () {
        setState(() {
          _loadMedicalRecords(managersMedicalRecord);
        });
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
      appBar: AppBar(title: Text("PDF Preview")),
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
