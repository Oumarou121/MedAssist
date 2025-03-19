import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/Auth/registerScreen.dart';
import 'package:med_assist/Controllers/authentication.dart';
import 'package:med_assist/Views/mainScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthenticationService _auth = AuthenticationService();
  bool _isSigning = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = "";

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
                        "Forgot Password",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Don't worry! It happens. Please enter the email that associated with yout Account.",
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      buildEmailTextField(),
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

  Widget buildEmailTextField() {
    return TextFormField(
      onChanged: (value) => setState(() => _email = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        } else if (!isValidEmail(value)) {
          return 'Veuillez entrer une adresse email valide';
        }
        return null;
      },
      keyboardType: TextInputType.emailAddress,
      decoration: inputDecoration("E-mail", Iconsax.direct_right),
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
                  'Send',
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

  bool isValidEmail(String value) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  void resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSigning = true);

      try {
        bool result = await _auth.resetPassword(email: _email);

        if (result) {
          Fluttertoast.showToast(
            msg: "Email Envoie! Veillez verifier vos email",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Cet email n'existe pas",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Erreur: ${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() => _isSigning = false);
      }
    }
  }
}
