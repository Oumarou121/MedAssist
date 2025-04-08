import 'package:flutter/material.dart';
import 'package:med_assist/Models/treat.dart';

class DailyScheduleView extends StatelessWidget {
  final ManagersSchedule managersSchedule;

  const DailyScheduleView({super.key, required this.managersSchedule});

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

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    // final endOfDay = DateTime(
    //   today.year,
    //   today.month,
    //   today.day,
    //   23,
    //   59,
    //   59,
    // );

    final schedules = [...managersSchedule.schedules]
      ..sort((a, b) => a.date.compareTo(b.date));

    final todaySchedules =
        schedules.where((schedule) {
          final scheduleDate = DateTime(
            schedule.date.year,
            schedule.date.month,
            schedule.date.day,
          );
          return scheduleDate.isAtSameMomentAs(startOfDay);
        }).toList();

    if (todaySchedules.isEmpty) {
      return const Center(
        child: Text('Aucun planning prévu pour aujourd\'hui.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todaySchedules.length,
      itemBuilder: (context, index) {
        final schedule = todaySchedules[index];
        final formattedDate = _formatDate(schedule.date);
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                if (schedule.scheduleItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Aucun traitement prévu pour ce jour.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  ...schedule.scheduleItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.name} (${item.dose})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
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
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        backgroundColor: Colors.blue.shade100,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
