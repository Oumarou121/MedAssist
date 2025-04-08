import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/components/DailyScheduleView.dart';
import 'package:med_assist/Views/components/SchedulesView.dart';
import 'package:med_assist/Views/components/schedulePage.dart';

class TreatScreen extends StatefulWidget {
  const TreatScreen({super.key, required this.userData});
  final AppUserData userData;
  @override
  _TreatScreenState createState() => _TreatScreenState();
}

class _TreatScreenState extends State<TreatScreen> {
  final List<Treat> defaultTreatments = [
    // Treat(
    //   authorUid: 'Users0001',
    //   authorName: "Dr John",
    //   code: 'T1',
    //   title: "Traitement Hypertension",
    //   createdAt: DateTime.now(),
    //   medicines: [
    //     Medicine(
    //       name: "Amlodipine",
    //       duration: 3,
    //       count: 0,
    //       dose: "5mg",
    //       frequencyType: FrequencyType.daily,
    //       frequency: 3,
    //       intervale: 6,
    //       createAt: DateTime.now(),
    //     ),
    //   ],
    // ),
    // Treat(
    //   authorUid: 'Users0001',
    //   authorName: "Dr John",
    //   code: 'T2',
    //   title: "Diabète Type 2",
    //   createdAt: DateTime.now(),
    //   medicines: [
    //     Medicine(
    //       name: "Metformine",
    //       duration: 5,
    //       count: 1,
    //       dose: "500mg",
    //       frequencyType: FrequencyType.daily,
    //       frequency: 2,
    //       intervale: 4,
    //       createAt: DateTime.now(),
    //     ),
    //   ],
    // ),
    // Treat(
    //   authorUid: '0Z6Hs2zgCzXqzTztrvaf1y3X5wL2',
    //   authorName: "Dr John",
    //   code: 'T3',
    //   title: "Asthme",
    //   createdAt: DateTime.now().subtract(Duration(days: 2)),
    //   medicines: [
    //     Medicine(
    //       name: "Ventoline",
    //       duration: 5,
    //       count: 2,
    //       dose: "2 bouffées",
    //       frequencyType: FrequencyType.daily,
    //       frequency: 3,
    //       intervale: 4,
    //       createAt: DateTime.now(),
    //     ),
    //   ],
    // ),
    // Treat(
    //   authorUid: 'Users0001',
    //   authorName: "Dr Souleymane",
    //   code: 'T4',
    //   title: "Douleur chronique",
    //   createdAt: DateTime.now(),
    //   medicines: [
    //     Medicine(
    //       name: "Paracétamol",
    //       duration: 14,
    //       count: 0,
    //       dose: "1g",
    //       frequencyType: FrequencyType.weekly,
    //       frequency: 2,
    //       intervale: 3,
    //       createAt: DateTime.now(),
    //     ),
    //   ],
    // ),
    // Treat(
    //   authorUid: 'Users0001',
    //   authorName: "Dr Souleymane",
    //   code: 'T5',
    //   title: "Douleur chronique",
    //   createdAt: DateTime.now(),
    //   medicines: [
    //     Medicine(
    //       name: "Paracétamol 1",
    //       duration: 30,
    //       count: 0,
    //       dose: "1g",
    //       frequencyType: FrequencyType.weekly,
    //       frequency: 2,
    //       intervale: 1,
    //       createAt: DateTime.now(),
    //     ),
    //   ],
    // ),
    // Treat(
    //   authorUid: 'Users0001',
    //   authorName: "Dr Souleymane",
    //   code: 'T6',
    //   title: "Douleur chronique",
    //   createdAt: DateTime(2025, 4, 8, 23, 50),
    //   medicines: [
    //     Medicine(
    //       name: "CO2",
    //       duration: 5,
    //       count: 0,
    //       dose: "1g",
    //       frequencyType: FrequencyType.daily,
    //       frequency: 2,
    //       intervale: 6,
    //       createAt: DateTime(2025, 4, 8, 23, 50),
    //     ),
    //   ],
    // ),
    // Cas 1 : Médicament quotidien, 3 prises par jour, durée 2 jours
    Treat(
      authorUid: 'user1',
      authorName: 'Dr. Jean',
      code: 'T001',
      title: 'Traitement CO2 quotidien',
      createdAt: DateTime.now(),
      medicines: [
        Medicine(
          name: 'CO2',
          dose: '1g',
          frequency: 3,
          intervale: 3,
          duration: 7,
          frequencyType: FrequencyType.daily,
          createAt: DateTime.now(),
        ),
      ],
    ),

    // Cas 2 : Médicament hebdomadaire, 2 prises par jour, durée 10 jours
    Treat(
      authorUid: 'user2',
      authorName: 'Dr. Alice',
      code: 'T002',
      title: 'Vitamine hebdomadaire',
      createdAt: DateTime(2025, 4, 7, 10, 0),
      medicines: [
        Medicine(
          name: 'Vitamine C',
          dose: '500mg',
          frequency: 2,
          intervale: 8,
          duration: 10,
          frequencyType: FrequencyType.weekly,
          createAt: DateTime(2025, 4, 7, 10, 0),
        ),
      ],
    ),

    // Cas 3 : Médicament bihebdomadaire, 1 prise par jour, durée 30 jours
    Treat(
      authorUid: 'user3',
      authorName: 'Dr. Karim',
      code: 'T003',
      title: 'Antibiotique long terme',
      createdAt: DateTime(2025, 4, 1),
      medicines: [
        Medicine(
          name: 'Antibiotique',
          dose: '250mg',
          frequency: 1,
          intervale: 24,
          duration: 30,
          frequencyType: FrequencyType.biweekly,
          createAt: DateTime(2025, 4, 1, 7, 0),
        ),
      ],
    ),

    // Cas 4 : Médicament mensuel, 1 prise, durée 60 jours
    Treat(
      authorUid: 'user4',
      authorName: 'Dr. Leïla',
      code: 'T004',
      title: 'Injection mensuelle B12',
      createdAt: DateTime(2025, 4, 1),
      medicines: [
        Medicine(
          name: 'Injection B12',
          dose: '1ml',
          frequency: 1,
          intervale: 24,
          duration: 60,
          frequencyType: FrequencyType.monthly,
          createAt: DateTime(2025, 4, 1, 9, 0),
        ),
      ],
    ),

    // Cas 5 : Médicament trimestriel, 1 prise, durée 100 jours
    Treat(
      authorUid: 'user5',
      authorName: 'Dr. Nadir',
      code: 'T005',
      title: 'Vaccination préventive',
      createdAt: DateTime(2025, 3, 20),
      medicines: [
        Medicine(
          name: 'Vaccin',
          dose: '5ml',
          frequency: 1,
          intervale: 24,
          duration: 100,
          frequencyType: FrequencyType.quarterly,
          createAt: DateTime(2025, 3, 20, 14, 0),
        ),
      ],
    ),
  ];
  late ManagersTreats managersTreats;
  List<Medicine> medicines = [];
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> durationControllers = [];
  List<TextEditingController> doseControllers = [];
  List<TextEditingController> frequencyControllers = [];
  List<TextEditingController> intervaleControllers = [];

