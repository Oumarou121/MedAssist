import 'package:flutter/material.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Views/components/AppointmentsView.dart';

class AppointmentsPage extends StatefulWidget {
  final ManagersDoctors manager;

  const AppointmentsPage({super.key, required this.manager});

  @override
  State<AppointmentsPage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final appointments = await widget.manager.getAppointments();
    setState(() {
      _appointments = appointments;
    });
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
          AppointmentsView(
            appointments: _appointments,
            managersDoctors: widget.manager,
          ),
        ],
      ),
    );
  }
}
