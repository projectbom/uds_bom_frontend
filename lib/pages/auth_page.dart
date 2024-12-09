import 'package:flutter/material.dart';
import '../widgets/common/app_header.dart';
import '../widgets/auth/login_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: const Card(
            margin: EdgeInsets.all(16),
            child: LoginForm(),
          ),
        ),
      ),
    );
  }
}