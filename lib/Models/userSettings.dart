class UserSettings {
  final String profileUrl;
  final bool allowBiometric;
  final bool allowNotification;
  final String language;
  final String theme;
  final String alarmMusic;

  static const languages = {'French': 'fr', 'English': 'en'};
  static const alarmMusics = {
    'Song 1': 'music1',
    'Song 2': 'music2',
    'Song 3': 'music3',
    'Song 4': 'music4',
  };
  static const themes = ['Automatic', 'Light', 'Dark'];

  UserSettings({
    required this.profileUrl,
    required this.allowBiometric,
    required this.allowNotification,
    required this.language,
    required this.theme,
    required this.alarmMusic,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileUrl': profileUrl,
      'allowBiometric': allowBiometric,
      'allowNotification': allowNotification,
      'language': language,
      'theme': theme,
      'alarmMusic': alarmMusic,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      profileUrl: map['profileUrl'],
      allowBiometric: map['allowBiometric'] ?? true,
      allowNotification: map['allowNotification'] ?? true,
      language: map['language'],
      theme: map['theme'],
      alarmMusic: map['alarmMusic'],
    );
  }

  static String getLabelFromCode(String code) {
    return languages.entries
        .firstWhere(
          (entry) => entry.value == code,
          orElse: () => MapEntry('Unknown', ''),
        )
        .key;
  }

  static String getLabelFromCodeMusics(String code) {
    return alarmMusics.entries
        .firstWhere(
          (entry) => entry.value == code,
          orElse: () => MapEntry('Unknown', ''),
        )
        .key;
  }
}
