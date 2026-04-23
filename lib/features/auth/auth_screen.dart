import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  void _goToRegister() => setState(() => _showLogin = false);
  void _goToLogin() => setState(() => _showLogin = true);

  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? LoginScreen(onRegisterTap: _goToRegister)
        : RegisterScreen(onLoginTap: _goToLogin);
  }
}
