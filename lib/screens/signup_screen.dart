import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  static const routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '회원가입 (이메일, 비밀번호, 이름)\nDay1은 화면 구조만',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 회원가입 후 관심 카테고리 / 질문 레벨 설정 화면으로
                Navigator.pushReplacementNamed(
                    context, OnboardingScreen.routeName);
              },
              child: const Text('임시 회원가입 완료 (온보딩으로 이동)'),
            ),
          ],
        ),
      ),
    );
  }
}
