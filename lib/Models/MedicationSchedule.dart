import 'package:flutter/material.dart';

class MedicationSchedule {
  final String medicationName;
  final List<MedicationTime> times; // Liste des heures de prise
  final String status; // "Pris" ou "En attente"

  MedicationSchedule({
    required this.medicationName,
    required this.times,
    required this.status,
  });
}

class MedicationTime {
  final TimeOfDay time; // Heure de prise du médicament
  final bool isTaken; // True si pris, false sinon

  MedicationTime({required this.time, required this.isTaken});
}
