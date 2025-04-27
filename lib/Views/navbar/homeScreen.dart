import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/databaseMedicalMessage.dart';
import 'package:med_assist/Views/components/MedicationSchedule.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/components/messagingScreen.dart';
import 'package:med_assist/Views/components/myAppointments.dart';
import 'package:med_assist/Views/components/myDoctors.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final PersistentTabController persistentTabController;

  const HomeScreen({super.key, required this.persistentTabController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
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
          final userData = snapshot.data!;
          final managersTreats = ManagersTreats(
            uid: userData.uid,
            name: userData.name,
            treats: userData.treatments,
          );
          final managersDoctors = ManagersDoctors(
            uid: userData.uid,
            name: userData.name,
            doctors: userData.doctors,
            appointments: userData.appointments,
            requests: userData.requests,
          );

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FB),
            body: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding + 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _top(userData: userData, userDataStream: database.user),
                    SizedBox(height: size.height * 0.03),
                    _searchBar(),
                    SizedBox(height: size.height * 0.03),
                    MedicationScheduleList(managersTreats: managersTreats),
                    SizedBox(height: size.height * 0.03),
                    MyAppointmentsList(managersDoctors: managersDoctors),
                    SizedBox(height: size.height * 0.03),
                    MyDoctorsList(
                      managersDoctors: managersDoctors,
                      persistentTabController: widget.persistentTabController,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const LoginScreen();
      },
    );
  }

  Widget _top({
    required AppUserData userData,
    required Stream<AppUserData> userDataStream,
  }) {
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
              StreamBuilder<bool>(
                stream: MedicalMessageService().hasUnreadMessagesStream(
                  ids: userData.medicalMessages,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      !snapshot.data!) {
                    return IconButton(
                      onPressed: () async {
                        Navigator.of(context, rootNavigator: true).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MedicalMessagingScreen(
                                      userDataStream: userDataStream,
                                    ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Iconsax.message, color: Colors.black),
                    );
                  }

                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () async {
                          Navigator.of(context, rootNavigator: true).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      MedicalMessagingScreen(
                                        userDataStream: userDataStream,
                                      ),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Iconsax.message, color: Colors.black),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              _buildProfileHeader(userData: userData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader({required AppUserData userData}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.green.shade100, Colors.green.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child:
                userData.userSettings.profileUrl.isNotEmpty
                    ? Image.network(
                      userData.userSettings.profileUrl,
                      fit: BoxFit.cover,
                    )
                    : Center(
                      child: Text(
                        userData.name.isNotEmpty ? userData.name[0] : '?',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      readOnly: true,
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
