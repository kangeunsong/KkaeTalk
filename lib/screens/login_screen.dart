import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'KkaeTalk 로그인 (Day1 더미 화면)',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            // TODO: 나중에 이메일/비밀번호 TextField 추가
            ElevatedButton(
              onPressed: () {
                // Day1: 인증 없이 홈으로 바로 이동
                Navigator.pushReplacementNamed(context, HomeScreen.routeName);
              },
              child: const Text('임시 로그인 (홈으로 이동)'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, SignupScreen.routeName);
              },
              child: const Text('회원가입으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
