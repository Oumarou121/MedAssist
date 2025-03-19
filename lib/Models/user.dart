class AppUser {
  final String uid;

  AppUser(this.uid);
}

class AppUserData {
  final String uid;
  final String name;
  final String password;
  final String phoneNumber;
  final String pinCode;

  AppUserData({
    required this.uid,
    required this.name,
    required this.password,
    required this.phoneNumber,
    required this.pinCode,
  });
}
