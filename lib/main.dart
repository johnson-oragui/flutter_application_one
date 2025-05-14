import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_one/firebase_options.dart';

import 'package:flutter_application_one/screens/home_screen.dart';
import 'package:flutter_application_one/screens/login_screen.dart';
import 'package:flutter_application_one/screens/profile_screen.dart';
import 'package:flutter_application_one/screens/register_screen.dart';
import 'package:flutter_application_one/screens/dashboard_screen.dart';
import 'package:flutter_application_one/screens/settings_screen.dart';
import 'package:flutter_application_one/utils/heavy_task.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(const MyApp());

      // Run initAuth after app launch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // compute(runInitAuthInBackground, null);
        runInitAuthInBackground;
      });
    },
    (error, stackTrace) {
      debugPrint("Global error: $error");
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: "/",
      onGenerateRoute: (settings) {
        if (settings.name == "/") {
          return MaterialPageRoute(builder: (context) => AuthGate());
        }
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return DashboardScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
