class Treat {
  final String authorUid;
  final String authorName;
  final String code;
  final String title;
  final List<Medicine> medicines;
  final DateTime createdAt;

  Treat({
    required this.authorUid,
    required this.authorName,
    required this.code,
    required this.title,
    required this.medicines,
    required this.createdAt,
  });

  int get duration {
    return medicines.isEmpty
        ? 0
        : medicines
            .map((medicine) => medicine.duration)
            .reduce((a, b) => a > b ? a : b);
  }

  bool isActive() {
    final endDate = createdAt.add(Duration(days: duration));
    return DateTime.now().isBefore(endDate);
  }
}

class Medicine {
  String name;
  int duration;
  String dose;
  String frequency;

  Medicine({
    required this.name,
    required this.duration,
    required this.dose,
    required this.frequency,
  });
}
