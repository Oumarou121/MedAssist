import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/noti_service.dart';
import 'package:med_assist/Views/mainScreen.dart';

class CreateCodePin extends StatefulWidget {
  const CreateCodePin({super.key, required this.uid});
  final String uid;

  @override
  State<CreateCodePin> createState() => _CreateCodePinState();
}

class _CreateCodePinState extends State<CreateCodePin> {
  String _codePin = "";
  String _title = 'create_pin_code_title'.tr();
  Key _pinKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: true, body: _content());
  }

  Widget _content() {
    return PinAuthentication(
      key: _pinKey,
      action: _title,
      actionDescription: 'create_pin_code_description'.tr(),
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
          if (_codePin.isEmpty) {
            _codePin = v;
            setState(() {
              _title = 'confirm_create_pin_code_title'.tr();
              _pinKey = UniqueKey();
            });
          } else {
            if (_codePin == v) {
              String id = widget.uid;
              print(id);
              DatabaseService(id).updateDataOfValue("pinCode", v);

              //Cancel All Notification && Alarm
              NotiService().cancelAllAlarm();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainScreen(initialIndex: 0),
                ),
              );
            } else {
              Fluttertoast.showToast(
                msg: 'failed_create_pin_code'.tr(),
                backgroundColor: Colors.red,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_SHORT,
              );
              _codePin = "";
              setState(() {
                _title = 'create_pin_code_title'.tr();
                _pinKey = UniqueKey();
              });
            }
          }
        }
      },

      onSpecialKeyTap: () {
        Fluttertoast.showToast(
          msg: 'create_pin_code_available_biometric'.tr(),
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      },
      useFingerprint: true,
    );
  }
}
