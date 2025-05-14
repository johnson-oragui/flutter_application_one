import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_one/services/secure_auth_storage_service.dart';
import 'package:local_auth/local_auth.dart';

import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final SecuredAuthStorage _securedAuthStorage = securedAuthStorage.value;

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  final hasUppercase = RegExp(r'[A-Z]');
  final hasLowercase = RegExp(r'[a-z]');
  final hasDigit = RegExp(r'\d');
  final hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Signed in uid: ${cred.user?.uid}');

      final idTokenResult = await cred.user?.getIdTokenResult();

      final accessToken = idTokenResult?.token;
      debugPrint('Token: $accessToken');

      final expirationTime = idTokenResult?.expirationTime;
      debugPrint('Expiry: $expirationTime');

      if (accessToken != null && expirationTime != null) {
        await _securedAuthStorage.saveAccessTokenWithExpiry(
          accessToken: accessToken,
          expiry: expirationTime.toIso8601String(),
        );
      }

      return cred;
    } on FirebaseAuthException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint("error: $e");
      debugPrint("Stack trace: $stackTrace");
      return null;
    }
  }

  Future<UserCredential?> register({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_email");
    await prefs.remove("user_id");

    await firebaseAuth.signOut();
    await _securedAuthStorage.clearAllTokens();

    if ((await getSavedEmailOnLogoutOption()) == true) {
      await clearSavedEmailOnLogout();
    }
  }

  Future<String?> getValidAccessToken() async {
    final expiry = await _securedAuthStorage.getAccessTokenExpiry();

    if (expiry != null &&
        DateTime.now().isBefore(expiry.subtract(Duration(minutes: 5)))) {
      // Add 5-Minute Safety Buffer to be extra safe
      return await _securedAuthStorage.readAccessToken();
    }

    if (currentUser != null) {
      final newTokenResult = await currentUser?.getIdTokenResult(true);

      final newToken = newTokenResult?.token;
      final newExpiry = newTokenResult?.expirationTime;

      if (newToken != null && newExpiry != null) {
        await _securedAuthStorage.saveAccessTokenWithExpiry(
          accessToken: newToken,
          expiry: newExpiry.toIso8601String(),
        );
        return newToken;
      }
    }

    return null; // refresh failed
  }

  Future<bool> checkIsLoggedIn() async {
    if (currentUser != null) {
      debugPrint("currentUser logged in uid:  ${currentUser?.uid}");
      return true;
    }
    return false;
  }

  //  caches and refreshes silently in the background on app startup.
  Future<void> initAuth() async {
    final expiry = await _securedAuthStorage.getAccessTokenExpiry();

    final now = DateTime.now();
    if (expiry != null && now.isAfter(expiry.subtract(Duration(minutes: 5)))) {
      if (currentUser != null) {
        final newTokenResult = await currentUser?.getIdTokenResult(true);
        final newToken = newTokenResult?.token;
        final newExpiry = newTokenResult?.expirationTime;

        if (newToken != null && newExpiry != null) {
          await _securedAuthStorage.saveAccessTokenWithExpiry(
            accessToken: newToken,
            expiry: newExpiry.toIso8601String(),
          );
          debugPrint("🔄 Refreshed access token on startup.");
          return;
        }
      }
      // await _tryFingerPrintLogin();
      return;
    }
    debugPrint("✅ Access token is still valid.");
  }

  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// validates password and returns error message if password is invalid or null if valid
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

  // for all platforms
  Future<void> saveEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await checkSavedEmailSetting(prefs)) {
      await prefs.setString("user_email", email);
      await prefs.setString("last_logged_in", email);
    }
  }

  Future<String?> getSavedEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("last_logged_in");
  }

  Future<bool> checkSavedEmailSetting(SharedPreferences? passedPref) async {
    final SharedPreferences prefs;
    if (passedPref != null) {
      prefs = passedPref;
    } else {
      prefs = await SharedPreferences.getInstance();
    }
    bool? saveEmail = prefs.getBool("save_email_on_logout");
    if (saveEmail == null || saveEmail == false) {
      return false;
    }
    return true;
  }

  Future<void> savedEmailOnLogoutOption(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("save_email_on_logout", value);
  }

  Future<void> clearSavedEmailOnLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("last_logged_in");
  }

  Future<bool?> getSavedEmailOnLogoutOption() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("save_email_on_logout");
  }

  Future<void> savedFingerprintLoginOption(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("fingerprint_enabled", value);
  }

  Future<bool> getFingerprintLoginOption() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? enabled = prefs.getBool("fingerprint_enabled");
    if (enabled == null) {
      return false;
    }
    return enabled;
  }

  Future<void> saveUserEmailAndPassword(String email, String password) async {
    await _securedAuthStorage.savePassword(password: password);
    await _securedAuthStorage.saveUserEmail(email: email);
  }

  // attempts to authenticate a user with fingerprint if enabled
  Future<void> tryFingerPrintLogin() async {
    final enabled = await getFingerprintLoginOption();
    if (!enabled) {
      return;
    }
    // b

    final authenticated = await LocalAuthentication().authenticate(
      localizedReason: 'Login with fingerprint',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (authenticated) {
      final email = await _securedAuthStorage.readUserEmail();
      final password = await _securedAuthStorage.readPassword();

      if (email != null && password != null) {
        await login(email: email, password: password);
      }
    }
  }
}
