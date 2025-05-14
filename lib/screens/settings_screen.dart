import 'package:flutter/material.dart';

import 'package:flutter_application_one/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;
  bool? _isLoggedIn;
  bool _fingerprintEnabled = false;
  bool? _clearEmailOnLogout;

  @override
  void initState() {
    super.initState();

    authService.value.checkIsLoggedIn().then((isIn) {
      setState(() {
        _isLoggedIn = isIn;
      });
      debugPrint("during check _isLoggedIn $_isLoggedIn");
    });

    authService.value.getSavedEmailOnLogoutOption().then((bool? value) {
      if (value == null) {
        setState(() {
          _clearEmailOnLogout = false;
        });
      } else {
        setState(() {
          _clearEmailOnLogout = value;
        });
      }
    });

    authService.value.getFingerprintLoginOption().then((bool? value) {
      if (value != null) {
        setState(() {
          _fingerprintEnabled = value;
        });
      }
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
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 3:
        await authService.value.logoutUser();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                      title: const Text('Profile'),
                      onTap: () => _handleNavigation(1),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Home'),
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
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text('Settings', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: Text('Clear email on logout'),
                  subtitle: const Text('Remove saved email when you log out'),
                  value: _clearEmailOnLogout ?? false,
                  onChanged: (bool newValue) {
                    setState(() {
                      _clearEmailOnLogout = newValue;
                    });
                    debugPrint("_clearEmailOnLogout: $_clearEmailOnLogout");
                    authService.value.savedEmailOnLogoutOption(
                      _clearEmailOnLogout ?? false,
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text("Enable Fingerprint Login"),
                  subtitle: const Text('Use biometric authentication'),
                  value: _fingerprintEnabled,
                  onChanged: (bool newValue) {
                    setState(() {
                      _fingerprintEnabled = newValue;
                    });
                    debugPrint("_fingerprintEnabled: $_fingerprintEnabled");
                    authService.value.savedFingerprintLoginOption(newValue);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
