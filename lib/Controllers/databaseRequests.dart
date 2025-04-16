import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/doctor.dart';

class RequestService {
  final CollectionReference<Map<String, dynamic>> requestCollection =
      FirebaseFirestore.instance.collection('requests');

  Future<void> addRequest(Request request) async {
    await requestCollection.doc(request.id).set(request.toMap());
  }

  Future<void> deleteRequest(String id) async {
    await requestCollection.doc(id).delete();
  }

  Future<void> updateRequest(Request request) async {
    await requestCollection.doc(request.id).update(request.toMap());
  }

  Stream<Request> getRequest(String id) {
    return requestCollection.doc(id).snapshots().map((snapshot) {
      return Request.fromMap(snapshot.data()!);
    });
  }

  Stream<List<Request>> getRequestsByUser(String uid, SenderType type) {
    String field = type == SenderType.doctor ? 'doctorUid' : 'patientUid';
    return requestCollection
        .where(field, isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Request.fromMap(doc.data())).toList(),
        );
  }

  Stream<List<Request>> getRequestsByType(RequestType type) {
    return requestCollection
        .where('requestType', isEqualTo: type.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Request.fromMap(doc.data())).toList(),
        );
  }

  Stream<List<Request>> getRequestsByStatus(RequestStatus status) {
    return requestCollection
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Request.fromMap(doc.data())).toList(),
        );
  }

  Future<List<Request>> getRequestsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshots = await Future.wait(
      ids.map((id) => requestCollection.doc(id).get()),
    );

    return snapshots
        .where((snap) => snap.exists)
        .map((snap) => Request.fromMap(snap.data()!))
        .toList();
  }
}
