import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Views/Auth/forgotPasswordScreen.dart';
import 'package:med_assist/Views/Auth/registerScreen.dart';
import 'package:med_assist/Controllers/authentication.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthenticationService _auth = AuthenticationService();
  bool _isPasswordVisible = false;
  bool _isSigning = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
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
                      buildEmailTextField(),
                      SizedBox(height: size.height * 0.03),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "${'forgot_password'.tr()} ?",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                      buildPasswordField(),
                      SizedBox(height: size.height * 0.03),
                      signInButton(size),
                      SizedBox(height: size.height * 0.03),
                      buildFooter(),
                      SizedBox(height: size.height * 0.03),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text('create_account'.tr()),
                      ),
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
      'assets/images/login.png',
      height: height_,
      width: width_,
    );
  }

  Widget buildEmailTextField() {
    return TextFormField(
      onChanged: (value) => setState(() => _email = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'required'.tr();
        } else if (!isValidEmail(value)) {
          return 'invalid_email'.tr();
        }
        return null;
      },
      keyboardType: TextInputType.emailAddress,
      decoration: inputDecoration('email'.tr(), Iconsax.direct_right),
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      obscureText: !_isPasswordVisible,
      onChanged: (value) => setState(() => _password = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'required'.tr();
        } else if (value.length < 6) {
          return 'invalid_password'.tr();
        }
        return null;
      },
      decoration: inputDecoration(
        'password'.tr(),
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
      onTap: signIn,
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
                  'login'.tr(),
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

  Widget buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'not_have_account'.tr(),
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
      ],
    );
  }

  bool isValidEmail(String value) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  void signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSigning = true);

      try {
        var result = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        Fluttertoast.showToast(
          msg: result,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } catch (e) {
        setState(() => _isSigning = false);
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
