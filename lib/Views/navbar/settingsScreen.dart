import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_assist/Controllers/authentication.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Controllers/noti_service.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Models/userSettings.dart';
import 'package:med_assist/Views/Auth/forgotPasswordScreen.dart';
import 'package:med_assist/Views/Auth/forgotPinCodeScreen.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:med_assist/Views/settings/edit_profile_page.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;
    final user = Provider.of<AppUser?>(context);
    if (user == null) return const LoginScreen();
    final database = DatabaseService(user.uid);

    return StreamBuilder<AppUserData>(
      stream: database.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          AppUserData? userData = snapshot.data;
          if (userData == null) return const LoginScreen();
          final DatabaseService db = DatabaseService(userData.uid);

          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding + 60),
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F7FB),
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 80,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'my_settings'.tr(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFFB2FF59)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    actions: [],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.01),
                          _buildProfileHeader(userData: userData),
                          SizedBox(height: size.height * 0.03),
                          _buildSectionTitle('account'.tr()),
                          _buildAccountSettings(userData: userData),
                          SizedBox(height: size.height * 0.03),
                          _buildSectionTitle('preferences'.tr()),
                          _buildAppPreferences(userData: userData),
                          SizedBox(height: size.height * 0.03),
                          _buildSectionTitle('security'.tr()),
                          _buildSecuritySettings(userData: userData, db: db),
                          SizedBox(height: size.height * 0.03),
                          _buildSectionTitle('support'.tr()),
                          _buildSupportOptions(),
                          SizedBox(height: size.height * 0.06),
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const LoginScreen();
      },
    );
  }

  Widget _buildProfileHeader({required AppUserData userData}) {
    return Row(
      children: [
        userData.userSettings.profileUrl != ''
            ? CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(userData.userSettings.profileUrl),
            )
            : CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF00C853),
              child: Text(
                userData.name[0],
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userData.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(userData.email, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAccountSettings({required AppUserData userData}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person_outline,
            title: 'edit_profile'.tr(),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _navigateToEditProfile(userData: userData),
          ),
          _buildDivider(),
          _buildListTile(
            onTap:
                () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                ),
            icon: Icons.lock_outline,
            title: 'change_password'.tr(),
            trailing: Icon(Icons.chevron_right),
          ),
          _buildDivider(),
          _buildListTile(
            onTap:
                () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder:
                        (context) => ForgotPinCodeScreen(userData: userData),
                  ),
                ),
            icon: Icons.pin,
            title: 'change_pin'.tr(),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences({required AppUserData userData}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.dark_mode_outlined,
            title: 'theme'.tr(),
            trailing: DropdownButton<String>(
              value: userData.userSettings.theme,
              items:
                  UserSettings.themes.map((theme) {
                    return DropdownMenuItem<String>(
                      value: theme,
                      child: Text(theme.tr()),
                    );
                  }).toList(),
              onChanged: (value) async {
                //
                await DatabaseService(
                  userData.uid,
                ).updateUserSetting("theme", value);
              },
              underline: const SizedBox(),
              icon: const SizedBox(),
            ),
          ),

          _buildDivider(),
          _buildListTile(
            icon: Icons.language,
            title: 'language'.tr(),
            trailing: DropdownButton<String>(
              value: UserSettings.getLabelFromCode(
                userData.userSettings.language,
              ),
              items:
                  UserSettings.languages.keys.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang.tr()),
                    );
                  }).toList(),
              onChanged: (selectedLabel) async {
                final selectedCode = UserSettings.languages[selectedLabel]!;
                await context.setLocale(Locale(selectedCode));
                final DatabaseService db = DatabaseService(userData.uid);
                await db.updateUserSetting("language", selectedCode);
              },
              underline: const SizedBox(),
              icon: const SizedBox(),
            ),
          ),

          _buildDivider(),
          _buildListTile(
            icon: Icons.library_music,
            title: 'alarm_music'.tr(),
            trailing: DropdownButton<String>(
              value: UserSettings.getLabelFromCodeMusics(
                userData.userSettings.alarmMusic,
              ),
              items:
                  UserSettings.alarmMusics.keys.map((alarm) {
                    return DropdownMenuItem<String>(
                      value: alarm,
                      child: Text(alarm),
                    );
                  }).toList(),
              onChanged: (selectedLabel) async {
                final selectedCode = UserSettings.alarmMusics[selectedLabel]!;
                final DatabaseService db = DatabaseService(userData.uid);
                await db.updateUserSetting("alarmMusic", selectedCode);

                //Redefine all alarm
                ManagersTreats managersTreats = ManagersTreats(
                  uid: userData.uid,
                  name: userData.name,
                  treats: userData.treatments,
                );

                managersTreats.redefineAlarm();
              },
              underline: const SizedBox(),
              icon: const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings({
    required AppUserData userData,
    required DatabaseService db,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: 'biometric_auth'.tr(),
            value: userData.userSettings.allowBiometric,
            onChanged: (v) async {
              await db.updateUserSetting("allowBiometric", v);
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'notifications'.tr(),
            value: userData.userSettings.allowNotification,
            onChanged: (v) async {
              await db.updateUserSetting("allowNotification", v);
              ManagersTreats managersTreats = ManagersTreats(
                uid: userData.uid,
                name: userData.name,
                treats: userData.treatments,
              );
              if (v) {
                managersTreats.checkAlarm();
              } else {
                NotiService().cancelAllAlarm();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.help_outline,
            title: 'help_center'.tr(),
            trailing: Icon(Icons.chevron_right),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'terms'.tr(),
            trailing: Icon(Icons.chevron_right),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.security_outlined,
            title: 'privacy_policy'.tr(),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(
          'logout'.tr(),
          style: GoogleFonts.poppins(color: Colors.red),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _confirmLogout(),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF00C853)),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[800]),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green[800],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200]);
  }

  void _navigateToEditProfile({required AppUserData userData}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: userData),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('confirm_logout'.tr()),
            content: Text('confirm_logout_content'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final AuthenticationService auth = AuthenticationService();
                  auth.signOut();
                },
                child: Text('logout'.tr(), style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
