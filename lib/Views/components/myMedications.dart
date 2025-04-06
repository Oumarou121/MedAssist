import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Medication {
  final String name;
  final String time;
  bool isTaken;

  Medication({required this.name, required this.time, this.isTaken = false});
}

class MedicationList extends StatefulWidget {
  final List<Medication> medications;

  const MedicationList({Key? key, required this.medications}) : super(key: key);

  @override
  _MedicationListState createState() => _MedicationListState();
}

class _MedicationListState extends State<MedicationList> {
  @override
  Widget build(BuildContext context) {
    final pendingMeds =
        widget.medications.where((med) => !med.isTaken).toList();
    final takenMeds = widget.medications.where((med) => med.isTaken).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade500,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingMeds.isNotEmpty) ...[
            Text(
              "💊 Médicaments en attente",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            ...pendingMeds.map((med) => _medicationItem(med)).toList(),
            SizedBox(height: 15),
          ],
          if (takenMeds.isNotEmpty) ...[
            Text(
              "✅ Médicaments pris",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            ...takenMeds.map((med) => _medicationItem(med)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _medicationItem(Medication med) {
    return ListTile(
      leading: Icon(
        Iconsax.health,
        color:
            med.isTaken ? Colors.greenAccent.shade100 : Colors.yellow.shade700,
      ),
      title: Text(
        med.name,
        style: TextStyle(
          color: Colors.white, // Texte en blanc
          decoration: med.isTaken ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        "🕒 ${med.time}",
        style: TextStyle(
          color: Colors.white70,
        ), // Sous-texte légèrement plus clair
      ),
      trailing: Theme(
        data: ThemeData(
          unselectedWidgetColor: Colors.white,
        ), // Case à cocher blanche
        child: Checkbox(
          value: med.isTaken,
          activeColor: Colors.greenAccent, // Couleur quand cochée
          checkColor: Colors.black, // Couleur de la coche
          onChanged: (bool? value) {
            setState(() {
              med.isTaken = value ?? false;
            });
          },
        ),
      ),
    );
  }
}