  @override
  void initState() {
    managersTreats = ManagersTreats(
      uid: widget.userData.uid,
      name: widget.userData.name,
      treats: [...defaultTreatments],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding + 60),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _top(),
                  SizedBox(height: size.height * 0.03),
                  Column(children: _buildTreatmentSections()),
                ],
              ),
            ),
          ),
        ),
      ),
      // SchedulePage(manager: managersTreats),
    );
  }

  Widget _top() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "My Treatment",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: IconButton(
            onPressed: () => _showTreatmentOptionsModal(),
            icon: Icon(Iconsax.more, color: Colors.black),
          ),
        ),
      ],
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

  void _showTreatmentOptionsModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
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
              ListTile(
                leading: Icon(Icons.add, color: Colors.blue),
                title: Text(
                  "Créer un nouveau traitement",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTreatmentModal();
                },
              ),
              ListTile(
                leading: Icon(Icons.link, color: Colors.green),
                title: Text(
                  "Rejoindre un traitement existant",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showJoinTreatmentModal();
                },
              ),

              ListTile(
                leading: Icon(Icons.event_note, color: Colors.purple),
                title: Text(
                  "Planning des traitements",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showScheduleModal(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: SchedulePage(manager: managersTreats),
          ),
        );
      },
    );
  }

  _showTreatmentInfosModal({
    required BuildContext context,
    required Treat treat,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxModalHeight = screenHeight * 0.75;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 60,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxModalHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title of the modal
                  Text(
                    'Traitement : ${treat.title}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Treatment Information Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Code', treat.code),
                          _buildInfoRow('Durée', '${treat.duration} jours'),
                          _buildInfoRow(
                            'Date de début',
                            formatDate(treat.createdAt),
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          _buildInfoRow(
                            'État du traitement',
                            !treat.isActive() ? 'Terminé' : 'En cours',
                            style: TextStyle(
                              color:
                                  !treat.isActive()
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Medications Information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Médicaments prescrits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      treat.authorUid == widget.userData.uid
                          ? TextButton(
                            onPressed:
                                () => _showAddMedicineModal(treat: treat),
                            child: Text(
                              "Ajouter un médicament",
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                          : SizedBox(),
                    ],
                  ),
                  SizedBox(height: 10),

                  ...treat.medicines.map((medicine) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nom : ${medicine.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              _buildInfoRow(
                                'Durée',
                                '${medicine.duration} jours',
                              ),
                              _buildInfoRow(
                                'Nombre de prise',
                                '${medicine.count}/${medicine.maxCount}',
                                style: TextStyle(color: Colors.green),
                              ),
                              LinearProgressIndicator(
                                value: medicine.count / medicine.maxCount,
                                backgroundColor: Colors.grey[300],
                                color: Colors.green,
                              ),
                              SizedBox(height: 5),
                              _buildInfoRow('Dose', medicine.dose),
                              _buildInfoRow(
                                'Fréquence',
                                medicine.formattedFrequency,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: style ?? TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinTreatmentModal() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController _controller = TextEditingController();
        String error1 = "";
        String error2 = "";
        bool isError1 = false;
        bool isError2 = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Rejoindre un traitement",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Code du traitement",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: isError1 ? error1 : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        String code = _controller.text.trim();

                        if (code.isEmpty) {
                          setModalState(() {
                            error1 = "Veuillez entrer un code.";
                            isError1 = true;
                          });
                          return;
                        }

                        bool exists = defaultTreatments.any(
                          (treat) => treat.code == code,
                        );

                        if (!exists) {
                          setModalState(() {
                            error1 = "Traitement non trouvé";
                            isError1 = true;
                          });
                          return;
                        }

                        Treat treatment = defaultTreatments.firstWhere(
                          (treat) => treat.code == code,
                        );

                        bool alreadyExists = managersTreats.alreadyExists(code);

                        if (alreadyExists) {
                          setModalState(() {
                            error1 = "Ce traitement existe déjà";
                            isError1 = true;
                          });
                          return;
                        }

                        Navigator.pop(context);
                        setState(() {
                          List<Medicine> ms = [];

                          Treat t = new Treat(
                            authorName: treatment.authorName,
                            authorUid: treatment.authorName,
                            code: treatment.code,
                            title: treatment.title,
                            medicines: ms,
                            createdAt: DateTime.now(),
                          );

                          for (Medicine m in treatment.medicines) {
                            t.addMedicine(m);
                          }

                          // treatments.add(t);
                          managersTreats.addTreatment(t);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Traitement ajouté avec succès !"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Text("Rejoindre"),
                    ),
                    SizedBox(height: 20),
                    Text("Ou sélectionnez un traitement de base :"),
                    SizedBox(height: 10),
                    DropdownButton<Treat>(
                      hint: Text("Sélectionner un traitement"),
                      onChanged: (Treat? selected) {
                        if (selected == null) return;

                        bool alreadyExists = managersTreats.alreadyExists(
                          selected.code,
                        );

                        if (alreadyExists) {
                          setModalState(() {
                            error2 = "Ce traitement est déjà dans la liste";
                            isError2 = true;
                          });
                          return;
                        }

                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text("Confirmation"),
                                content: Text(
                                  "Voulez-vous ajouter le traitement ${selected.title} de ${selected.authorName} ?",
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("Annuler"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text("Ajouter"),
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                      ); // Ferme le dialogue
                                      Navigator.pop(context); // Ferme le modal
                                      setState(() {
                                        List<Medicine> ms = [];

                                        Treat t = new Treat(
                                          authorName: selected.authorName,
                                          authorUid: selected.authorName,
                                          code: selected.code,
                                          title: selected.title,
                                          medicines: ms,
                                          createdAt: DateTime.now(),
                                        );

                                        for (Medicine m in selected.medicines) {
                                          t.addMedicine(m);
                                        }

                                        // treatments.add(t);
                                        managersTreats.addTreatment(t);
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Traitement ajouté avec succès !",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                        );
                      },
                      items:
                          defaultTreatments.map((Treat treat) {
                            return DropdownMenuItem<Treat>(
                              value: treat,
                              child: Text(treat.title),
                            );
                          }).toList(),
                    ),
                    if (isError2 && error2.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          error2,
                          style: TextStyle(color: Colors.red),
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

  Widget _buildMedicineForm(
    Medicine medicine,
    int index,
    StateSetter setModalState,
  ) {
    return Form(
      key: medicine.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(height: 10),

          // Nom
          TextFormField(
            controller: nameControllers[index],
            decoration: InputDecoration(
              labelText: "Nom du médicament",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est requis';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.name = value;
              });
            },
          ),
          SizedBox(height: 10),

          // Dose
          TextFormField(
            controller: doseControllers[index],
            decoration: InputDecoration(
              labelText: "Dose",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La dose est requise';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.dose = value;
              });
            },
          ),
          SizedBox(height: 10),

          // Fréquence (nombre)
          TextFormField(
            controller: frequencyControllers[index],
            decoration: InputDecoration(
              labelText: "Fréquence (nombre de fois)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La fréquence est requise';
              }
              final parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Valeur invalide';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.frequency = int.tryParse(value) ?? 1;
              });
            },
          ),
          SizedBox(height: 10),

          // Type de fréquence
          DropdownButtonFormField<FrequencyType>(
            value: medicine.frequencyType,
            decoration: InputDecoration(
              labelText: "Type de fréquence",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items:
                FrequencyType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.unitLabel),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setModalState(() {
                  medicine.frequencyType = value;
                });
              }
            },
          ),
          SizedBox(height: 10),

          TextFormField(
            controller: intervaleControllers[index],
            decoration: InputDecoration(
              labelText: "Intervale de prise",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "L'intervale est requise";
              }
              final parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Valeur invalide';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.intervale = int.tryParse(value) ?? 1;
              });
            },
          ),
          SizedBox(height: 10),
          // Durée
          TextFormField(
            controller: durationControllers[index],
            decoration: InputDecoration(
              labelText: "Durée (jours)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La durée est requise';
              }
              final parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Entrez un nombre valide';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.duration = int.tryParse(value) ?? 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddMedicineForm(
    Medicine medicine,
    StateSetter setModalState,
    TextEditingController nameControllerAdd,
    TextEditingController doseControllerAdd,
    TextEditingController frequencyControllerAdd,
    TextEditingController durationControllerAdd,
    TextEditingController intervaleControllerAdd,
  ) {
    return Form(
      key: medicine.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom
          TextFormField(
            controller: nameControllerAdd,
            decoration: InputDecoration(
              labelText: "Nom du médicament",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est requis';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.name = value;
              });
            },
          ),
          SizedBox(height: 10),

          // Dose
          TextFormField(
            controller: doseControllerAdd,
            decoration: InputDecoration(
              labelText: "Dose",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La dose est requise';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.dose = value;
              });
            },
          ),
          SizedBox(height: 10),

          // Fréquence (nombre)
          TextFormField(
            controller: frequencyControllerAdd,
            decoration: InputDecoration(
              labelText: "Fréquence (nombre de fois)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La fréquence est requise';
              }
              final parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Valeur invalide';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.frequency = int.tryParse(value) ?? 1;
              });
            },
          ),
          SizedBox(height: 10),

          // Type de fréquence
          DropdownButtonFormField<FrequencyType>(
            value: medicine.frequencyType,
            decoration: InputDecoration(
              labelText: "Type de fréquence",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items:
                FrequencyType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.unitLabel),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setModalState(() {
                  medicine.frequencyType = value;
                });
              }
            },
          ),

          SizedBox(height: 10),

          TextFormField(
            controller: intervaleControllerAdd,
            decoration: InputDecoration(
              labelText: "Intervale de prise",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "L'intervale est requise";
              }
              final parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Entrez un nombre valide';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.intervale = int.tryParse(value) ?? 1;
              });
            },
          ),
          SizedBox(height: 10),

          // Durée
          TextFormField(
            controller: durationControllerAdd,
            decoration: InputDecoration(
              labelText: "Durée (jours)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La durée est requise';
              }
              final parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Entrez un nombre valide';
              }
              return null;
            },
            onChanged: (value) {
              setModalState(() {
                medicine.duration = int.tryParse(value) ?? 1;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddMedicineModal({required Treat treat}) {
    Medicine medicine = Medicine(
      name: "",
      duration: 0,
      dose: "",
      frequency: 0,
      frequencyType: FrequencyType.daily,
      intervale: 0,
      createAt: DateTime.now(),
    );
    final nameControllerAdd = TextEditingController();
    final doseControllerAdd = TextEditingController();
    final frequencyControllerAdd = TextEditingController();
    final durationControllerAdd = TextEditingController();
    final intervaleControllerAdd = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Ajouter un Medicament",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildAddMedicineForm(
                        medicine,
                        setModalState,
                        nameControllerAdd,
                        doseControllerAdd,
                        frequencyControllerAdd,
                        durationControllerAdd,
                        intervaleControllerAdd,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final isValid =
                              medicine.formKey.currentState?.validate() ??
                              false;

                          if (isValid) {
                            final name = nameControllerAdd.text.trim();
                            final durationText =
                                durationControllerAdd.text.trim();
                            final dose = doseControllerAdd.text.trim();
                            final frequencyText =
                                frequencyControllerAdd.text.trim();
                            final intervaleText =
                                intervaleControllerAdd.text.trim();

                            final int duration = int.parse(durationText);
                            final int frequency = int.parse(frequencyText);
                            final int intervale = int.parse(intervaleText);
                            Medicine m = Medicine(
                              name: name,
                              duration: duration,
                              count: 0,
                              dose: dose,
                              frequency: frequency,
                              frequencyType: medicine.frequencyType,
                              intervale: intervale,
                              createAt: DateTime.now(),
                            );
                            setState(() {
                              treat.addMedicine(m);
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text("Créer le traitement"),
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

  void _showAddTreatmentModal() {
    medicines = [];
    nameControllers = [];
    intervaleControllers = [];
    durationControllers = [];
    doseControllers = [];
    frequencyControllers = [];
    String error = "";
    bool isError = false;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Ajouter un traitement",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 400, // ou 600.0 par ex.
                          maxWidth:
                              MediaQuery.of(context).size.width *
                              0.9, // ou 400.0 par ex.
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: "Titre du traitement",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorText: isError ? error : null,
                                ),
                              ),
                              SizedBox(height: 20),
                              Column(
                                children: List.generate(medicines.length, (
                                  index,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: _buildMedicineForm(
                                      medicines[index],
                                      index,
                                      setModalState,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setModalState(() {
                            _addMedicine();
                          });
                        },
                        child: Text("Ajouter un médicament"),
                      ),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
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

                              for (int i = 0; i < nameControllers.length; i++) {
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
                                      frequencyType: medicines[i].frequencyType,
                                      intervale: interval,
                                      createAt: DateTime.now(),
                                    ),
                                  );
                                }
                              }

                              if (meds.isNotEmpty) {
                                Treat newTreatment = Treat(
                                  authorUid: widget.userData.uid,
                                  authorName: 'Mr/Mm ${widget.userData.name}',
                                  code:
                                      'TREAT-${DateTime.now().millisecondsSinceEpoch}',
                                  title: titleController.text.trim(),
                                  medicines: meds,
                                  createdAt: DateTime.now(),
                                );

                                Navigator.pop(context);
                                setState(() {
                                  // treatments.add(newTreatment);
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
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Veuillez remplir tous les champs correctement.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setModalState(() {
                                isError = false;
                                error = "";
                              });
                            }
                          } else {
                            setModalState(() {
                              isError = true;
                              error = "Veuillez remplir tous les champs.";
                            });
                          }
                        },

                        child: Text("Créer le traitement"),
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

  List<Widget> _buildTreatmentSections() {
    final activeTreatments = managersTreats.activeTreatments();
    final finishedTreatments = managersTreats.finishedTreatments();
    return [
      if (activeTreatments.isNotEmpty) ...[
        Text(
          "En cours",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ..._buildTreatmentList(activeTreatments),
      ],
      if (finishedTreatments.isNotEmpty) ...[
        SizedBox(height: 20),
        Text(
          "Terminés",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ..._buildTreatmentList(finishedTreatments),
      ],
    ];
  }

  List<Widget> _buildTreatmentList(List<Treat> list) {
    return list
        .map(
          (treat) => GestureDetector(
            onTap:
                () => _showTreatmentInfosModal(context: context, treat: treat),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          treat.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Confirmation dialog
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text("Confirmation"),
                                    content:
                                        treat.authorUid == widget.userData.uid
                                            ? Text(
                                              "Voulez-vous supprimer votre traitement ${treat.title} ?",
                                            )
                                            : Text(
                                              "Voulez-vous quitter le traitement ${treat.title} de ${treat.authorName} ?",
                                            ),
                                    actions: [
                                      TextButton(
                                        child: Text("Non"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Text("Oui"),
                                        onPressed: () {
                                          Navigator.pop(
                                            context,
                                          ); // Ferme le dialogue
                                          setState(() {
                                            managersTreats.removeTreatment(
                                              treat,
                                            );
                                          });

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                treat.authorUid ==
                                                        widget.userData.uid
                                                    ? "Traitement supprimé avec succès !"
                                                    : "Traitement quitté avec succès !",
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                            );
                          },
                          icon: Icon(Iconsax.heart_remove, color: Colors.red),
                        ),
                      ],
                    ),
                    // Affichage du statut (Actif ou Terminé)
                    Text(
                      treat.isActive() ? "Actif" : "Terminé",
                      style: TextStyle(
                        color: treat.isActive() ? Colors.green : Colors.red,
                      ),
                    ),
                    // Liste des médicaments
                    ...treat.medicines.asMap().entries.map((entry) {
                      // int index = entry.key;
                      var med = entry.value;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(med.name),
                        subtitle: Text(
                          "${med.dose} - ${med.formattedFrequency}",
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}
