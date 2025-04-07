import 'package:flutter/material.dart';

class Treat {
  final String authorUid;
  final String authorName;
  final String code;
  final String title;
  final List<Medicine> medicines;
  final int count;
  final DateTime createdAt;

  Treat({
    required this.authorUid,
    required this.authorName,
    required this.code,
    required this.title,
    required this.medicines,
    required this.count,
    required this.createdAt,
  });

  int get duration {
    return medicines.isEmpty
        ? 0
        : medicines
            .map((medicine) => medicine.duration)
            .reduce((a, b) => a > b ? a : b);
  }

  bool isActive() {
    final endDate = createdAt.add(Duration(days: duration));
    return DateTime.now().isBefore(endDate);
  }

  void addMedicine(Medicine med) {
    Medicine m = new Medicine(
      name: med.name,
      duration: med.duration,
      count: 0,
      dose: med.dose,
      frequencyType: med.frequencyType,
      frequency: med.frequency,
    );
    medicines.add(m);
  }
}

class Medicine {
  String name;
  int duration;
  String dose;
  int frequency;
  FrequencyType frequencyType;
  int count;
  final GlobalKey<FormState> formKey;

  Medicine({
    required this.name,
    required this.duration,
    required this.dose,
    required this.frequency,
    required this.frequencyType,
    this.count = 0,
  }) : formKey = GlobalKey<FormState>();
}

enum FrequencyType { daily, weekly, biweekly, monthly, quarterly }

extension FrequencyTypeExtension on FrequencyType {
  String get unitLabel {
    switch (this) {
      case FrequencyType.daily:
        return "jour";
      case FrequencyType.weekly:
        return "semaine";
      case FrequencyType.biweekly:
        return "2 semaines";
      case FrequencyType.monthly:
        return "mois";
      case FrequencyType.quarterly:
        return "3 mois";
    }
  }
}

extension MedicineFormatter on Medicine {
  String get formattedFrequency {
    String unit = frequencyType.unitLabel;
    if (frequency > 1 && !unit.contains("2") && !unit.contains("3")) {
      unit += "s";
    }
    return "${frequency}x/$unit";
  }
}
