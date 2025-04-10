import 'package:cloud_firestore/cloud_firestore.dart';
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
    return await userCollection.doc(uid).set({
      'name': name,
      'password': password,
      'phoneNumber': phoneNumber,
      'pinCode': pinCode,
    });
  }

  Future<void> updataDataOfValue(String _name, var _value) async {
    return await userCollection.doc(uid).update({_name: _value});
  }

  AppUserData _userFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    var data = snapshot.data();
    if (data == null) throw Exception("user not found");
    return AppUserData(
      uid: snapshot.id,
      name: data['name'],
      password: data['password'],
      phoneNumber: data['phoneNumber'],
      pinCode: data['pinCode'],
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
