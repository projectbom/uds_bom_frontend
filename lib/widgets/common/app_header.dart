import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.main),
        child: Image.asset(
          'assets/images/logo.png',
          height: 40,
        ),
      ),
      actions: [
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              return IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
              );
            }
            return TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.auth),
              child: const Text('로그인'),
            );
          },
        ),
      ],
    );
  }
}