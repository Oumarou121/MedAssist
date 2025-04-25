import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Models/user.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser? _userFromFirebase(User? user) {
    return user != null ? AppUser(user.uid) : null;
  }

  Stream<AppUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return _userFromFirebase(user);
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (exception) {
      return exception.toString();
    }
  }

  Future<String> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? user = result.user;

      if (user == null) {
        return 'false';
      }

      await DatabaseService(
        user.uid,
      ).saveUser(name, email, password, phoneNumber, "");

      return user.uid;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Une erreur est survenue lors de l’inscription.';
    } catch (exception) {
      return exception.toString();
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Erreur lors de la réinitialisation du mot de passe : $e");
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (exception) {
      print(exception.toString());
    }
  }

  Future<void> deleteAccountWithData(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);
        await FirebaseFirestore.instance
            .collection("users")
            .doc("patients")
            .collection("users")
            .doc(user.uid)
            .delete();
        await user.delete();
        print("Compte et données supprimés.");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }
}
