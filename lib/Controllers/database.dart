import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService(this.uid);

  final CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance
          .collection("users")
          .doc("patients")
          .collection("users");

  final CollectionReference<Map<String, dynamic>> userCollectionConfig =
      FirebaseFirestore.instance.collection("config");

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
        'doctors': [],
        'appointments': [],
        'requests': [],
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
