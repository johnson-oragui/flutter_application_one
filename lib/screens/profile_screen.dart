import 'package:flutter/material.dart';

import 'package:flutter_application_one/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();

    authService.value.checkIsLoggedIn().then((isIn) {
      // isLoggedIn = isIn;
      setState(() {
        _isLoggedIn = isIn;
      });
      debugPrint("during check _isLoggedIn $_isLoggedIn");
    });
  }

  Future<void> _handleNavigation(int index) async {
    // Ensure index is within valid range
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
      case 3:
        await authService.value.logoutUser();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // boolean for calculating the screen size
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('ProfileScreen')),
      drawer:
          isWide
              ? null
              : Drawer(
                width: 160.0,
                child: ListView(
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue),
                      margin: EdgeInsets.only(bottom: 5.0),
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Menu',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.dashboard_customize_sharp),
                      title: const Text('Dashboard'),
                      onTap: () => _handleNavigation(0),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Home'),
                      onTap: () => _handleNavigation(1),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () => _handleNavigation(2),
                    ),
                    if (_isLoggedIn == null || _isLoggedIn == false) ...[
                      ListTile(
                        leading: const Icon(Icons.login_sharp),
                        title: const Text('Login'),
                        onTap: () => _handleNavigation(4),
                      ),

                      ListTile(
                        leading: const Icon(Icons.app_registration_sharp),
                        title: const Text('Register'),
                        onTap: () => _handleNavigation(5),
                      ),
                    ],
                    if (_isLoggedIn != null && _isLoggedIn == true) ...[
                      ListTile(
                        leading: const Icon(Icons.logout_sharp),
                        title: const Text('Logout'),
                        onTap: () => _handleNavigation(3),
                      ),
                    ],
                  ],
                ),
              ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _handleNavigation,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_customize_sharp),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
                if (_isLoggedIn != null && _isLoggedIn == true) ...[
                  NavigationRailDestination(
                    icon: Icon(Icons.logout_sharp),
                    label: Text('Logout'),
                  ),
                ],
                if (_isLoggedIn == null || _isLoggedIn == false) ...[
                  NavigationRailDestination(
                    icon: Icon(Icons.login_sharp),
                    label: Text('Login'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.app_registration_sharp),
                    label: Text('Register'),
                  ),
                ],
              ],
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
