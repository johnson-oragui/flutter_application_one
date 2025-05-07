import 'package:flutter/material.dart';
import 'package:flutter_application_one/utils/auth_utils.dart';

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
    String? emailSaved = await getSavedEmail();
    print("emailSaved: $emailSaved");
    if (emailSaved != null) {
      _emailController.text = emailSaved;
    }
  }

  /// Validates email in real-time
  void _validateEmail() {
    final email = _emailController.text;
    if (!_emailFocusNode.hasFocus) {
      if (email != "" && !validateEmail(email)) {
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
        _passwordError = validatePassword(password);
      });
      return;
    }

    setState(() {
      _passwordError = null;
    });
    setState(() => {});
  }

  // ignore: unused_element
  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    if (_emailError != null ||
        email == "" ||
        _passwordError != null ||
        password == "") {
      return;
    }

    print('Email: $email');
    print('Password: $password');
    await saveEmail(email);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
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
                      onPressed: _login,
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
      ),
    );
  }
}
