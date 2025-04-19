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
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );

  late AnimationController _animationController;
  late Animation<double> _animationValue;

  @override
  void initState() {
    super.initState();
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
            screens: _buildScreens(userData: userData),
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

  List<Widget> _buildScreens({required AppUserData userData}) {
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
        title: "Home",
        activeColorPrimary: Colors.green,
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
        title: "Treat",
        activeColorPrimary: Colors.green,
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
        title: "Medicine",
        activeColorPrimary: Colors.green,
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
        title: "Medical Records",
        activeColorPrimary: Colors.green,
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
        title: "Settings",
        activeColorPrimary: Colors.green,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}
