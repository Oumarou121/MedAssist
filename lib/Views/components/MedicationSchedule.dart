import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
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
          time.time.minute + 1,
        );
        final diff = now.difference(scheduledTime).inMinutes;
        final isActive = !time.isTaken && diff >= 0 && diff <= 10;

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
    final activeConfirmItems =
        confirmItems.where((item) => item.isActive).toList();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              'planning_medical'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (activeConfirmItems.isNotEmpty)
            ...activeConfirmItems
                .map((item) => _buildConfirmCard(item))
                .toList(),

          if (schedules.isEmpty)
            _buildEmptyState()
          else if (_allTaken())
            _buildFinishState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder:
                  (context, index) => _buildMedicationCard(schedules[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.health_and_safety, size: 48, color: Colors.blueGrey[300]),
          const SizedBox(height: 12),
          Text(
            'no_treatment_today'.tr(),
            style: GoogleFonts.poppins(
              color: Colors.blueGrey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishState() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 40, color: Colors.green[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'finish_treatment'.tr(),
              style: GoogleFonts.poppins(
                color: Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmCard(ConfirmItem item) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'intake_confirm'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.medicine.name} • ${item.medicine.dose}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${'intake'.tr()} n°${item.medicine.count + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blueGrey[400],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.check, size: 18),
            label: Text('confirm'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green[800],
              side: BorderSide(color: Colors.green[800]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(MedicationSchedule schedule) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // colors: [Colors.blue[50]!, Colors.white],
          colors: [
            Color(0xFF00C853).withOpacity(0.4),
            Color(0xFFB2FF59).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.medication, color: Colors.green[800]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.medicine.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        schedule.medicine.dose,
                        style: GoogleFonts.poppins(
                          color: Colors.blueGrey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(schedule.status),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<DateTime>(
              valueListenable: _timeNotifier,
              builder: (context, currentDateTime, _) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      schedule.times.map((medTime) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                medTime.isTaken
                                    ? Colors.green[50]
                                    : Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  medTime.isTaken
                                      ? Colors.green[100]!
                                      : Colors.orange[100]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                medTime.isTaken
                                    ? Icons.check_circle
                                    : Icons.access_time,
                                color:
                                    medTime.isTaken
                                        ? Colors.green[600]
                                        : Colors.orange[600],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatTime(medTime.time),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                            ],
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

  Widget _buildStatusIndicator(String status) {
    final color = _statusColor(status.tr());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Color _statusColor(String status) {
  //   switch (status) {
  //     case 'finished'.tr():
  //       return Colors.green;
  //     case 'on_hold'.tr():
  //       return Colors.orange;
  //     case 'in_progress'.tr():
  //       return Colors.grey;
  //     default:
  //       return Colors.blueGrey;
  //   }
  // }

  Color _statusColor(String status) {
    switch (status) {
      case 'finished':
        return Colors.green;
      case 'on_hold':
        return Colors.orange;
      case 'in_progress':
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
