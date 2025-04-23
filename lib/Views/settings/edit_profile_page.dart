import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/storageService.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/components/utils.dart';
import 'package:med_assist/Views/mainScreen.dart';

class EditProfilePage extends StatefulWidget {
  final AppUserData userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _phoneController = TextEditingController(text: widget.userData.phoneNumber);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
      Navigator.pop(context);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialogConfirm(
        isAlert: true,
        context: context,
        contextParent: null,
        msg: "confirm_change_profile".tr(),
        action1: () async {
          AppUserData _userData = widget.userData;

          final DatabaseService db = DatabaseService(_userData.uid);

          final name = _nameController.text.trim();
          final phoneNumber = _phoneController.text.trim();

          if (name != _userData.name) {
            db.updateDataOfValue("name", name);
          }

          if (phoneNumber != _userData.phoneNumber) {
            db.updateDataOfValue("phoneNumber", phoneNumber);
          }

          final storage = StorageService();

          if (_profileImage != null) {
            if (_userData.userSettings.profileUrl != '') {
              await storage.deleteProfileImage(
                _userData.userSettings.profileUrl,
              );
            }
            String url = await storage.uploadProfileImage(
              file: _profileImage!,
              uid: _userData.uid,
            );

            await db.updateUserSetting("profileUrl", url);
          }
        },
        action2: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(initialIndex: 4),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'change_profile'.tr(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.04),
              _ProfileHeader(
                userData: widget.userData,
                onPressed: _showImagePicker,
                profileImage: _profileImage,
              ),
              SizedBox(height: size.height * 0.06),
              _buildFullNameTextField(),
              SizedBox(height: size.height * 0.03),
              _buildPhoneNumberTextField(),
              SizedBox(height: size.height * 0.05),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => _ImagePickerBottomSheet(
            onCameraPressed: () => _pickImage(ImageSource.camera),
            onGalleryPressed: () => _pickImage(ImageSource.gallery),
          ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Color(0xFF00C853),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          'save_changes'.tr(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameTextField() {
    return _CustomTextField(
      controller: _nameController,
      label: 'full_name'.tr(),
      icon: Iconsax.user,
      validator: (value) => value!.length < 4 ? 'required'.tr() : null,
    );
  }

  Widget _buildPhoneNumberTextField() {
    return _CustomTextField(
      controller: _phoneController,
      label: 'phone_number'.tr(),
      icon: Iconsax.call,
      keyboardType: TextInputType.phone,
      validator:
          (value) => value!.length < 8 ? 'invalid_phone_number'.tr() : null,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppUserData userData;
  final VoidCallback onPressed;
  final File? profileImage;

  const _ProfileHeader({
    required this.userData,
    required this.onPressed,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
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
          width: 140,
          height: 140,
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
                profileImage != null
                    ? Image.file(profileImage!, fit: BoxFit.cover)
                    : userData.userSettings.profileUrl.isNotEmpty
                    ? Image.network(
                      userData.userSettings.profileUrl,
                      fit: BoxFit.cover,
                    )
                    : Center(
                      child: Text(
                        userData.name.isNotEmpty ? userData.name[0] : '?',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton.small(
            onPressed: onPressed,
            backgroundColor: Color(0xFF00C853),
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

class _ImagePickerBottomSheet extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const _ImagePickerBottomSheet({
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 75,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'change_profile_picture'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Iconsax.camera, color: Color(0xFF00C853)),
            title: Text(
              'take_picture'.tr(),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            onTap: onCameraPressed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: Icon(Iconsax.gallery, color: Color(0xFF00C853)),
            title: Text(
              'choose_from_gallery'.tr(),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            onTap: onGalleryPressed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Color(0xFF00C853)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF00C853), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.red),
      ),
      validator: validator,
    );
  }
}
