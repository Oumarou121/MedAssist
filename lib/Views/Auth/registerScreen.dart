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
                child: const Text('Se connecter'),
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
        const Text(
          'Créer un compte',
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
      hintText: "Nom complet",
      prefixIcon: const Icon(Iconsax.user),
      onChanged: (value) => _fullName = value,
      validator:
          (value) =>
              value!.isEmpty ? 'Veuillez entrer votre nom complet' : null,
    );
  }

  Widget _buildEmailTextField() {
    return _buildTextField(
      hintText: "E-mail",
      prefixIcon: const Icon(Iconsax.direct_right),
      onChanged: (value) => _email = value,
      validator:
          (value) =>
              value!.isEmpty || !isValidEmail(value)
                  ? 'Veuillez entrer une adresse e-mail valide'
                  : null,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPhoneNumberTextField() {
    return _buildTextField(
      hintText: "Numéro de téléphone",
      prefixIcon: const Icon(Iconsax.call),
      onChanged: (value) => _phoneNumber = value,
      validator:
          (value) =>
              value!.isEmpty
                  ? 'Veuillez entrer votre numéro de téléphone'
                  : null,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      hintText: 'Mot de passe',
      prefixIcon: const Icon(Iconsax.password_check),
      onChanged: (value) => _password = value,
      validator:
          (value) =>
              value!.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
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
      hintText: 'Confirmer le mot de passe',
      prefixIcon: const Icon(Iconsax.password_check),
      onChanged: (value) => _confirmPassword = value,
      validator:
          (value) =>
              value != _password
                  ? 'Les mots de passe ne correspondent pas'
                  : null,
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
                  'Créer un compte',
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
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Vous avez déjà un compte?",
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
        print(result);
        if (result != 'false') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCodePin(uid: result)),
          );
          ;
        } else {
          Fluttertoast.showToast(
            msg: "Erreur lors de la création du compte",
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
