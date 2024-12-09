import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onKakaoLogin;
  final VoidCallback onNaverLogin;
  final VoidCallback onGoogleLogin;
  final bool isLoading;

  const SocialLoginButtons({
    Key? key,
    required this.onKakaoLogin,
    required this.onNaverLogin,
    required this.onGoogleLogin,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialLoginButton(
          icon: 'assets/icons/kakao.png',
          text: '카카오로 계속하기',
          backgroundColor: const Color(0xFFFEE500),
          textColor: Colors.black87,
          onPressed: isLoading ? null : onKakaoLogin,
        ),
        const SizedBox(height: 12),
        _SocialLoginButton(
          icon: 'assets/icons/naver.png',
          text: '네이버로 계속하기',
          backgroundColor: const Color(0xFF03C75A),
          textColor: Colors.white,
          onPressed: isLoading ? null : onNaverLogin,
        ),
        const SizedBox(height: 12),
        _SocialLoginButton(
          icon: 'assets/icons/google.png',
          text: '구글로 계속하기',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          onPressed: isLoading ? null : onGoogleLogin,
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          disabledForegroundColor: textColor.withOpacity(0.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }
}