import 'package:flutter/material.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/security/codePin.dart';
import 'package:med_assist/Views/security/createCodePin.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
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
          if (userData.pinCode == '') return CreateCodePin(uid: userData.uid);
          return const CodePin();
        }

        return const LoginScreen();
      },
    );
  }
}
