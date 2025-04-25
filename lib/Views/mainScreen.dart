import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:med_assist/Views/navbar/homeScreen.dart';
import 'package:med_assist/Views/navbar/doctorsScreen.dart';
import 'package:med_assist/Views/navbar/medicalRecordsScreen.dart';
import 'package:med_assist/Views/navbar/settingsScreen.dart';
import 'package:med_assist/Views/navbar/treatScreen.dart';
import 'package:provider/provider.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:med_assist/Models/user.dart';
import 'package:med_assist/Views/Auth/loginScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:iconsax/iconsax.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, required this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late PersistentTabController _controller;
  late AnimationController _animationController;
  late Animation<double> _animationValue;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.initialIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          return PersistentTabView(
            context,
            controller: _controller,
            screens: _buildScreens(
              userData: userData,
              userDataStream: database.user,
            ),
            items: _navBarsItems(),
            handleAndroidBackButtonPress: true,
            resizeToAvoidBottomInset: true,
            stateManagement: true,
            hideNavigationBarWhenKeyboardAppears: true,
            padding: const EdgeInsets.only(top: 8),
            confineToSafeArea: true,
            navBarHeight: 65,
            margin: EdgeInsets.only(bottom: 5),
            backgroundColor: Colors.white,
            navBarStyle: NavBarStyle.style10,
          );
        }
        return const LoginScreen();
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final user = Provider.of<AppUser?>(context);
  //   final userData = Provider.of<AppUserData?>(context);

  //   if (user == null) return const LoginScreen();
  //   if (userData == null) {
  //     return const Scaffold(body: Center(child: CircularProgressIndicator()));
  //   }

  //   return PersistentTabView(
  //     context,
  //     controller: _controller,
  //     screens: _buildScreens(
  //       userData: userData,
  //       // On garde la stream si c’est utilisé dans les écrans :
  //       userDataStream: DatabaseService(user.uid).user,
  //     ),
  //     items: _navBarsItems(),
  //     handleAndroidBackButtonPress: true,
  //     resizeToAvoidBottomInset: true,
  //     stateManagement: true,
  //     hideNavigationBarWhenKeyboardAppears: true,
  //     padding: const EdgeInsets.only(top: 8),
  //     confineToSafeArea: true,
  //     navBarHeight: 65,
  //     margin: const EdgeInsets.only(bottom: 5),
  //     backgroundColor: Colors.white,
  //     navBarStyle: NavBarStyle.style10,
  //   );
  // }

  List<Widget> _buildScreens({
    required AppUserData userData,
    required Stream<AppUserData> userDataStream,
  }) {
    return [
      HomeScreen(persistentTabController: _controller),
      TreatScreen(),
      DoctorsScreen(),
      MedicalRecordsScreen(userData: userData),
      SettingsScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(Iconsax.home),
        icon: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _animationController.isCompleted
                ? AnimatedIcon(
                  icon: AnimatedIcons.home_menu,
                  progress: _animationValue,
                )
                : Icon(Iconsax.home);
          },
        ),
        iconAnimationController: _animationController,
        title: 'home'.tr(),
        activeColorPrimary: Color(0xFF00C853),
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(Iconsax.activity),
        icon: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _animationController.isCompleted
                ? AnimatedIcon(
                  icon: AnimatedIcons.view_list,
                  progress: _animationValue,
                )
                : Icon(Iconsax.activity);
          },
        ),
        iconAnimationController: _animationController,
        title: 'treatments'.tr(),
        activeColorPrimary: Color(0xFF00C853),
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(Iconsax.receipt_add),
        icon: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _animationController.isCompleted
                ? AnimatedIcon(
                  icon: AnimatedIcons.view_list,
                  progress: _animationValue,
                )
                : Icon(Iconsax.receipt_add);
          },
        ),
        iconAnimationController: _animationController,
        title: 'doctors'.tr(),
        activeColorPrimary: Color(0xFF00C853),
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(Iconsax.document),
        icon: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _animationController.isCompleted
                ? AnimatedIcon(
                  icon: AnimatedIcons.view_list,
                  progress: _animationValue,
                )
                : Icon(Iconsax.document);
          },
        ),
        iconAnimationController: _animationController,
        title: 'medical_records'.tr(),
        activeColorPrimary: Color(0xFF00C853),
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(Iconsax.setting_24),
        icon: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _animationController.isCompleted
                ? AnimatedIcon(
                  icon: AnimatedIcons.view_list,
                  progress: _animationValue,
                )
                : Icon(Iconsax.setting_24);
          },
        ),
        iconAnimationController: _animationController,
        title: "settings".tr(),
        activeColorPrimary: Color(0xFF00C853),
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}
