import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/Models/medicalRecord.dart';
import 'package:med_assist/Models/user.dart';

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
  String selectedCategory = 'All';
  double usedStorage = 0;
  double maxStorage = 50;
  bool isLoading = true;

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
      maxStorage = ManagersMedicalRecord.maxMemory;
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
    if (category == 'All') return records;
    return records.where((r) => r.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;
    ManagersMedicalRecord managersMedicalRecord = ManagersMedicalRecord(
      uid: widget.userData.uid,
      name: widget.userData.name,
      medicalRecords: widget.userData.medicalRecords,
    );

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
                          managersMedicalRecord: managersMedicalRecord,
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
    required List<MedicalRecord> medicalRecords,
  }) {
    final double usedPercentage = usedStorage / maxStorage;
    final double usedInMo = usedStorage / 1024;
    final double maxInMo = maxStorage / 1024;

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
                      '${usedInMo.toStringAsFixed(1)} Mo / ${maxInMo.toStringAsFixed(1)} Mo',
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
    required ManagersMedicalRecord managersMedicalRecord,
    required List<MedicalRecord> medicalRecords,
  }) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
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
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Iconsax.add,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Create the medical record',
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
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              String title = titleController.text.trim();
                              String category = categoryController.text.trim();

                              String exist = await managersMedicalRecord
                                  .checkMedicalRecord(title, medicalRecords);
                              if (exist == 'Success') {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xFFF5F7FB),
                                                Colors.white,
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Iconsax.info_circle,
                                                size: 40,
                                                color: Color(0xFF00C853),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                "Do you want to create the",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Medical Record: $title ?",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(),
                                              ),
                                              const SizedBox(height: 24),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF00C853,
                                                                ),
                                                          ),
                                                      child: const Text(
                                                        "Confirm",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        await managersMedicalRecord
                                                            .addMedicalRecord(
                                                              title,
                                                              category,
                                                            );
                                                        _loadMedicalRecords(
                                                          managersMedicalRecord,
                                                        );
                                                        Navigator.pop(context);
                                                        Navigator.pop(
                                                          contextParent,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                );
                              } else {
                                setModalState(() {
                                  error = exist;
                                  isError = true;
                                });
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
    final progressValue = totalSizeMB / 50;
    final fileCount = record.medicalFiles.length;

    return GestureDetector(
      onTap: () => _showMedicalRecordInfosModal(medicalRecord: record),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
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
                            record.title,
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
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fichiers récents :',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...record.medicalFiles
                            .take(2)
                            .map(
                              (file) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.document,
                                      color: Colors.green.shade400,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${file.title} (${(file.fileSize / 1024).toStringAsFixed(1)} Ko)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'dd/MM',
                                      ).format(file.createdAt),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        if (fileCount > 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+ ${fileCount - 2} autres...',
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
              ),
            ],
          ),
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
          width: MediaQuery.of(context).size.width,
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Détails du dossier',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Iconsax.card_remove, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

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
                      medicalRecord.category,
                    ),

                    _buildDetailItem(
                      Iconsax.timer,
                      'CreatedAt : ',
                      medicalRecord.formattedDate,
                    ),
                    _buildDetailItem(
                      Iconsax.size,
                      'Size : ',
                      '${totalSizeMB.toStringAsFixed(1)} Mo',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

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
                          medicalRecords: myMedicalRecords,
                          managersMedicalRecord: managersMedicalRecord,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                medicalRecord.medicalFiles.isEmpty
                    ? _buildEmptyStateMedicalFile()
                    : _buildDocumentsList(
                      medicalFiles: medicalRecord.medicalFiles,
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

  Widget _buildInfoSection({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
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
    );
  }

  Widget _buildDocumentsList({required List<MedicalFile> medicalFiles}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: medicalFiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _buildDocumentCard(medicalFiles[index]),
    );
  }

  Widget _buildDocumentCard(MedicalFile medicalFile) {
    return Card(
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
            // Text(
            //   '${medicalFile.type} • ${medicalFile.formattedDate}',
            //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
            // ),
            Text(
              '${medicalFile.fileSize / 1024} Ko',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.remove_red_eye),
                    title: Text('Prévisualiser'),
                    onTap: () {},
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.share),
                    title: Text('Partager'),
                    onTap: () {},
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {},
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
    } else if (lower == '.png' ||
        lower == 'jpg' ||
        lower == 'jpeg' ||
        lower == 'webp' ||
        lower == 'bmp' ||
        lower == 'gif') {
      return Colors.green[400]!;
    } else {
      return Colors.blue[400]!;
    }
  }

  IconData _getFileTypeIcon(String type) {
    final lower = type.toLowerCase();

    if (lower == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (lower == 'png' ||
        lower == 'jpg' ||
        lower == 'jpeg' ||
        lower == 'webp' ||
        lower == 'bmp' ||
        lower == 'gif') {
      return Icons.image;
    } else {
      return Icons.insert_drive_file;
    }
  }

  void _showAddMedicalFileModal({
    required ManagersMedicalRecord managersMedicalRecord,
    required List<MedicalRecord> medicalRecords,
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
                      _buildFileUploadSection(
                        medicalFile: MedicalFile(
                          title: 'title',
                          fileType: '',
                          fileUrl: '',
                          fileSize: 0,
                          createdAt: DateTime.now(),
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
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Iconsax.add,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Create the medical record',
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
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              String title = titleController.text.trim();

                              String exist = await managersMedicalRecord
                                  .checkMedicalRecord(title, medicalRecords);
                              if (exist == 'Success') {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xFFF5F7FB),
                                                Colors.white,
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Iconsax.info_circle,
                                                size: 40,
                                                color: Color(0xFF00C853),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                "Do you want to create the",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Medical Record: $title ?",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(),
                                              ),
                                              const SizedBox(height: 24),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF00C853,
                                                                ),
                                                          ),
                                                      child: const Text(
                                                        "Confirm",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        // await managersMedicalRecord
                                                        //     .addMedicalRecord(
                                                        //       title,
                                                        //       category,
                                                        //     );
                                                        _loadMedicalRecords(
                                                          managersMedicalRecord,
                                                        );
                                                        Navigator.pop(context);
                                                        Navigator.pop(
                                                          contextParent,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                );
                              } else {
                                setModalState(() {
                                  error = exist;
                                  isError = true;
                                });
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

  File? _selectedFile;
  String? _fileType;
  Widget _buildFileUploadSection({required MedicalFile medicalFile}) {
    return Center(
      child: Column(
        children: [
          if (_selectedFile != null) ...[
            _buildFilePreview(medicalFile),
            const SizedBox(height: 15),
          ],
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Import a file'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _pickFile,
          ),
          if (_selectedFile != null)
            Text(
              'Fichier sélectionné: ${_selectedFile!.path.split('/').last}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedFile = File(file.path!);
            _fileType = file.extension;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de sélection: $e')));
    }
  }

  Widget _buildFilePreview(MedicalFile medicalFile) {
    return switch (medicalFile.fileType.toLowerCase()) {
      'pdf' => PdfViewerWidget(url: medicalFile.fileUrl),
      'image' => InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Image.network(
          medicalFile.fileUrl,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 300,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value:
                    progress.cumulativeBytesLoaded /
                    (progress.expectedTotalBytes ?? 1),
              ),
            );
          },
          errorBuilder:
              (context, error, stackTrace) => _ErrorPlaceholder(
                message: 'Erreur de chargement',
                icon: Icons.image_not_supported_rounded,
              ),
        ),
      ),
      _ => _ErrorPlaceholder(
        message: 'Aperçu non disponible',
        icon: Icons.visibility_off_rounded,
      ),
    };
  }
}

class PdfViewerWidget extends StatefulWidget {
  final String url;

  const PdfViewerWidget({super.key, required this.url});

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  late PDFDocument document;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      document = await PDFDocument.fromURL(widget.url);
      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      //picture_as_pdf_off_rounded
      return _ErrorPlaceholder(
        message: 'Erreur de chargement',
        icon: Icons.picture_as_pdf,
      );
    }

    return SizedBox(
      height: 500,
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : PDFViewer(
                document: document,
                scrollDirection: Axis.vertical,
                lazyLoad: false,
                indicatorBackground:
                    Theme.of(context).colorScheme.primaryContainer,
                indicatorText: Theme.of(context).colorScheme.onPrimaryContainer,
                progressIndicator: const CircularProgressIndicator(),
              ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final String message;
  final IconData icon;

  const _ErrorPlaceholder({Key? key, required this.message, required this.icon})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
