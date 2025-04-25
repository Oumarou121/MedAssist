import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:local_auth/local_auth.dart';
import 'package:med_assist/Controllers/authentication.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/forgotPinCodeScreen.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/mainScreen.dart';
import 'package:provider/provider.dart';

class CodePin extends StatefulWidget {
  const CodePin({super.key});

  @override
  State<CodePin> createState() => _CodePinState();
}

class _CodePinState extends State<CodePin> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  Key _pinKey = UniqueKey();
  int attempts = 0;
  int max_attempts = 3;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _authenticateWithBiometrics({
    required AppUserData userData,
  }) async {
    if (userData.userSettings.allowBiometric) {
      try {
        bool isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'fingerprint_title'.tr(),
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (isAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(initialIndex: 0),
            ),
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'failed_biometric'.tr(),
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'not_allow_biometric'.tr(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   final user = Provider.of<AppUser?>(context);
  //   final userData = Provider.of<AppUserData?>(context);

  //   if (user == null) return const LoginScreen();
  //   if (userData == null) {
  //     return const Scaffold(body: Center(child: CircularProgressIndicator()));
  //   }

  //   // Manager Notification && Alarm
  //   ManagersTreats managersTreats = ManagersTreats(
  //     uid: userData.uid,
  //     name: userData.name,
  //     treats: userData.treatments,
  //   );
  //   managersTreats.checkAlarm();

  //   return Scaffold(
  //     appBar: AppBar(
  //       automaticallyImplyLeading: false,
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //       actions: [
  //         IconButton(
  //           padding: const EdgeInsets.only(right: 20),
  //           onPressed: () {
  //             final AuthenticationService _auth = AuthenticationService();
  //             _auth.signOut();
  //           },
  //           icon: const Icon(Iconsax.login, color: Color(0xFF2A8F68)),
  //         ),
  //       ],
  //     ),
  //     backgroundColor: Colors.white,
  //     body: _content(userData),
  //   );
  // }

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

          //Manager Notification && Alarm
          ManagersTreats managersTreats = ManagersTreats(
            uid: userData.uid,
            name: userData.name,
            treats: userData.treatments,
          );
          managersTreats.checkAlarm();

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  padding: const EdgeInsets.only(right: 20),
                  onPressed: () {
                    final AuthenticationService _auth = AuthenticationService();
                    _auth.signOut();
                  },
                  icon: const Icon(Iconsax.login, color: Color(0xFF2A8F68)),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            body: _content(userData),
          );
        }

        return const LoginScreen();
      },
    );
  }

  Widget _content(AppUserData userData) {
    return PinAuthentication(
      key: _pinKey,
      action: 'pin_code_title'.tr(),
      actionDescription: 'pin_code_description'.tr(),
      maxLength: 4,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.white,
        keysColor: const Color(0xFF2A8F68),
        activeFillColor: const Color(0xFF2A8F68),
        selectedFillColor: const Color(0xFF5AAF76),
        inactiveFillColor: const Color(0xFF2A8F68),
        fieldWidth: 45,
        fieldHeight: 45,
        borderWidth: 1,
      ),
      onChanged: (v) {},
      onCompleted: (v) {
        if (v.length == 4) {
          if (v == userData.pinCode) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(initialIndex: 0),
              ),
            );
          } else {
            attempts++;

            if (attempts >= max_attempts) {
              _showResetPasswordDialog(userData: userData);
            } else {
              setState(() {
                _pinKey = UniqueKey();
              });
              Fluttertoast.showToast(
                msg: 'invalid_pin_code'.tr(),
                backgroundColor: Colors.red,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          }
        }
      },
      onSpecialKeyTap: () {
        _authenticateWithBiometrics(userData: userData);
      },
      useFingerprint: true,
    );
  }

  void _showResetPasswordDialog({required AppUserData userData}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('many_attempts_title'.tr()),
          content: Text('many_attempts_description'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                attempts = 0;
                max_attempts = 1;
                setState(() {
                  _pinKey = UniqueKey();
                });
                Navigator.of(context).pop();
              },
              child: Text('again'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ForgotPinCodeScreen(userData: userData),
                  ),
                );
              },
              child: Text('reset'.tr()),
            ),
          ],
        );
      },
    );
  }
}
