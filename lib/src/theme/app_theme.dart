import 'package:flutter/material.dart';

class AppTheme {
  // 메인 색상을 더 밝고 세련된 파란색으로 변경
  static const Color primaryColor = Color(0xFF2196F3); // 밝은 파란색
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color subtextColor = Colors.black54;

  // 소셜 로그인 버튼 색상
  static const Color naverColor = Color(0xFF03C75A);
  static const Color facebookColor = Color(0xFF1877F2);
  static const Color googleColor = Color(0xFFEA4335);
  static const Color kakaoColor = Color(0xFFFEE500);

  // 공통 버튼 스타일
  static final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // 각진 모서리에 살짝만 라운드 처리
    ),
    elevation: 0, // 그림자 제거
  );

  static ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: buttonStyle,
        ),
      );
}