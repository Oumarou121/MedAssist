import 'package:easy_localization/easy_localization.dart';
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
  List<AppointmentData> _appointments = [];

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
        title: Text('appointment_schedule'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs:  [
            Tab(icon: Icon(Icons.calendar_today), text: 'today'.tr()),
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
