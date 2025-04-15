import 'package:flutter/material.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Views/components/AppointmentsView.dart';
import 'package:med_assist/Views/components/SchedulesView.dart';

class AppointmentsPage extends StatefulWidget {
  final ManagersDoctors manager;

  const AppointmentsPage({super.key, required this.manager});

  @override
  State<AppointmentsPage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _appointments = widget.manager.appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Planning des rendez-vous'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: "Aujourd'hui"),
            Tab(icon: Icon(Icons.calendar_month), text: "Global"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DailyAppointmentsView(appointments: _appointments),
          AppointmentsView(appointments: _appointments),
        ],
      ),
    );
  }
}
