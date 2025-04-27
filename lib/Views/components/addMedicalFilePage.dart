import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/medicalRecord.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/components/utils.dart';

class AddMedicalFilePage extends StatefulWidget {
  final AppUserData userData;
  final ManagersMedicalRecord managersMedicalRecord;
  final List<MedicalRecordData> myMedicalRecords;
  final MedicalRecordData medicalRecord;
  final VoidCallback onFileAdded;

  const AddMedicalFilePage({
    Key? key,
    required this.userData,
    required this.managersMedicalRecord,
    required this.myMedicalRecords,
    required this.medicalRecord,
    required this.onFileAdded,
  }) : super(key: key);

  @override
  _AddMedicalFilePageState createState() => _AddMedicalFilePageState();
}

class _AddMedicalFilePageState extends State<AddMedicalFilePage> {
  final titleController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isError = false;
  String error = '';
  bool isPickingFile = false;
  File? selectedFile;
  String? fileType;

  Future<void> _pickFile() async {
    try {
      setState(() => isPickingFile = true);

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
          final allowedExtensions = [
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
          ];

          if (allowedExtensions.contains(file.extension)) {
            setState(() {
              selectedFile = File(file.path!);
              fileType = file.extension;
              error = '';
              isError = false;
            });
          } else {
            setState(() {
              error = 'add_medical_file_trick3'.tr();
              isError = true;
            });
          }
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => isPickingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('add_medical_file'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(
                userData: widget.userData,
                title: widget.medicalRecord.medicalRecord.title,
              ),
              const SizedBox(height: 16),
              Text(
                'title'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'medical_file_title'.tr(),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildModernFormField(
                controller: titleController,
                label: 'title'.tr(),
                icon: Iconsax.document,
                validator: (value) => value!.isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 20),
              if (selectedFile != null)
                Center(
                  child:
                      isPickingFile
                          ? const CircularProgressIndicator()
                          : Text(
                            '${'selected_file'.tr()} : ${selectedFile!.path.split('/').last}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
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
                  onPressed: _pickFile,
                ),
              ),
              const SizedBox(height: 10),
              if (isError)
                Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
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
                        String exist = widget.managersMedicalRecord
                            .checkCanAddMedicalFile(
                              widget.medicalRecord.medicalRecord,
                              title,
                            );
                        if (exist == 'Success') {
                          String canAdd = await widget.managersMedicalRecord
                              .checkCanAddFile(
                                selectedFile!,
                                widget.myMedicalRecords,
                              );
                          if (canAdd == 'Success') {
                            showDialogConfirm(
                              context: context,
                              contextParent: context,
                              msg: "${'add_medical_file'.tr()} : $title ?",
                              action1: () async {
                                await widget.managersMedicalRecord
                                    .addMedicalFile(
                                      widget.medicalRecord.medicalRecord,
                                      title,
                                      fileType!,
                                      selectedFile!,
                                    );
                                widget.onFileAdded();
                                Navigator.pop(context); // Close after adding
                              },
                              action2: () {},
                            );
                          } else {
                            setState(() {
                              error = canAdd;
                              isError = true;
                            });
                          }
                        } else {
                          setState(() {
                            error = exist;
                            isError = true;
                          });
                        }
                      } else {
                        setState(() {
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
              const SizedBox(height: 24),
              Text(
                'add_medical_file_trick1'.tr(),
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),

              Text(
                "• ${'authorized_account'.tr()}",
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "• ${'add_medical_file_trick2'.tr()}",
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "• ${'add_medical_file_trick3'.tr()}",
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProfileHeader({
    required AppUserData userData,
    required String title,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey, width: .5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'login_content'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.green.shade100, Colors.green.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            userData.userSettings.profileUrl.isNotEmpty
                                ? Image.network(
                                  userData.userSettings.profileUrl,
                                  fit: BoxFit.cover,
                                )
                                : Center(
                                  child: Text(
                                    userData.name.isNotEmpty
                                        ? userData.name[0]
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      userData.email,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "${'medical_record_content'.tr()} : $title",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
