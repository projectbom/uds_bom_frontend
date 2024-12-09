// routes.dart
import 'package:flutter/material.dart';
import '../pages/main_page.dart';
import '../pages/map_page.dart';
import '../pages/auth_page.dart';
import '../pages/profile_page.dart';
import '../widgets/auth/login_form.dart';

class AppRoutes {
  static const String main = '/';
  static const String map = '/map';
  static const String auth = '/auth';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case map:
        return MaterialPageRoute(builder: (_) => const MapPage());
      case auth:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: LoginForm(),
              ),
            ),
          ),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(builder: (_) => const MainPage());
    }
  }
}