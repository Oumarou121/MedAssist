class UserSettings {
  final String profileUrl;
  final bool allowBiometric;
  final bool allowNotification;
  final String language;
  final String theme;

  static const languages = ['French', 'English', 'Spanish'];
  static const themes = ['Automatic', 'Light', 'Dark'];

  UserSettings({
    required this.profileUrl,
    required this.allowBiometric,
    required this.allowNotification,
    required this.language,
    required this.theme,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileUrl': profileUrl,
      'allowBiometric': allowBiometric,
      'allowNotification': allowNotification,
      'language': language,
      'theme': theme,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      profileUrl: map['profileUrl'],
      allowBiometric: map['allowBiometric'] ?? true,
      allowNotification: map['allowNotification'] ?? true,
      language: map['language'],
      theme: map['theme'],
    );
  }
}
