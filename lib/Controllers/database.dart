import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Models/userSettings.dart';

class DatabaseService {
  final String uid;

  DatabaseService(this.uid);

  final CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance
          .collection("users")
          .doc("patients")
          .collection("users");

  Future<void> saveUser(
    String name,
    String email,
    String password,
    String phoneNumber,
    String pinCode,
  ) async {
    UserSettings userSettings = UserSettings(
      profileUrl: "",
      allowBiometric: true,
      allowNotification: true,
      language: "en",
      theme: "Light",
      alarmMusic: "music1",
    );
    try {
      await userCollection.doc(uid).set({
        'name': capitalizeEachWord(name),
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'pinCode': pinCode,
        'profileUrl': '',
        'treatments': [],
        'doctors': [],
        'appointments': [],
        'requests': [],
        'medicalRecords': [],
        'medicalMessages': [],
        "settings": userSettings.toMap(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception("Failed to save user: $e");
    }
  }

  Future<void> updateDataOfValue(String name, var value) async {
    try {
      await userCollection.doc(uid).update({name: value});
    } catch (e) {
      throw Exception("Failed to update data: $e");
    }
  }

  // Future<void> addElementToArray(String name, var value) async {
  //   try {
  //     await userCollection.doc(uid).update({
  //       name: FieldValue.arrayUnion([value]),
  //     });
  //   } catch (e) {
  //     throw Exception("Failed to add element to array: $e");
  //   }
  // }

  // Future<void> removeElementFromArray(String name, var value) async {
  //   try {
  //     await userCollection.doc(uid).update({
  //       name: FieldValue.arrayRemove([value]),
  //     });
  //   } catch (e) {
  //     throw Exception("Failed to remove element from array: $e");
  //   }
  // }

  Future<void> updateTreatments(List<Treat> userTreatments) async {
    try {
      await userCollection.doc(uid).set({
        'treatments': userTreatments.map((t) => t.toMap()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to update treatments: $e");
    }
  }

  Future<void> updateUserSetting(String name, dynamic value) async {
    try {
      await userCollection.doc(uid).update({'settings.$name': value});
    } catch (e) {
      throw Exception("Failed to update setting '$name': $e");
    }
  }

  Future<dynamic> getUserSetting(String key) async {
    try {
      final docSnapshot = await userCollection.doc(uid).get();

      if (!docSnapshot.exists) {
        throw Exception("User not found");
      }

      final data = docSnapshot.data();
      if (data == null || data['settings'] == null) {
        throw Exception("Settings not found");
      }

      return data['settings'][key];
    } catch (e) {
      throw Exception("Failed to get setting '$key': $e");
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
      email: data['email'] ?? 'Unknown',
      password: data['password'] ?? 'Unknown',
      phoneNumber: data['phoneNumber'] ?? 'Unknown',
      pinCode: data['pinCode'] ?? 'Unknown',
      treatments:
          data['treatments'] != null
              ? (data['treatments'] as List)
                  .map((treat) => Treat.fromMap(treat))
                  .toList()
              : [],
      doctors:
          data['doctors'] != null
              ? List<String>.from(data['doctors'].map((e) => e.toString()))
              : [],
      appointments:
          data['appointments'] != null
              ? List<String>.from(data['appointments'].map((e) => e.toString()))
              : [],
      requests:
          data['requests'] != null
              ? List<String>.from(data['requests'].map((e) => e.toString()))
              : [],
      medicalRecords:
          data['medicalRecords'] != null
              ? List<String>.from(
                data['medicalRecords'].map((e) => e.toString()),
              )
              : [],
      medicalMessages:
          data['medicalMessages'] != null
              ? List<String>.from(
                data['medicalMessages'].map((e) => e.toString()),
              )
              : [],
      userSettings: UserSettings.fromMap(data['settings']),
      createdAt: DateTime.parse(data['createdAt']),
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

String capitalizeEachWord(String input) {
  return input
      .split(' ')
      .map(
        (word) =>
            word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '',
      )
      .join(' ');
}
