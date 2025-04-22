import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_assist/Controllers/authentication.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Controllers/noti_service.dart';
import 'package:med_assist/Views/splash.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      tz.initializeTimeZones();
      await Alarm.init();
      NotiService().initNotification();

      // Initialisez Firebase
      await Firebase.initializeApp();

      // await Firebase.initializeApp(
      //   options: FirebaseOptions(
      //     apiKey: "AIzaSyAsWLuoq_8-46L8hFGhzXrJp7qRv9qCffI",
      //     authDomain: "med-assist-53cba.firebaseapp.com",
      //     projectId: "med-assist-53cba",
      //     storageBucket: "med-assist-53cba.firebasestorage.app",
      //     messagingSenderId: "441831269862",
      //     appId: "1:441831269862:web:2145e79e8b05be0d4e6227",
      //     measurementId: "G-X3DPNG80D1",
      //   ),
      // );

      await Supabase.initialize(
        url: 'https://fxwpdqnowtwmckklipve.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4d3BkcW5vd3R3bWNra2xpcHZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ4ODUzNjIsImV4cCI6MjA2MDQ2MTM2Mn0.mHi3QlhxY0v6Y4LLpqydjLCt5dAfbRmcNcRPMR_iKRY',
      );

      runApp(const MyApp());
    },
    (error, stackTrace) {
      print('Caught error: $error');
    },
  );
}

class ItemsNumber with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemsNumber()),
        StreamProvider<AppUser?>.value(
          value: AuthenticationService().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Med Assist',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),

        home: const SplashScreen(),
      ),
    );
  }
}
