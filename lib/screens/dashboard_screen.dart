import 'package:flutter/material.dart';

import 'package:flutter_application_one/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/profile');
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
      appBar: AppBar(title: const Text('Dashboard')),
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
                      leading: const Icon(Icons.home),
                      title: const Text('Home'),
                      onTap: () => _handleNavigation(0),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Profile'),
                      onTap: () => _handleNavigation(1),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () => _handleNavigation(2),
                    ),
                    if (_isLoggedIn != null && _isLoggedIn == true) ...[
                      // conditionally add icons if user is logged in
                      ListTile(
                        leading: const Icon(Icons.logout_sharp),
                        title: const Text('Logout'),
                        onTap: () => _handleNavigation(3),
                      ),
                      if (_isLoggedIn == null || _isLoggedIn == false) ...[
                        // conditionally add icons if user is logged in
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
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
                if (_isLoggedIn == null || _isLoggedIn == false) ...[
                  // conditionally add icons if user is logged in
                  NavigationRailDestination(
                    icon: Icon(Icons.login_sharp),
                    label: Text('Login'),
                  ),

                  NavigationRailDestination(
                    icon: Icon(Icons.app_registration_sharp),
                    label: Text('Register'),
                  ),
                  if (_isLoggedIn != null && _isLoggedIn == true) ...[
                    // conditionally add icons if user is logged in
                    NavigationRailDestination(
                      icon: Icon(Icons.logout_sharp),
                      label: Text('Logout'),
                    ),
                  ],
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
