// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart'; // <-- AJOUT
// import 'package:med_assist/Controllers/database.dart';
// import 'package:med_assist/Models/user.dart';
// import 'package:med_assist/Views/Auth/loginScreen.dart';
// import 'package:med_assist/Views/security/codePin.dart';
// import 'package:med_assist/Views/security/createCodePin.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<AppUser?>(context);

//     if (user == null) return const LoginScreen();

//     final database = DatabaseService(user.uid);

//     return StreamBuilder<AppUserData>(
//       stream: database.user,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Lottie.asset(
//                     'assets/animations/animation.json', // ton fichier JSON ici
//                     width: 200,
//                     height: 200,
//                     fit: BoxFit.cover,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Chargement en cours...',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         if (snapshot.hasError) {
//           print("Firestore Error: ${snapshot.error}");
//           return const Scaffold(
//             body: Center(
//               child: Text(
//                 'Une erreur est survenue...',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           );
//         }

//         if (snapshot.hasData) {
//           final userData = snapshot.data!;

//           final locale = Locale(userData.userSettings.language);
//           if (context.locale != locale) {
//             context.setLocale(locale);
//           }

//           if (userData.pinCode.isEmpty) {
//             return CreateCodePin(uid: userData.uid);
//           }
//           return const CodePin();
//         }

//         return const LoginScreen();
//       },
//     );
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _showSplash = true; // D'abord true

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Animation dure 4 secondes
    )..forward();

    // Après 4 secondes, on cache l'animation
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child:
            _showSplash
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/animation2.json',
                        controller: _animationController,
                        onLoaded: (composition) {
                          _animationController
                            ..duration = const Duration(seconds: 4)
                            ..forward();
                        },
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Med Assist',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                )
                : _buildMainContent(user),
      ),
    );
  }

  Widget _buildMainContent(AppUser? user) {
    if (user == null) {
      return const LoginScreen();
    }

    final database = DatabaseService(user.uid);

    return StreamBuilder<AppUserData>(
      stream: database.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Ici on peut mettre un loader simple pendant la récupération des données
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("Firestore Error: ${snapshot.error}");
          return const Center(
            child: Text(
              'Une erreur est survenue...',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        if (snapshot.hasData) {
          final userData = snapshot.data!;

          final locale = Locale(userData.userSettings.language);
          if (context.locale != locale) {
            context.setLocale(locale);
          }

          if (userData.pinCode.isEmpty) {
            return CreateCodePin(uid: userData.uid);
          }
          return const CodePin();
        }

        return const LoginScreen();
      },
    );
  }
}
