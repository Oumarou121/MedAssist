import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_assist/Models/doctor.dart';

class AppointmentService {
  final CollectionReference<Map<String, dynamic>> appointmentCollection =
      FirebaseFirestore.instance.collection('appointments');

  Future<void> addAppointment(Appointment appointment) async {
    await appointmentCollection.doc(appointment.id).set(appointment.toMap());
  }

  Future<void> deleteAppointment(String id) async {
    await appointmentCollection.doc(id).delete();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await appointmentCollection.doc(appointment.id).update(appointment.toMap());
  }

  Future<Appointment> getAppointment(String id) async {
    print(id);
    final snapshot = await appointmentCollection.doc(id).get();
    return Appointment.fromMap(snapshot.data()!);
  }

  Stream<List<Appointment>> getAppointmentsByDoctor(String doctorUid) {
    return appointmentCollection
        .where('doctorUid', isEqualTo: doctorUid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Appointment.fromMap(doc.data()))
                  .toList(),
        );
  }

  Stream<List<Appointment>> getAppointmentsByPatient(String patientUid) {
    return appointmentCollection
        .where('patientUid', isEqualTo: patientUid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Appointment.fromMap(doc.data()))
                  .toList(),
        );
  }

  Future<List<Appointment>> getAppointmentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshots = await Future.wait(
      ids.map((id) => appointmentCollection.doc(id).get()),
    );

    return snapshots
        .where((snap) => snap.exists)
        .map((snap) => Appointment.fromMap(snap.data()!))
        .toList();
  }
}
