import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_one/services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreen();
}

class _RegistrationScreen extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstnameController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _firstnameError;

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _firstnameFocusNode = FocusNode();

  int _selectedIndex = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
    _firstnameController.addListener(_validateFirstname);

    _emailFocusNode.addListener(
      () => setState(() {}),
    ); // rebuild to reflect focus changes
    _passwordFocusNode.addListener(
      () => setState(() {}),
    ); // rebuild to reflect focus changes
    _firstnameFocusNode.addListener(
      () => setState(() {}),
    ); // rebuild to reflect focus changes
    _confirmPasswordFocusNode.addListener(
      () => setState(() {}),
    ); // rebuild to reflect focus changes
  }

  /// Validates email in real-time
  void _validateEmail() {
    final email = _emailController.text;
    if (!_emailFocusNode.hasFocus) {
      if (email != "" && !authService.value.validateEmail(email)) {
        setState(() {
          _emailError = "invalid email";
        });
        return;
      }
    }

    setState(() {
      _emailError = null;
    });
    setState(() {});
  }

  /// Validates password in real-time
  void _validatePassword() {
    final password = _passwordController.text.trim();

    if (!_passwordFocusNode.hasFocus) {
      String? res = authService.value.validatePassword(password);
      setState(() {
        _passwordError = res;
      });
      return;
    }

    setState(() {
      _passwordError = null;
    });
    setState(() => {});
  }

  void _validateConfirmPassword() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    debugPrint("password $password");
    debugPrint("confirmPassword $confirmPassword");

    if (!_confirmPasswordFocusNode.hasFocus) {
      if (password != confirmPassword) {
        setState(() {
          _confirmPasswordError = "password and confirm password\n must match";
        });
        return;
      }
      setState(() {
        _confirmPasswordError = null;
      });
      setState(() => {});
    }

    setState(() {
      _confirmPasswordError = null;
    });
    setState(() => {});
  }

  /// validate first name in real time
  void _validateFirstname() {
    final firstname = _firstnameController.text;
    if (!_firstnameFocusNode.hasFocus) {
      String? res = authService.value.validatename(firstname, 3, 50);
      if (res != null) {
        setState(() {
          _firstnameError = "firstname $res";
        });
        return;
      }
      setState(() {
        _firstnameError = null;
      });
      return;
    }

    setState(() {
      _firstnameError = null;
    });
    setState(() => {});
  }

  Future<void> _register(BuildContext context) async {
    try {
      String email = _emailController.text.trim().toLowerCase();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String firstname = _firstnameController.text.trim();

      if (_emailError != null ||
          email == "" ||
          _passwordError != null ||
          password == "" ||
          firstname == "" ||
          _firstnameError != null ||
          _confirmPasswordError != null ||
          confirmPassword == "") {
        debugPrint("confirm password error:  $_confirmPasswordError");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("All fields must be filled")),
          snackBarAnimationStyle: AnimationStyle(
            duration: Duration(seconds: 2),
            curve: Curves.bounceInOut,
          ),
        );
        return;
      }

      debugPrint('Email: $email');
      debugPrint('Password: $password');
      debugPrint('firstname: $firstname');

      UserCredential? newUser = await authService.value.register(
        email: email,
        password: password,
      );
      var additionalUserInfo = newUser?.additionalUserInfo;
      debugPrint("additional user info $additionalUserInfo");
      User? user = newUser?.user;
      debugPrint("user $user");

      // pass the email to login email field
      Navigator.pushReplacementNamed(
        context,
        "/login",
        arguments: <String, String>{'email': email},
      );
      // add authentication logic here
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        debugPrint("FirebaseAuthException: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Email already in use.")));
      }
    } catch (e) {
      debugPrint("error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Register failed: $e")));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstnameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation(int index) async {
    // Ensure index is within valid range
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/profile');
        break;
      case 2:
        Navigator.pushNamed(context, '/home');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

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
      NavigationRailDestination(
        icon: Icon(Icons.login_sharp),
        label: Text('Login'),
      ),
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
      ListTile(
        leading: const Icon(Icons.login_sharp),
        title: const Text('Login'),
        onTap: () => _handleNavigation(4),
      ),
    ];

    final formContent = Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstnameController,
              decoration: InputDecoration(
                labelText: 'Firstname',
                border: OutlineInputBorder(),
                errorText: _firstnameError,
                focusColor: Color.fromARGB(0, 63, 168, 53),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                errorText: _passwordError,
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                errorText: _confirmPasswordError,
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  child: const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () => _register(context),
                  child: Text("Register"),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isWide) {
      return Scaffold(
        appBar: AppBar(title: const Text("Register")),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _handleNavigation,
              labelType: NavigationRailLabelType.all,
              destinations: destinations,
            ),
            const VerticalDivider(),
            Expanded(child: SingleChildScrollView(child: formContent)),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      drawer: Drawer(width: 160.0, child: ListView(children: children)),
      body: Center(child: SingleChildScrollView(child: formContent)),
    );
  }
}
