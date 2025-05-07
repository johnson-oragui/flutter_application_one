import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);

    _emailFocusNode.addListener(
      () => setState(() {}),
    ); // rebuild to reflect focus changes
    _passwordFocusNode.addListener(
      () => setState(() {}),
    ); // rebuild to reflect focus changes
  }

  /// Validates email in real-time
  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!_emailFocusNode.hasFocus) {
      if (email != "" && !emailRegex.hasMatch(email)) {
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
    final hasUppercase = RegExp(r'[A-Z]');
    final hasLowercase = RegExp(r'[a-z]');
    final hasDigit = RegExp(r'\d');
    final hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

    if (!_passwordFocusNode.hasFocus) {
      if (password != "" && !hasUppercase.hasMatch(password)) {
        setState(() {
          _passwordError = "Password must have atleast one upper-case letter";
        });
        return;
      }
      if (password != "" && !hasLowercase.hasMatch(password)) {
        setState(() {
          _passwordError = "Password must have atleast one lower-case letter";
        });
        return;
      }
      if (password != "" && !hasDigit.hasMatch(password)) {
        setState(() {
          _passwordError = "Password must have atleast one digit";
        });
        return;
      }
      if (password != "" && !hasSpecialChar.hasMatch(password)) {
        setState(() {
          _passwordError = "Password must have atleast one special character";
        });
        return;
      }
      if (password != "" && password.length < 8) {
        setState(() {
          _passwordError = "Password must be up to eight(8) in length";
        });
        return;
      }
    }

    setState(() {
      _passwordError = null;
    });
    setState(() => {});
  }

  // ignore: unused_element
  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;
    if (_emailError != null ||
        email == "" ||
        _passwordError != null ||
        password == "") {
      return;
    }
    if (_emailError == null &&
        email != "" &&
        _passwordError == null &&
        password != "") {
      print('Email: $email');
      print('Password: $password');
      // add authentication logic here
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
          // width: MediaQuery.of(context).size.width * 0.5,
          width: 400,
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
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
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
