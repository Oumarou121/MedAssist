import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Views/components/SchedulesView.dart';

class SchedulePage extends StatefulWidget {
  final ManagersTreats manager;

  const SchedulePage({super.key, required this.manager});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ManagersSchedule _schedule;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _schedule = widget.manager.generateSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('treatment_planning'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.calendar_today), text: 'today'.tr()),
            Tab(icon: Icon(Icons.calendar_month), text: "Global"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DailyScheduleView(managersSchedule: _schedule),
          SchedulesView(managersSchedule: _schedule),
        ],
      ),
    );
  }
}
