// class Doctor {
//   final String imageUrl;
//   final String name;
//   final String specialty;
//   final String experience;

//   Doctor({
//     required this.imageUrl,
//     required this.name,
//     required this.specialty,
//     required this.experience,
//   });
// }

class Doctor {
  final String id;
  final String imageUrl;
  final String name;
  final String specialty;
  final String experience;
  final String phoneNumber;
  final String email;
  final String address;
  final double rating;
  final List<String> availableDays;
  final List<String> availableHours;
  final String bio;
  final List<String> languages;
  final bool isOnline;
  final String gender;
  final String licenseNumber;
  final String hospital;

  Doctor({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.rating,
    required this.availableDays,
    required this.availableHours,
    required this.bio,
    required this.languages,
    required this.isOnline,
    required this.gender,
    required this.licenseNumber,
    required this.hospital,
  });
}
