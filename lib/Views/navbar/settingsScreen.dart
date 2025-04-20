// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:med_assist/Controllers/database.dart';
// import 'package:med_assist/Models/user.dart';
// import 'package:med_assist/Views/Auth/loginScreen.dart';
// import 'package:provider/provider.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//     final mediaQuery = MediaQuery.of(context);
//     final bottomPadding = mediaQuery.viewInsets.bottom;

//     final user = Provider.of<AppUser?>(context);
//     if (user == null) return const LoginScreen();
//     final database = DatabaseService(user.uid);

//     return StreamBuilder<AppUserData>(
//       stream: database.user,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasData) {
//           AppUserData? userData = snapshot.data;
//           if (userData == null) return const LoginScreen();

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: Scaffold(
//               body: Padding(
//                 padding: EdgeInsets.only(bottom: bottomPadding + 40),
//                 child: SafeArea(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: <Widget>[
//                         _top(),
//                         SizedBox(height: size.height * 0.03),
//                         SizedBox(height: size.height * 0.03),
//                         SizedBox(height: size.height * 0.03),
//                         SizedBox(height: size.height * 0.03),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }
//         return const LoginScreen();
//       },
//     );
//   }

//   Widget _top() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'My Settings',
//           style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
//         ),
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Icon(Iconsax.setting_3, size: 24, color: Colors.black),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_assist/Views/settings/change_email_page.dart';
import 'package:med_assist/Views/settings/change_password_page.dart';
import 'package:med_assist/Views/settings/edit_profile_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricAuth = false;
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('Compte'),
          _buildAccountSettings(),
          const SizedBox(height: 24),
          _buildSectionTitle('Préférences'),
          _buildAppPreferences(),
          const SizedBox(height: 24),
          _buildSectionTitle('Sécurité'),
          _buildSecuritySettings(),
          const SizedBox(height: 24),
          _buildSectionTitle('Support'),
          _buildSupportOptions(),
          const SizedBox(height: 40),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage('https://example.com/profile.jpg'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jean Dupont',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'jean.dupont@email.com',
              style: TextStyle(color: Colors.grey[600]),
            ),
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

  Widget _buildAccountSettings() {
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
            title: 'Modifier le profil',
            trailing: Icon(Icons.chevron_right),
            onTap: () => _navigateToEditProfile(),
          ),
          _buildDivider(),
          _buildListTile(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const ChangeEmailPage(
                          currentEmail: 'demo@gmail.com',
                        ),
                  ),
                ),
            icon: Icons.email_outlined,
            title: 'Changer l\'email',
            trailing: Icon(Icons.chevron_right),
          ),
          _buildDivider(),
          _buildListTile(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                ),
            icon: Icons.lock_outline,
            title: 'Changer le mot de passe',
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Mode sombre',
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.language,
            title: 'Langue',
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items:
                  ['Français', 'English', 'Español']
                      .map(
                        (lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedLanguage = value!),
              underline: const SizedBox(),
              icon: const SizedBox(),
            ),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.data_saver_off,
            title: 'Mode économie de données',
            value: false,
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
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
            title: 'Authentification biométrique',
            value: _biometricAuth,
            onChanged: (v) => setState(() => _biometricAuth = v),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Notifications',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
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
            title: 'Centre d\'aide',
            trailing: Icon(Icons.chevron_right),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            trailing: Icon(Icons.chevron_right),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.security_outlined,
            title: 'Politique de confidentialité',
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
          'Déconnexion',
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

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfilePage(
              initialName: 'Jean Dupont',
              initialEmail: 'jean.dupont@email.com',
              initialPhone: '+33 6 12 34 56 78',
              initialPhoto: 'https://example.com/profile.jpg',
            ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la déconnexion'),
            content: const Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implémenter la déconnexion
                },
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
