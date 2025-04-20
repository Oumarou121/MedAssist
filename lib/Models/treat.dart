import 'package:flutter/material.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Views/components/noti_service.dart';
import 'package:uuid/uuid.dart';

class ManagersTreats {
  final String uid;
  final String name;
  final List<Treat> treats;

  ManagersTreats({required this.uid, required this.name, required this.treats});

  List<Treat> activeTreatments() {
    return treats.where((t) => t.isActive() && !t.isMissing).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Treat> failedTreatments() {
    return treats.where((t) => t.isMissing).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Treat> finishedTreatments() {
    return treats.where((t) => !t.isActive()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addTreatment(Treat treat) async {
    treats.add(treat);

    //Firebase && Alarm
    final DatabaseService db = DatabaseService(uid);
    await db.updateTreatments(treats);
    await checkAlarm();
  }

  void removeTreatment(Treat treat) async {
    treats.remove(treat);

    //Firebase && Alarm
    final DatabaseService db = DatabaseService(uid);
    await db.updateTreatments(treats);

    //Cancel Alarm
    await redefineAlarm();
  }

  bool alreadyExists(String code) {
    return treats.any((treat) => treat.code == code);
  }

  int _generateAlarmId(
    String treatCode,
    String medicineName,
    int index,
    DateTime date,
  ) {
    final uuid = Uuid();
    final String uniquePart = uuid.v5(
      // ignore: deprecated_member_use
      Uuid.NAMESPACE_URL,
      '$treatCode-$date-$medicineName-$index',
    );
    return uniquePart.codeUnits.reduce((a, b) => a + b) % 100000;
  }

  Future<void> checkAlarm() async {
    ManagersSchedule managersSchedule = generateSchedule();

    for (var schedule in managersSchedule.schedules) {
      DateTime currentDate = schedule.date;
      for (var scheduleItem in schedule.scheduleItems) {
        for (int i = 0; i < scheduleItem.times.length; i++) {
          String formattedTime = scheduleItem.times[i];
          final cleaned = formattedTime.replaceAll("h", "").replaceAll("'", "");
          final parts = cleaned.split(":");
          int hour = int.parse(parts[0].trim());
          int minute = int.parse(parts[1].trim());

          int id = _generateAlarmId(
            scheduleItem.treat.code,
            scheduleItem.medicine.name,
            i,
            currentDate,
          );

          DateTime alarmDate = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            minute,
            0,
          );

          print('id : $id, time: $alarmDate');

          bool isActive = await NotiService().isNotificationPlanned(id);
          if (isActive) {
            print("active");
          } else {
            print("non-active");
            await NotiService().addAlarm(
              id: id,
              title1: scheduleItem.treat.title,
              title2: scheduleItem.medicine.name,
              body1: "C'est l'heure de prendre votre médicament",
              body2:
                  "${scheduleItem.medicine.name} (${scheduleItem.medicine.dose})",
              payload:
                  "${scheduleItem.treat.code}_${scheduleItem.medicine.name}_$i",
              time: alarmDate,
            );
          }
        }
      }
    }
  }

  Future<void> redefineAlarm() async {
    ManagersSchedule managersSchedule = generateSchedule();

    await NotiService().cancelAllAlarm();

    for (var schedule in managersSchedule.schedules) {
      DateTime currentDate = schedule.date;
      for (var scheduleItem in schedule.scheduleItems) {
        for (int i = 0; i < scheduleItem.times.length; i++) {
          String formattedTime = scheduleItem.times[i];
          final cleaned = formattedTime.replaceAll("h", "").replaceAll("'", "");
          final parts = cleaned.split(":");
          int hour = int.parse(parts[0].trim());
          int minute = int.parse(parts[1].trim());

          int id = _generateAlarmId(
            scheduleItem.treat.code,
            scheduleItem.medicine.name,
            i,
            currentDate,
          );

          DateTime alarmDate = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            minute,
            0,
          );

          print('id : $id, time: $alarmDate');

          bool isActive = await NotiService().isNotificationPlanned(id);
          if (isActive) {
            print("active");
          } else {
            print("non-active");
            await NotiService().addAlarm(
              id: id,
              title1: scheduleItem.treat.title,
              title2: scheduleItem.medicine.name,
              body1: "C'est l'heure de prendre votre médicament",
              body2:
                  "${scheduleItem.medicine.name} (${scheduleItem.medicine.dose})",
              payload:
                  "${scheduleItem.treat.code}_${scheduleItem.medicine.name}_$i",
              time: alarmDate,
            );
          }
        }
      }
    }
  }

  ManagersSchedule generateSchedule() {
    final Map<DateTime, List<ScheduleItem>> scheduleMap = {};

    List<Treat> ts = activeTreatments();

    for (final treat in ts) {
      for (final med in treat.medicines) {
        for (int i = 0; i < med.duration; i++) {
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

          // +10 minutes
          DateTime baseTime = med.createAt.add(Duration(days: i, minutes: 10));
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
              (item) =>
                  item.medicine.name == med.name &&
                  item.medicine.dose == med.dose,
              orElse: () {
                final newItem = ScheduleItem(
                  treat: treat,
                  medicine: med,
                  times: [],
                  minStepCount: med.calculateStepMaxCount(
                    duration: i,
                    frequency: med.frequency,
                    frequencyType: med.frequencyType,
                    intervale: med.intervale,
                  ),
                  maxStepCount: med.calculateStepMaxCount(
                    duration: i + 1,
                    frequency: med.frequency,
                    frequencyType: med.frequencyType,
                    intervale: med.intervale,
                  ),
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
    final hour = '${dt.hour.toString().padLeft(2, '0')}h';
    final minute = "${dt.minute.toString().padLeft(2, '0')}'";
    return "$hour : $minute";
  }

  List<MedicationSchedule> todayMedicationSchedules() {
    final ManagersSchedule schedule = generateSchedule();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final Schedule todaySchedule = schedule.schedules.firstWhere(
      (s) =>
          s.date.year == today.year &&
          s.date.month == today.month &&
          s.date.day == today.day,
      orElse: () => Schedule(date: today, scheduleItems: []),
    );

    final List<MedicationSchedule> result = [];

    for (var item in todaySchedule.scheduleItems) {
      List<MedicationTime> medicationTimes = [];
      bool isValid = true;

      for (int i = 0; i < item.times.length; i++) {
        final formattedTime = item.times[i];
        final cleaned = formattedTime.replaceAll("h", "").replaceAll("'", "");
        final parts = cleaned.split(":");

        int hour = int.parse(parts[0].trim());
        int minute = int.parse(parts[1].trim());
        final doseTime = DateTime(
          today.year,
          today.month,
          today.day,
          hour,
          minute,
        );
        bool isTakenByCount = false;

        int currentStep = item.minStepCount + i + 1;
        int count = item.medicine.count;

        if (count >= item.minStepCount && count <= item.maxStepCount) {
          if (count >= currentStep) {
            isTakenByCount = true;
          } else if (now.isAfter(
            DateTime(
              doseTime.year,
              doseTime.month,
              doseTime.day,
              doseTime.hour,
              doseTime.minute + 10,
            ),
          )) {
            item.treat.updateStatus(uid, treats);

            //Alarm
            redefineAlarm();
            isValid = false;
            break;
          }
        } else {
          item.treat.updateStatus(uid, treats);

          //Alarm
          redefineAlarm();

          isValid = false;
          break;
        }

        bool isTaken = now.isAfter(doseTime) && isTakenByCount;

        medicationTimes.add(
          MedicationTime(
            time: TimeOfDay(hour: hour, minute: minute),
            isTaken: isTaken,
          ),
        );
      }

      // Si le médicament n'est pas valide, on continue avec le prochain item
      if (!isValid) continue;

      String status;
      int takenCount = medicationTimes.where((t) => t.isTaken).length;

      // Statut en fonction du nombre de prises effectuées
      if (takenCount == medicationTimes.length) {
        status = 'terminé';
      } else if (takenCount == 0) {
        status = 'en attente';
      } else {
        status = 'en cours';
      }

      result.add(
        MedicationSchedule(
          treat: item.treat,
          medicine: item.medicine,
          times: medicationTimes,
          status: status,
        ),
      );
    }

    return result;
  }
}

class Treat {
  final String authorUid;
  final String authorName;
  final String code;
  final String title;
  final List<Medicine> medicines;
  final DateTime createdAt;
  final bool isPublic;
  final List<String> followers;
  bool isMissing;

  Treat({
    required this.authorUid,
    required this.authorName,
    required this.code,
    required this.title,
    required this.medicines,
    required this.createdAt,
    required this.followers,
    required this.isPublic,
    this.isMissing = false,
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

  void addMedicine(Medicine med, String uid, List<Treat> userTreatments) {
    final m = Medicine(
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

    //Firebase && Alarm
    final index = userTreatments.indexWhere((t) => t.code == code);
    if (index != -1) {
      userTreatments[index] = this;
    }
    final db = DatabaseService(uid);
    db.updateTreatments(userTreatments);
  }

  void updateStatus(String uid, List<Treat> userTreatments) {
    isMissing = true;

    //Firebase
    final index = userTreatments.indexWhere((t) => t.code == code);
    if (index != -1) {
      userTreatments[index] = this;
    }

    final db = DatabaseService(uid);
    db.updateTreatments(userTreatments);
  }

  void addMedicineWithoutSave(Medicine med) {
    final m = Medicine(
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

  Map<String, dynamic> toMap() {
    return {
      'authorUid': authorUid,
      'authorName': authorName,
      'code': code,
      'title': title,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isMissing': isMissing,
      'isPublic': isPublic,
      'followers': followers,
    };
  }

  factory Treat.fromMap(Map<String, dynamic> map) {
    return Treat(
      authorUid: map['authorUid'],
      authorName: map['authorName'],
      code: map['code'],
      title: map['title'],
      medicines:
          (map['medicines'] as List)
              .map((m) => Medicine.fromMap(m as Map<String, dynamic>))
              .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      isMissing: map['isMissing'] ?? false,
      isPublic: map['isPublic'] ?? false,
      followers:
          map['followers'] != null
              ? List<String>.from(
                map['followers'].map((f) => f.toString()),
              ) // Conversion explicite
              : [],
    );
  }

  double progressValue() {
    int maxCount = 0;
    int count = 0;

    for (Medicine med in medicines) {
      maxCount += med.maxCount;
      count += med.count;
    }

    return count / maxCount;
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

  int calculateStepMaxCount({
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

  void updateMedicine(String uid, Treat treat, List<Treat> userTreatments) {
    if (count < maxCount) {
      count++;

      //Firebase
      final medIndex = treat.medicines.indexWhere(
        (m) =>
            m.name == name &&
            m.dose == dose &&
            m.createAt.isAtSameMomentAs(createAt) &&
            m.duration == duration,
      );
      if (medIndex != -1) {
        treat.medicines[medIndex] = this;
      }

      final treatIndex = userTreatments.indexWhere((t) => t.code == treat.code);
      if (treatIndex != -1) {
        userTreatments[treatIndex] = treat;
      }

      final db = DatabaseService(uid);
      db.updateTreatments(userTreatments);
      return;
    }
    print("Error update count");
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
      'dose': dose,
      'frequency': frequency,
      'frequencyType': frequencyType.index,
      'count': count,
      'maxCount': maxCount,
      'intervale': intervale,
      'createAt': createAt.toIso8601String(),
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      name: map['name'],
      duration: map['duration'],
      dose: map['dose'],
      frequency: map['frequency'],
      frequencyType: FrequencyType.values[map['frequencyType']],
      count: map['count'] ?? 0,
      intervale: map['intervale'] ?? 0,
      createAt: DateTime.parse(map['createAt']),
    );
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
  final Treat treat;
  final Medicine medicine;
  final List<String> times;
  final int minStepCount;
  final int maxStepCount;

  ScheduleItem({
    required this.treat,
    required this.medicine,
    required this.times,
    required this.minStepCount,
    required this.maxStepCount,
  });

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

class MedicationSchedule {
  final Treat treat;
  final Medicine medicine;
  final List<MedicationTime> times;
  final String status;

  MedicationSchedule({
    required this.treat,
    required this.medicine,
    required this.times,
    required this.status,
  });
}

class MedicationTime {
  final TimeOfDay time;
  final bool isTaken;

  MedicationTime({required this.time, required this.isTaken});
}
