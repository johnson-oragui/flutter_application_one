import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
    String? emailSaved = await AuthService.getSavedEmail();
    print("emailSaved: $emailSaved");
    if (emailSaved != null) {
      _emailController.text = emailSaved;
    }
  }

  /// Validates email in real-time
  void _validateEmail() {
    final email = _emailController.text;
    if (!_emailFocusNode.hasFocus) {
      if (email != "" && !AuthService.validateEmail(email)) {
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
        _passwordError = AuthService.validatePassword(password);
      });
      return;
    }

    setState(() {
      _passwordError = null;
    });
    setState(() => {});
  }

  // ignore: unused_element
  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    if (_emailError != null ||
        email == "" ||
        _passwordError != null ||
        password == "") {
      return;
    }
    if (email != "johnson@gmail.com" || password != "Johnson1234#") {
      setState(() {
        _emailError = 'Invalid credentials';
        _passwordError = 'Invalid credentials';
      });
      return;
    }

    print('Email: $email');
    print('Password: $password');
    await AuthService.saveEmail(email);
    // Simulate a successful login, and obtain a token
    final String token = "sampleAccessToken";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", token);
    await prefs.setString("user_email", email);
    await prefs.setString("user_id", "1234567890");

    if (context.mounted) {
      Navigator.pushNamed(context, '/dashboard');
    }
    // add authentication logic here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    print("args $args");
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

    bool isLoggedIn = false;

    AuthService.checkIsLoggedIn().then((isIn) {
      isLoggedIn = isIn;
    });

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
    ];

    // conditionally add icons if user is logged in

    if (!isLoggedIn) {
      destinations.add(
        NavigationRailDestination(
          icon: Icon(Icons.login_sharp),
          label: Text('Register'),
        ),
      );

      children.add(
        ListTile(
          leading: const Icon(Icons.login_sharp),
          title: const Text('Register'),
          onTap: () => _handleNavigation(3),
        ),
      );
    }

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
                  ElevatedButton(onPressed: _login, child: const Text('Login')),
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
