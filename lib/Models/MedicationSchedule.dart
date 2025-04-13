import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_assist/Models/treat.dart';

class MedicationScheduleList extends StatefulWidget {
  final ManagersTreats managersTreats;

  const MedicationScheduleList({super.key, required this.managersTreats});

  @override
  State<MedicationScheduleList> createState() => _MedicationScheduleListState();
}

class _MedicationScheduleListState extends State<MedicationScheduleList> {
  final ValueNotifier<DateTime> _timeNotifier = ValueNotifier(DateTime.now());
  Timer? _timer;
  List<MedicationSchedule> schedules = [];
  final List<ConfirmItem> confirmItems = [];

  @override
  void initState() {
    super.initState();
    _updateSchedules();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _timeNotifier.value = DateTime.now();
      _updateSchedules();
    });
  }

  void _updateSchedules() {
    setState(() {
      schedules = widget.managersTreats.todayMedicationSchedules();
      _refreshConfirmItems();
    });
  }

  void _refreshConfirmItems() {
    confirmItems.clear();
    for (var schedule in schedules) {
      for (var time in schedule.times) {
        final now = DateTime.now();
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.time.hour,
          time.time.minute,
        );
        final diff = now.difference(scheduledTime).inMinutes;
        final isActive = !time.isTaken && diff >= 0 && diff <= 5;

        confirmItems.add(
          ConfirmItem(
            treat: schedule.treat,
            medicine: schedule.medicine,
            time: time.time,
            isActive: isActive,
          ),
        );
      }
    }
  }

  bool _allTaken() {
    for (var schedule in schedules) {
      for (var time in schedule.times) {
        if (!time.isTaken) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double maxHeight = schedules.isEmpty || _allTaken() ? 80 : 300;
    final activeConfirmItems =
        confirmItems.where((item) => item.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daily Medicine",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 300,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (activeConfirmItems.isNotEmpty)
                  ...activeConfirmItems
                      .map((item) => _buildConfirmRow(item))
                      .toList(),

                schedules.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "Aucun médicament prévu pour aujourd'hui.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    : _allTaken()
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "🎉 Tous les médicaments ont été pris pour aujourd'hui !",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: schedules.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) {
                        return _buildMedicationCard(schedules[index]);
                      },
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmRow(ConfirmItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Confirmer la ${item.medicine.count + 1}ᵉ prise de ${item.medicine.dose} de ${item.medicine.name} ?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                item.medicine.updateMedicine(
                  widget.managersTreats.uid,
                  item.treat,
                  widget.managersTreats.treats,
                );
                _updateSchedules();
              });
            },
            icon: const Icon(Icons.check_circle, size: 16),
            label: const Text("Confirmer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(MedicationSchedule schedule) {
    return Card(
      color: Colors.green.shade400,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre + statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.medication_liquid,
                      color: Colors.white54,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${schedule.medicine.name} (${schedule.medicine.dose})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(schedule.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Heures de prise
            ValueListenableBuilder<DateTime>(
              valueListenable: _timeNotifier,
              builder: (context, currentDateTime, _) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      schedule.times.map((medTime) {
                        return Chip(
                          avatar: Icon(
                            medTime.isTaken
                                ? Icons.check_circle
                                : Icons.access_time,
                            color:
                                medTime.isTaken ? Colors.green : Colors.orange,
                            size: 18,
                          ),
                          label: Text(
                            formatTime(medTime.time),
                            style: const TextStyle(fontSize: 14),
                          ),
                          backgroundColor:
                              medTime.isTaken
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'terminé':
        return Colors.green;
      case 'en cours':
        return Colors.orange;
      case 'en attente':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}

class ConfirmItem {
  final Treat treat;
  final Medicine medicine;
  final TimeOfDay time;
  final bool isActive;

  ConfirmItem({
    required this.treat,
    required this.medicine,
    required this.time,
    required this.isActive,
  });
}

String formatTime(TimeOfDay dt) {
  final hour = '${dt.hour.toString().padLeft(2, '0')}h';
  final minute = "${dt.minute.toString().padLeft(2, '0')}'";
  return "$hour : $minute";
}
