import 'package:flutter/material.dart';

class ManagersTreats {
  final String uid;
  final String name;
  final List<Treat> treats;

  ManagersTreats({required this.uid, required this.name, required this.treats});

  List<Treat> activeTreatments() {
    return treats.where((t) => t.isActive()).toList();
  }

  List<Treat> finishedTreatments() {
    return treats.where((t) => !t.isActive()).toList();
  }

  void addTreatment(Treat treat) {
    treats.add(treat);
  }

  void removeTreatment(Treat treat) {
    treats.remove(treat);
  }

  bool alreadyExists(String code) {
    return treats.any((treat) => treat.code == code);
  }

  ManagersSchedule generateSchedule() {
    final Map<DateTime, List<ScheduleItem>> scheduleMap = {};

    for (final treat in treats) {
      final startDate = treat.createdAt;

      for (final med in treat.medicines) {
        for (int i = 0; i < med.duration; i++) {
          DateTime currentDate = startDate.add(Duration(days: i));
          bool shouldAdd = false;

          switch (med.frequencyType) {
            case FrequencyType.daily:
              shouldAdd = true;
              break;
            case FrequencyType.weekly:
              shouldAdd = i % 7 == 0;
              break;
            case FrequencyType.biweekly:
              shouldAdd = i % 14 == 0;
              break;
            case FrequencyType.monthly:
              shouldAdd = i % 30 == 0;
              break;
            case FrequencyType.quarterly:
              shouldAdd = i % 90 == 0;
              break;
          }

          if (!shouldAdd) continue;

          DateTime baseTime = med.createAt.add(Duration(days: i, minutes: 5));
          for (int j = 0; j < med.frequency; j++) {
            DateTime doseTime = baseTime.add(
              med.frequencyType == FrequencyType.daily
                  ? Duration(hours: j * med.intervale)
                  : Duration(days: j * med.intervale),
            );

            DateTime scheduleDate = DateTime(
              doseTime.year,
              doseTime.month,
              doseTime.day,
            );

            final formattedTime = _formatTime(doseTime);

            if (!scheduleMap.containsKey(scheduleDate)) {
              scheduleMap[scheduleDate] = [];
            }

            final existingItem = scheduleMap[scheduleDate]!.firstWhere(
              (item) => item.name == med.name && item.dose == med.dose,
              orElse: () {
                final newItem = ScheduleItem(
                  name: med.name,
                  dose: med.dose,
                  times: [],
                );
                scheduleMap[scheduleDate]!.add(newItem);
                return newItem;
              },
            );

            if (!existingItem.times.contains(formattedTime)) {
              existingItem.times.add(formattedTime);
            }
          }
        }
      }
    }

    final schedules =
        scheduleMap.entries.map((entry) {
          return Schedule(date: entry.key, scheduleItems: entry.value);
        }).toList();

    return ManagersSchedule(schedules: schedules);
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class Treat {
  final String authorUid;
  final String authorName;
  final String code;
  final String title;
  final List<Medicine> medicines;
  final DateTime createdAt;

  Treat({
    required this.authorUid,
    required this.authorName,
    required this.code,
    required this.title,
    required this.medicines,
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
    Medicine m = Medicine(
      name: med.name,
      duration: med.duration,
      count: 0,
      dose: med.dose,
      frequencyType: med.frequencyType,
      frequency: med.frequency,
      intervale: med.intervale,
      createAt: DateTime.now(),
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
  int maxCount;
  int intervale;
  DateTime createAt;
  final GlobalKey<FormState> formKey;

  Medicine({
    required this.name,
    required this.duration,
    required this.dose,
    required this.frequency,
    required this.frequencyType,
    this.count = 0,
    this.intervale = 0,
    required this.createAt,
  }) : maxCount = Medicine.calculateMaxCountStatic(
         duration: duration,
         frequency: frequency,
         frequencyType: frequencyType,
         intervale: intervale,
       ),
       formKey = GlobalKey<FormState>();

  static int calculateMaxCountStatic({
    required int duration,
    required int frequency,
    required FrequencyType frequencyType,
    required int intervale,
  }) {
    if (duration <= 0 || frequency <= 0 || intervale <= 0) {
      return 0;
    }

    switch (frequencyType) {
      case FrequencyType.daily:
        return duration * frequency;
      case FrequencyType.weekly:
        return ((duration / 7).ceil()) * frequency;
      case FrequencyType.biweekly:
        return ((duration / 14).ceil()) * frequency;
      case FrequencyType.monthly:
        return ((duration / 30).ceil()) * frequency;
      case FrequencyType.quarterly:
        return ((duration / 90).ceil()) * frequency;
    }
  }
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

class ScheduleItem {
  final String name;
  final String dose;
  final List<String> times;

  ScheduleItem({required this.name, required this.dose, required this.times});

  void addTime(String time) {
    times.add(time);
  }
}

class Schedule {
  final DateTime date;
  final List<ScheduleItem> scheduleItems;

  Schedule({required this.date, required this.scheduleItems});

  void addScheduleItem(ScheduleItem scheduleItem) {
    scheduleItems.add(scheduleItem);
  }
}

class ManagersSchedule {
  final List<Schedule> schedules;

  ManagersSchedule({required this.schedules});

  void addSchedule(Schedule schedule) {
    schedules.add(schedule);
  }
}
