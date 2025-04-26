import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/treat.dart';

class SchedulesView extends StatelessWidget {
  final ManagersSchedule managersSchedule;

  const SchedulesView({super.key, required this.managersSchedule});

  @override
  Widget build(BuildContext context) {
    final schedules = [...managersSchedule.schedules]
      ..sort((a, b) => a.date.compareTo(b.date));

    if (schedules.isEmpty) {
      return Center(
        child: Text(
          'no_treatment'.tr(),
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _buildScheduleCard(
          date: schedule.date,
          items: schedule.scheduleItems,
        );
      },
    );
  }
}

class DailyScheduleView extends StatelessWidget {
  final ManagersSchedule managersSchedule;

  const DailyScheduleView({super.key, required this.managersSchedule});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final schedules = [...managersSchedule.schedules]
      ..sort((a, b) => a.date.compareTo(b.date));

    final todaySchedules =
        schedules
            .where(
              (schedule) => DateTime(
                schedule.date.year,
                schedule.date.month,
                schedule.date.day,
              ).isAtSameMomentAs(startOfDay),
            )
            .toList();

    if (todaySchedules.isEmpty) {
      return Center(
        child: Text(
          'no_treatment_today'.tr(),
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todaySchedules.length,
      itemBuilder: (context, index) {
        final schedule = todaySchedules[index];
        return _buildScheduleCard(
          date: schedule.date,
          items: schedule.scheduleItems,
        );
      },
    );
  }
}

Widget _buildScheduleCard({
  required DateTime date,
  required List<ScheduleItem> items,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      // color:Color(0xFF00C853).withOpacity(0.5),
      gradient: LinearGradient(
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
          color: Colors.black.withOpacity(0.05),
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
              const Icon(Iconsax.clock, color: Color(0xFF3366FF), size: 20),
              const SizedBox(width: 8),
              Text(
                _formatDate(date),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'no_treatment'.tr(),
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            )
          else
            ...items.map((item) => _buildScheduleItem(item)).toList(),
        ],
      ),
    ),
  );
}

Widget _buildScheduleItem(ScheduleItem item) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.medicine.name} • ${item.medicine.dose}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              item.times
                  .map(
                    (time) => Chip(
                      label: Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF3366FF),
                        ),
                      ),
                      backgroundColor: const Color(0xFF3366FF).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  final days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  final months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  final dayName = days[date.weekday - 1];
  final monthName = months[date.month - 1];
  return '$dayName ${date.day} $monthName ${date.year}';
}
