import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_assist/Controllers/authentication.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisez Firebase
  // await Firebase.initializeApp();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAsWLuoq_8-46L8hFGhzXrJp7qRv9qCffI",
      authDomain: "med-assist-53cba.firebaseapp.com",
      projectId: "med-assist-53cba",
      storageBucket: "med-assist-53cba.firebasestorage.app",
      messagingSenderId: "441831269862",
      appId: "1:441831269862:web:2145e79e8b05be0d4e6227",
      measurementId: "G-X3DPNG80D1",
    ),
  );

  runApp(const MyApp());
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
