import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/security/createCodePin.dart';

class ForgotPinCodeScreen extends StatefulWidget {
  const ForgotPinCodeScreen({super.key, required this.userData});
  final AppUserData userData;

  @override
  State<ForgotPinCodeScreen> createState() => _ForgotPinCodeScreenState();
}

class _ForgotPinCodeScreenState extends State<ForgotPinCodeScreen> {
  bool _isPasswordVisible = false;
  bool _isSigning = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _password = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
            child: Column(
              children: <Widget>[
                SizedBox(height: size.height * 0.03),
                logo(170, 170),
                SizedBox(height: size.height * 0.06),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forgot Pin Code",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Don't worry! It happens. Please enter the password that associated with yout Account.",
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      buildPasswordField(),
                      SizedBox(height: size.height * 0.03),
                      signInButton(size),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logo(double height_, double width_) {
    return Image.asset(
      'assets/images/forgot_password.png',
      height: height_,
      width: width_,
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      obscureText: !_isPasswordVisible,
      onChanged: (value) => setState(() => _password = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre mot de passe';
        } else if (value.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        return null;
      },
      decoration: inputDecoration(
        "Password",
        Iconsax.password_check,
        suffixIcon: IconButton(
          onPressed:
              () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          icon: Icon(_isPasswordVisible ? Iconsax.eye_slash : Iconsax.eye),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF25D366)),
      ),
    );
  }

  Widget signInButton(Size size) {
    return GestureDetector(
      onTap: resetPassword,
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.green,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C2E84).withOpacity(0.2),
              offset: const Offset(0, 15.0),
              blurRadius: 60.0,
            ),
          ],
        ),
        child:
            _isSigning
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  'Check Out',
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
      ),
    );
  }

  void resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSigning = true);
      await Future.delayed(Duration(seconds: 2));
      if (_password == widget.userData.password) {
        String userUid = widget.userData.uid;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateCodePin(uid: userUid)),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Incorrect Password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      setState(() => _isSigning = false);
    }
  }
}
