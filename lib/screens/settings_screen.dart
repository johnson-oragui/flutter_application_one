import 'package:flutter/material.dart';
import 'package:flutter_application_one/utils/auth_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;

  Future<void> _handleNavigation(int index) async {
    // Ensure index is within valid range
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 3:
        await logoutUser();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/login');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/register');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    bool isLoggedIn = false;

    checkIsLoggedIn().then((isIn) {
      isLoggedIn = isIn;
    });

    // wide screen
    final destinations = [
      NavigationRailDestination(
        icon: Icon(Icons.dashboard_customize_sharp),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.person),
        label: Text('Profile'),
      ),
      NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
    ];

    // not wide screen
    List<Widget> children = [
      const DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue),
        margin: EdgeInsets.only(bottom: 5.0),
        padding: EdgeInsets.only(bottom: 10.0),
        child: Text('Menu', style: TextStyle(color: Colors.white)),
      ),
      ListTile(
        leading: const Icon(Icons.dashboard_customize_sharp),
        title: const Text('Dashboard'),
        onTap: () => _handleNavigation(0),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Profile'),
        onTap: () => _handleNavigation(1),
      ),
      ListTile(
        leading: const Icon(Icons.home),
        title: const Text('Home'),
        onTap: () => _handleNavigation(2),
      ),
    ];

    // conditionally add icons if user is logged in
    if (isLoggedIn) {
      destinations.add(
        NavigationRailDestination(
          icon: Icon(Icons.logout_sharp),
          label: Text('Logout'),
        ),
      );

      children.add(
        ListTile(
          leading: const Icon(Icons.logout_sharp),
          title: const Text('Logout'),
          onTap: () => _handleNavigation(3),
        ),
      );
    }
    if (!isLoggedIn) {
      destinations.add(
        NavigationRailDestination(
          icon: Icon(Icons.login_sharp),
          label: Text('Login'),
        ),
      );
      destinations.add(
        NavigationRailDestination(
          icon: Icon(Icons.app_registration_sharp),
          label: Text('Register'),
        ),
      );

      children.add(
        ListTile(
          leading: const Icon(Icons.login_sharp),
          title: const Text('Login'),
          onTap: () => _handleNavigation(4),
        ),
      );

      children.add(
        ListTile(
          leading: const Icon(Icons.app_registration_sharp),
          title: const Text('Register'),
          onTap: () => _handleNavigation(5),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer:
          isWide
              ? null
              : Drawer(width: 160.0, child: ListView(children: children)),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _handleNavigation,
              destinations: destinations,
              labelType: NavigationRailLabelType.all,
            ),
          const Expanded(
            child: Center(child: Text('Select a section from the menu')),
          ),
        ],
      ),
    );
  }
}
