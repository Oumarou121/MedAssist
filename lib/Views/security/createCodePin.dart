import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/mainScreen.dart';

class CreateCodePin extends StatefulWidget {
  const CreateCodePin({super.key, required this.uid});
  final String uid;

  @override
  State<CreateCodePin> createState() => _CreateCodePinState();
}

class _CreateCodePinState extends State<CreateCodePin> {
  String _codePin = "";
  String _title = "Create Pin Code";
  Key _pinKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
            icon: const Icon(Iconsax.login, color: Color(0xFF2A8F68)),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: _content(),
    );
  }

  Widget _content() {
    return PinAuthentication(
      key: _pinKey,
      action: _title,
      actionDescription: 'This password will be required at each login',
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
              _title = "Confirm Pin Code";
              _pinKey = UniqueKey();
            });
          } else {
            if (_codePin == v) {
              final DatabaseService _db = DatabaseService(widget.uid);
              _db.updataDataOfValue("pinCode", v);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            } else {
              Fluttertoast.showToast(
                msg: 'Pin Code does not match',
                backgroundColor: Colors.red,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_SHORT,
              );
              _codePin = "";
              setState(() {
                _title = "Create Pin Code";
                _pinKey = UniqueKey();
              });
            }
          }
        }
      },

      onSpecialKeyTap: () {
        Fluttertoast.showToast(
          msg: 'Available after the creation of the Pin Code',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      },
      useFingerprint: true,
    );
  }
}
