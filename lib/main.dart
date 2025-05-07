import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

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
      initialRoute: "/login",
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

        // fallback
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
