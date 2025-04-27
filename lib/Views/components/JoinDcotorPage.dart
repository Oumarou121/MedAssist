import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/user.dart';

class JoinDoctorPage extends StatefulWidget {
  final ManagersDoctors managersDoctors;
  final AppUserData userData;

  const JoinDoctorPage({
    Key? key,
    required this.managersDoctors,
    required this.userData,
  }) : super(key: key);

  @override
  _JoinDoctorPageState createState() => _JoinDoctorPageState();
}

class _JoinDoctorPageState extends State<JoinDoctorPage> {
  final TextEditingController _controller = TextEditingController();
  String error1 = "";
  bool isError1 = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('send_request_title'.tr(), style: GoogleFonts.poppins()),
        // backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(userData: widget.userData),
              const SizedBox(height: 16),
              Text(
                'doctor_id'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'send_request_content'.tr(),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'doctor_id'.tr(),
                  prefixIcon: Icon(Iconsax.code, color: Colors.grey.shade600),
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

              const SizedBox(height: 24),

              // Bouton Rejoindre
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon:
                      isLoading
                          ? const SizedBox.shrink()
                          : const Icon(
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
                  onPressed: _sendRequest,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'send_request_trick'.tr(),
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
                "• ${'doctor_id_trick'.tr()}",
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

  Widget _buildProfileHeader({required AppUserData userData}) {
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
          ],
        ),
      ),
    );
  }

  void _sendRequest() async {
    setState(() {
      isLoading = true;
      isError1 = false;
    });
    String code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() {
        error1 = 'required_doctor_id'.tr();
        isError1 = true;
        isLoading = false;
      });
      return;
    }
    String result = await widget.managersDoctors.checkSendJoinDoctorRequest(
      code,
    );
    List<String> parts = result.split('/');

    if (parts.isNotEmpty && parts[0] == "Success") {
      String doctorName = parts.length > 1 ? parts[1] : "Inconnu";
      setState(() {
        isLoading = false;
      });
      _showConfirmDialog(code, doctorName);
    } else {
      setState(() {
        error1 = result;
        isError1 = true;
        isLoading = false;
      });
    }
  }

  void _showConfirmDialog(String code, String doctorName) {
    showDialog(
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          title: Text('confirmation'.tr(), style: GoogleFonts.poppins()),
          content: Text(
            "${'tracking_request'.tr()} $doctorName ?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(contextDialog).pop(); // Fermer le dialog
                await widget.managersDoctors.sendJoinDoctorRequest(code);
                Navigator.of(context).pop(); // Fermer la page après succès
              },
              child: Text(
                'yes'.tr(),
                style: GoogleFonts.poppins(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(contextDialog).pop(); // Juste fermer
              },
              child: Text(
                'no'.tr(),
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
