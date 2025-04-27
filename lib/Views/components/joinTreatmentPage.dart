import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/databaseTreatments.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/components/utils.dart';

class JoinTreatmentPage extends StatefulWidget {
  final ManagersTreats managersTreats;
  final AppUserData userData;

  const JoinTreatmentPage({
    super.key,
    required this.managersTreats,
    required this.userData,
  });

  @override
  State<JoinTreatmentPage> createState() => _JoinTreatmentPageState();
}

class _JoinTreatmentPageState extends State<JoinTreatmentPage> {
  late List<Treat> publicTreatments;

  TextEditingController _controller = TextEditingController();
  String error1 = "";
  String error2 = "";
  bool isError1 = false;
  bool isError2 = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('join_treatment2'.tr(), style: GoogleFonts.poppins()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _buildProfileHeader(userData: widget.userData),
            const SizedBox(height: 16),

            Text(
              'treatment_code'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Ask for the treatment code at a public hospital, but for better monitoring consult a private doctor.",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            // Champ de code
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'treatment_code'.tr(),
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

            const SizedBox(height: 16),

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
                onPressed: _joinByCode,
              ),
            ),

            const SizedBox(height: 24),

            // Séparateur
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade400)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('or'.tr(), style: GoogleFonts.poppins()),
                ),
                Expanded(child: Divider(color: Colors.grey.shade400)),
              ],
            ),

            const SizedBox(height: 24),

            FutureBuilder(
              future: TreatmentService().getPublicTreatments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                publicTreatments = snapshot.data!;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(),
                  ),

                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<Treat>(
                    isExpanded: true,
                    hint: Text(
                      'select_treatment'.tr(),
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
                    onChanged: _joinByDropdown,
                  ),
                );
              },
            ),

            // Dropdown de traitements publics
            if (isError2 && error2.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  error2,
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),

            const SizedBox(height: 24),
            Text(
              'join_treatment_trick'.tr(),
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
              "• ${'treatment_code_trick'.tr()}",
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

  void _joinByCode() {
    setState(() {
      isLoading = true;
      isError1 = false;
      isError2 = false;
    });

    String code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() {
        error1 = 'required_field'.tr();
        isError1 = true;
        isLoading = false;
      });
      return;
    }

    bool exists = publicTreatments.any((treat) => treat.code == code);
    if (!exists) {
      setState(() {
        error1 = 'invalid_treatment_code'.tr();
        isError1 = true;
        isLoading = false;
      });
      return;
    }

    Treat treatment = publicTreatments.firstWhere(
      (treat) => treat.code == code,
    );
    bool alreadyExists = widget.managersTreats.alreadyExists(code);

    if (alreadyExists) {
      setState(() {
        error1 = 'treatment_already_added'.tr();
        isError1 = true;
        isLoading = false;
      });
      return;
    }

    // TODO: Ajouter ici ton showDialogConfirm() pour valider l'ajout
    showDialogConfirm(
      context: context,
      contextParent: context,
      msg: "${'add_treatment'.tr()} ${treatment.title} ?",
      action1: () async {
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

        await widget.managersTreats.addTreatment(t);

        await TreatmentService().addFollowerToTreatment(
          treatment.code,
          widget.managersTreats.uid,
        );
      },
      action2: () {},
    );
  }

  void _joinByDropdown(Treat? selected) {
    if (selected == null) return;

    if (widget.managersTreats.alreadyExists(selected.code)) {
      setState(() {
        error2 = 'treatment_already_added'.tr();
        isError2 = true;
      });
      return;
    }

    // TODO: Ajouter ici ton showDialogConfirm() pour valider l'ajout
    showDialogConfirm(
      context: context,
      contextParent: context,
      msg: "${'add_treatment'.tr()} ${selected.title} ?",
      action1: () async {
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
        await widget.managersTreats.addTreatment(t);
        await TreatmentService().addFollowerToTreatment(
          selected.code,
          widget.managersTreats.uid,
        );
      },
      action2: () {},
    );
  }
}
