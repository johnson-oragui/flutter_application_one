import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_one/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  // set optional email for case where previous screen is from succesful register
  final String? email;

  const LoginScreen({super.key, this.email});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  String? _emailError;
  String? _passwordError;

  int _selectedIndex = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // check if email was passed from register screen
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }

    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);

    _loadSavedEmail();

    _emailFocusNode.addListener(
      () => setState(() {}),
    ); // rebuild to reflect focus changes
    _passwordFocusNode.addListener(
      () => setState(() {}),
    ); // rebuild to reflect focus changes
  }

  Future<void> _loadSavedEmail() async {
    String? emailSaved = await authService.value.getSavedEmail();
    debugPrint("emailSaved: $emailSaved");
    if (emailSaved != null) {
      _emailController.text = emailSaved;
    }
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
      setState(() {
        _passwordError = authService.value.validatePassword(password);
      });
      return;
    }

    setState(() {
      _passwordError = null;
    });
    setState(() => {});
  }

  // ignore: unused_element
  Future<void> _login(BuildContext context) async {
    try {
      String email = _emailController.text.trim().toLowerCase();
      String password = _passwordController.text.trim();
      if (_emailError != null ||
          email == "" ||
          _passwordError != null ||
          password == "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please completely fill in the fields")),
        );
        return;
      }

      debugPrint('Email: $email');
      debugPrint('Password: $password');

      UserCredential? user = await authService.value.login(
        email: email,
        password: password,
      );
      debugPrint("user $user");
      var addInfo = user?.additionalUserInfo;
      debugPrint("additional user info $addInfo");
      String? userId = user?.user!.uid;
      debugPrint("userId $userId");
      await authService.value.saveEmail(email);
      if (await authService.value.getFingerprintLoginOption()) {
        await authService.value.saveUserEmailAndPassword(email, password);
      }

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
      // add authentication logic here
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        debugPrint('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed. Invalid credentials.")),
        );
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided.');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Invalid credentials.")));
      } else {
        debugPrint('FirebaseAuthException: ${e.code}');
      }
    } catch (e) {
      debugPrint("Exception occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "An unexpected Error occurred. Please try again later.",
          ),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    debugPrint("args $args");
    if (args != null && args.containsKey('email')) {
      _emailController.text = args['email']!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
        Navigator.pushReplacementNamed(context, '/register');
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
        label: Text('Register'),
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
        title: const Text('Register'),
        onTap: () => _handleNavigation(3),
      ),
    ];

    final formContent = Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        // width: 400,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  errorText: _passwordError,
                ),
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _login(context),
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: Text("Register"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isWide) {
      return Scaffold(
        appBar: AppBar(title: const Text("Login")),
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
      appBar: AppBar(title: const Text('Login')),
      drawer: Drawer(width: 160.0, child: ListView(children: children)),
      body: Center(child: SingleChildScrollView(child: formContent)),
    );
  }
}
