import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Controllers/authentication.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/security/createCodePin.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthenticationService _auth = AuthenticationService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSignup = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _fullName = "";
  String _email = "";
  String _phoneNumber = "";
  String _password = "";
  String _confirmPassword = "";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Column(
            children: <Widget>[
              SizedBox(height: size.height * 0.03),
              _buildLogoSection(size),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFullNameTextField(),
                    SizedBox(height: size.height * 0.03),
                    _buildEmailTextField(),
                    SizedBox(height: size.height * 0.03),
                    _buildPhoneNumberTextField(),
                    SizedBox(height: size.height * 0.03),
                    _buildPasswordField(),
                    SizedBox(height: size.height * 0.03),
                    _buildConfirmPasswordField(),
                    SizedBox(height: size.height * 0.03),
                    _buildSignUpButton(size),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
              buildFooter(),
              SizedBox(height: size.height * 0.03),
              ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                child: Text('register'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/form.png', height: 110, width: 110),
        SizedBox(height: size.height * 0.03),
        Text(
          'create_account'.tr(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required Icon prefixIcon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildFullNameTextField() {
    return _buildTextField(
      hintText: 'full_name'.tr(),
      prefixIcon: const Icon(Iconsax.user),
      onChanged: (value) => _fullName = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'required'.tr();
        } else if (value.length < 4) {
          return 'invalid_full_name'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildEmailTextField() {
    return _buildTextField(
      hintText: "email".tr(),
      prefixIcon: const Icon(Iconsax.direct_right),
      onChanged: (value) => _email = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'required'.tr();
        } else if (!isValidEmail(value)) {
          return 'invalid_email'.tr();
        }
        return null;
      },
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPhoneNumberTextField() {
    return _buildTextField(
      hintText: 'phone_number'.tr(),
      prefixIcon: const Icon(Iconsax.call),
      onChanged: (value) => _phoneNumber = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'required'.tr();
        } else if (value.length < 8) {
          return 'invalid_phone_number'.tr();
        }
        return null;
      },
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      hintText: 'password'.tr(),
      prefixIcon: const Icon(Iconsax.password_check),
      onChanged: (value) => _password = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'required'.tr();
        } else if (value.length < 6) {
          return 'invalid_password'.tr();
        }
        return null;
      },
      obscureText: !_isPasswordVisible,
      suffixIcon: IconButton(
        onPressed:
            () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        icon: Icon(_isPasswordVisible ? Iconsax.eye_slash : Iconsax.eye),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      hintText: 'confirm_password'.tr(),
      prefixIcon: const Icon(Iconsax.password_check),
      onChanged: (value) => _confirmPassword = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'required'.tr();
        } else if (value != _password) {
          return 'invalid_confirm_password'.tr();
        }
        return null;
      },
      obscureText: !_isConfirmPasswordVisible,
      suffixIcon: IconButton(
        onPressed:
            () => setState(
              () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
            ),
        icon: Icon(_isConfirmPasswordVisible ? Iconsax.eye_slash : Iconsax.eye),
      ),
    );
  }

  Widget _buildSignUpButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          signUp();
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.green,
        ),
        child:
            _isSignup
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  'create_account'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
            'have_account'.tr(),
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

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSignup = true);

      try {
        String result = await _auth.registerWithEmailAndPassword(
          name: _fullName,
          email: _email,
          password: _password,
          phoneNumber: _phoneNumber,
        );
        if (result != 'false') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCodePin(uid: result)),
          );
          ;
        } else {
          Fluttertoast.showToast(
            msg: 'failed_register'.tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Erreur : ${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() => _isSignup = false);
      }
    }
  }
}
