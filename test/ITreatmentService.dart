import 'package:med_assist/Models/treat.dart';

abstract class ITreatmentService {
  Future<void> addTreatment(Treat treatment);
  Future<void> saveTreatment(Treat treatment);
  Future<void> updateTreatment(Treat treatment);
  Future<void> deleteTreatment(String code);
  Future<Treat> getTreatmentByCode(String code);
  Stream<List<Treat>> get treatments;
  Future<List<Treat>> getPublicTreatments();
  Future<void> addFollowerToTreatment(String code, String followerUid);
  Future<void> removeFollowerFromTreatment(String code, String followerUid);
}

class MockTreatmentService implements ITreatmentService {
  final List<Treat> _storage = [];

  @override
  Future<void> saveTreatment(Treat treatment) async {
    print("saveTreatment called for: ${treatment.code}");
    final index = _storage.indexWhere((t) => t.code == treatment.code);
    if (index != -1) {
      _storage[index] = treatment;
      print("Updated treatment: ${treatment.code}");
    } else {
      _storage.add(treatment);
      print("Added new treatment: ${treatment.code}");
    }
  }

  @override
  Future<void> addTreatment(Treat treatment) async {
    print("addTreatment called for: ${treatment.code}");
    _storage.add(treatment);
  }

  @override
  Future<void> updateTreatment(Treat treatment) async {
    print("updateTreatment called for: ${treatment.code}");
    final index = _storage.indexWhere((t) => t.code == treatment.code);
    if (index != -1) {
      _storage[index] = treatment;
      print("Treatment updated: ${treatment.code}");
    } else {
      print("Treatment not found for update: ${treatment.code}");
      throw Exception("Treatment not found");
    }
  }

  @override
  Future<void> deleteTreatment(String code) async {
    print("deleteTreatment called for: $code");
    _storage.removeWhere((t) => t.code == code);
  }

  @override
  Future<Treat> getTreatmentByCode(String code) async {
    print("getTreatmentByCode called for: $code");
    final found = _storage.firstWhere(
      (t) => t.code == code,
      orElse: () {
        print("Treatment not found: $code");
        throw Exception("Treatment not found");
      },
    );
    return found;
  }

  @override
  Stream<List<Treat>> get treatments async* {
    print("Stream of treatments requested");
    yield _storage;
  }

  @override
  Future<List<Treat>> getPublicTreatments() async {
    print("getPublicTreatments called");
    return _storage.where((t) => t.isPublic).toList();
  }

  @override
  Future<void> addFollowerToTreatment(String code, String followerUid) async {
    print("addFollowerToTreatment called for: $code by $followerUid");
    final index = _storage.indexWhere((t) => t.code == code);
    if (index != -1 && !_storage[index].followers.contains(followerUid)) {
      _storage[index].followers.add(followerUid);
      print("Follower $followerUid added to treatment $code");
    } else {
      print(
        "Follower $followerUid already exists or treatment $code not found",
      );
    }
  }

  @override
  Future<void> removeFollowerFromTreatment(
    String code,
    String followerUid,
  ) async {
    print("removeFollowerFromTreatment called for: $code by $followerUid");
    final index = _storage.indexWhere((t) => t.code == code);
    if (index != -1) {
      _storage[index].followers.remove(followerUid);
      print("Follower $followerUid removed from treatment $code");
    }
  }
}

class ManagersTreats {
  final String uid;
  final String name;
  final ITreatmentService service;

  List<Treat> treats;

  ManagersTreats({
    required this.uid,
    required this.name,
    required this.treats,
    required this.service,
  });

  Future<void> addTreatment(Treat treat) async {
    print("addTreatment called for: ${treat.code}");
    treats.add(treat);
    await service.addTreatment(treat);
  }

  Future<void> updateTreatment(Treat treat) async {
    print("updateTreatment called for: ${treat.code}");
    final index = treats.indexWhere((t) => t.code == treat.code);
    if (index != -1) {
      treats[index] = treat;
      await service.updateTreatment(treat);
      print("Treatment updated: ${treat.code}");
    } else {
      print("Treatment not found for update: ${treat.code}");
    }
  }

  Future<void> removeTreatment(Treat treat) async {
    print("removeTreatment called for: ${treat.code}");
    treats.removeWhere((t) => t.code == treat.code);
    await service.deleteTreatment(treat.code);
  }

  bool alreadyExists(String code) {
    print("alreadyExists called for: $code");
    return treats.any((t) => t.code == code);
  }

  List<Treat> activeTreatments() {
    print("activeTreatments called");
    final active =
        treats.where((t) {
            if (t.isMissing) return false;
            final now = DateTime.now();
            return t.medicines.any(
              (m) => m.createAt.add(Duration(days: m.duration)).isAfter(now),
            );
          }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    print("Active treatments: ${active.length}");
    return active;
  }

  List<Treat> failedTreatments() {
    print("failedTreatments called");
    final failed = treats.where((t) => t.isMissing).toList();
    print("Failed treatments: ${failed.length}");
    return failed;
  }

  List<Treat> finishedTreatments() {
    print("finishedTreatments called");
    final finished =
        treats.where((t) {
          if (t.isMissing) return false;
          final now = DateTime.now();
          return t.medicines.every(
            (m) => m.createAt.add(Duration(days: m.duration)).isBefore(now),
          );
        }).toList();
    print("Finished treatments: ${finished.length}");
    return finished;
  }

  Treat? getTreatmentByCode(String code) {
    print("getTreatmentByCode called for: $code");
    return treats.firstWhere(
      (t) => t.code == code,
      orElse: () {
        print("Treatment not found: $code");
        return Treat(
          authorUid: '',
          authorName: '',
          code: '',
          title: '',
          medicines: [],
          createdAt: DateTime.now(),
          followers: [],
          isPublic: false,
        );
      },
    );
  }
}
