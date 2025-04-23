import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/noti_service.dart';
import 'package:med_assist/Views/components/MedicationSchedule.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/components/myAppointments.dart';
import 'package:med_assist/Views/components/myDoctors.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final PersistentTabController persistentTabController;

  const HomeScreen({
    super.key,
    required this.persistentTabController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    listenNotification();
  }

  listenNotification() {
    print("Listening to nootification");
    // NotiService.onClickNotification.stream.listen((event) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => AnotherPage(payload: event)),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    final user = Provider.of<AppUser?>(context);
    if (user == null) return const LoginScreen();
    final database = DatabaseService(user.uid);

    return StreamBuilder<AppUserData>(
      stream: database.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          AppUserData? userData = snapshot.data;
          if (userData == null) return const LoginScreen();
          ManagersTreats managersTreats = ManagersTreats(
            uid: userData.uid,
            name: userData.name,
            treats: userData.treatments,
          );

          ManagersDoctors managersDoctors = ManagersDoctors(
            uid: userData.uid,
            name: userData.name,
            doctors: userData.doctors,
            appointments: userData.appointments,
            requests: userData.requests,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding + 40),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _top(userData: userData),
                        SizedBox(height: size.height * 0.03),
                        _searchBar(),
                        SizedBox(height: size.height * 0.03),
                        MedicationScheduleList(managersTreats: managersTreats),
                        SizedBox(height: size.height * 0.03),
                        MyAppointmentsList(managersDoctors: managersDoctors),
                        SizedBox(height: size.height * 0.03),
                        MyDoctorsList(
                          managersDoctors: managersDoctors,
                          persistentTabController:
                              widget.persistentTabController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const LoginScreen();
      },
    );
  }

  Widget _top({required AppUserData userData}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'hello'.tr(),
              style: GoogleFonts.poppins(fontSize: 24, color: Colors.black),
            ),
            Text(
              "${userData.name}!",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      await NotiService().cancelAllAlarm();
                    },
                    icon: const Icon(Iconsax.notification, color: Colors.black),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              _buildProfileHeader(userData: userData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader({required AppUserData userData}) {
    return userData.userSettings.profileUrl != ''
        ? CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(userData.userSettings.profileUrl),
        )
        : CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFF00C853),
          child: Text(
            userData.name[0],
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
        );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (text) {},
      decoration: InputDecoration(
        hintText: 'search'.tr(),
        prefixIcon: Icon(Iconsax.search_normal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}
