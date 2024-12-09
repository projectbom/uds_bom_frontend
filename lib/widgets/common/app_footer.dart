import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(
                title: '회사 소개',
                onTap: () {
                  // 회사 소개 페이지로 이동
                },
              ),
              _FooterDivider(),
              _FooterLink(
                title: '이용약관',
                onTap: () {
                  // 이용약관 페이지로 이동
                },
              ),
              _FooterDivider(),
              _FooterLink(
                title: '개인정보처리방침',
                onTap: () {
                  // 개인정보처리방침 페이지로 이동
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2024 어디서봄. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _FooterLink({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '|',
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
        ),
      ),
    );
  }
}