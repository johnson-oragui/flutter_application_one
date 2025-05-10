import 'package:flutter/material.dart';

import 'package:flutter_application_one/screens/home_screen.dart';
import 'package:flutter_application_one/screens/login_screen.dart';
import 'package:flutter_application_one/screens/profile_screen.dart';
import 'package:flutter_application_one/screens/register_screen.dart';
import 'package:flutter_application_one/screens/dashboard_screen.dart';
import 'package:flutter_application_one/screens/settings_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initializes Hive for Flutter (mobile, web, desktop)
  await Hive.openBox('emails'); // Open a box (like a database table)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: "/settings",
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          final args = settings.arguments as Map<String, String>?;
          return MaterialPageRoute(
            builder: (context) => LoginScreen(email: args?['email']),
          );
        }
        if (settings.name == '/register') {
          return MaterialPageRoute(builder: (context) => RegistrationScreen());
        }
        if (settings.name == '/dashboard') {
          return MaterialPageRoute(builder: (context) => DashboardScreen());
        }
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => HomeScreen());
        }
        if (settings.name == '/profile') {
          return MaterialPageRoute(builder: (context) => ProfileScreen());
        }
        if (settings.name == '/settings') {
          return MaterialPageRoute(builder: (context) => SettingsScreen());
        }

        // fallback
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
