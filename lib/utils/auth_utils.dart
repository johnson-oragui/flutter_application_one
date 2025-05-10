import 'package:flutter_application_one/database/models/last_logged_in_email.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hasUppercase = RegExp(r'[A-Z]');
final hasLowercase = RegExp(r'[a-z]');
final hasDigit = RegExp(r'\d');
final hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

bool validateEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

String? validatePassword(String password) {
  String? message;
  if (password != "" && !hasUppercase.hasMatch(password)) {
    message = "Password must have atleast one upper-case letter";
  } else if (password != "" && !hasLowercase.hasMatch(password)) {
    message = "Password must have atleast one lower-case letter";
  } else if (password != "" && !hasDigit.hasMatch(password)) {
    message = "Password must have atleast one digit";
  } else if (password != "" && !hasSpecialChar.hasMatch(password)) {
    message = "Password must have atleast one special character";
  } else if (password != "" && password.length < 8) {
    message = "Password must be up to eight(8) in length";
  }
  return message;
}

String? validatename(String name, int min, int max) {
  String? message;
  if (name != "" && name.length < min) {
    message = "must be longer than $min in length";
  } else if (name != "" && name.length > max) {
    message = "must not be longer than $max";
  } else if (name != "" && hasDigit.hasMatch(name)) {
    message = "must not have a digit";
  } else if (name != "" && hasSpecialChar.hasMatch(name)) {
    message = "must not include a special character";
  }
  return message;
}

// for mobile only
Future<String?> isEmailSaved() async {
  String? emailFound = await LastLoggedInEmail.fetchEmail();
  return emailFound;
}

// for all platforms
Future<void> saveEmail(String email) async {
  final box = Hive.box('emails');
  await box.put('last_logged_in', email);
}

Future<String?> getSavedEmail() async {
  final box = Hive.box('emails');
  return box.get('last_logged_in');
}

Future<void> logoutUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("access_token");
  await prefs.remove("user_email");
  await prefs.remove("user_id");
}

Future<bool> checkIsLoggedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString("access_token");
  print("accessToken $accessToken");
  if (accessToken != null) {
    return true;
  }
  return false;
}
