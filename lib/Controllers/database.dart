// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:med_assist/Models/treat.dart';
// import 'package:med_assist/Models/user.dart';

// class DatabaseService {
//   final String uid;

//   DatabaseService(this.uid);

//   final CollectionReference<Map<String, dynamic>> userCollection =
//       FirebaseFirestore.instance.collection("users");

//   Future<void> saveUser(
//     String name,
//     String password,
//     String phoneNumber,
//     String pinCode,
//   ) async {
//     return await userCollection.doc(uid).set({
//       'name': name,
//       'password': password,
//       'phoneNumber': phoneNumber,
//       'pinCode': pinCode,
//       'treatments': [],
//     });
//   }

//   Future<void> updataDataOfValue(String _name, var _value) async {
//     return await userCollection.doc(uid).update({_name: _value});
//   }

//   Future<void> updateTreatments(List<Treat> userTreatments) async {
//     return await FirebaseFirestore.instance.collection('users').doc(uid).set({
//       'treatments': userTreatments.map((t) => t.toMap()).toList(),
//     }, SetOptions(merge: true));
//   }

//   AppUserData _userFromSnapshot(
//     DocumentSnapshot<Map<String, dynamic>> snapshot,
//   ) {
//     var data = snapshot.data();
//     if (data == null) throw Exception("user not found");
//     return AppUserData(
//       uid: snapshot.id,
//       name: data['name'],
//       password: data['password'],
//       phoneNumber: data['phoneNumber'],
//       pinCode: data['pinCode'],
//       treatments: data['treatments'],
//     );
//   }

//   Stream<AppUserData> get user {
//     return userCollection.doc(uid).snapshots().map(_userFromSnapshot);
//   }

//   List<AppUserData> _userListFromSnapshot(
//     QuerySnapshot<Map<String, dynamic>> snapshot,
//   ) {
//     return snapshot.docs.map((doc) {
//       return _userFromSnapshot(doc);
//     }).toList();
//   }

//   Stream<List<AppUserData>> get users {
//     return userCollection.snapshots().map(_userListFromSnapshot);
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService(this.uid);

  final CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("users");

  Future<void> saveUser(
    String name,
    String password,
    String phoneNumber,
    String pinCode,
  ) async {
    try {
      await userCollection.doc(uid).set({
        'name': name,
        'password': password,
        'phoneNumber': phoneNumber,
        'pinCode': pinCode,
        'treatments': [],
      });
    } catch (e) {
      throw Exception("Failed to save user: $e");
    }
  }

  Future<void> updateDataOfValue(String _name, var _value) async {
    try {
      await userCollection.doc(uid).update({_name: _value});
    } catch (e) {
      throw Exception("Failed to update data: $e");
    }
  }

  Future<void> updateTreatments(List<Treat> userTreatments) async {
    try {
      await userCollection.doc(uid).set({
        'treatments': userTreatments.map((t) => t.toMap()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to update treatments: $e");
    }
  }

  AppUserData _userFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    var data = snapshot.data();
    if (data == null) throw Exception("User not found");

    return AppUserData(
      uid: snapshot.id,
      name: data['name'] ?? 'Unknown',
      password: data['password'] ?? 'Unknown',
      phoneNumber: data['phoneNumber'] ?? 'Unknown',
      pinCode: data['pinCode'] ?? 'Unknown',
      treatments:
          data['treatments'] != null
              ? (data['treatments'] as List)
                  .map((treat) => Treat.fromMap(treat))
                  .toList()
              : [],
    );
  }

  Stream<AppUserData> get user {
    return userCollection.doc(uid).snapshots().map(_userFromSnapshot);
  }

  List<AppUserData> _userListFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return _userFromSnapshot(doc);
    }).toList();
  }

  Stream<List<AppUserData>> get users {
    return userCollection.snapshots().map(_userListFromSnapshot);
  }
}
