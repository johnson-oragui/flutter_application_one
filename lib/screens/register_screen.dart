import 'package:flutter/material.dart';
import 'package:flutter_application_one/utils/auth_utils.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreen();
}

class _RegistrationScreen extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _firstnameError;

  final _passwordFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _firstnameFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
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
      String? res = validatePassword(password);
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

  /// validate first name in real time
  void _validateFirstname() {
    final firstname = _firstnameController.text;
    if (!_firstnameFocusNode.hasFocus) {
      String? res = validatename(firstname, 3, 50);
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

  void _register() {
    String email = _emailController.text;
    String password = _passwordController.text;
    String firstname = _firstnameController.text;

    if (_emailError != null ||
        email == "" ||
        _passwordError != null ||
        password == "" ||
        firstname == "" ||
        _firstnameError != null) {
      return;
    }

    print('Email: $email');
    print('Password: $password');
    print('firstname: $firstname');

    // pass the email to login email field
    Navigator.pushNamed(
      context,
      "/login",
      arguments: <String, String>{'email': _emailController.text},
    );
    // add authentication logic here
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: Container(
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
                      onPressed: _register,
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
