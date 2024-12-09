import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'pages/main_page.dart';
import 'providers/auth_provider.dart';

class UdsbomApp extends StatelessWidget {
  const UdsbomApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '어디서봄',
      theme: AppTheme.lightTheme,
      home: const MainPage(), // MainPage를 기본 화면으로 설정
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // textScaleFactor 대신 사용
          ),
          child: child!,
        );
      },
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      locale: const Locale('ko', 'KR'),
    );
  }
}
