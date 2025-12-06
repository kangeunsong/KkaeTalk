import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLogin', false);
    await AuthService.instance.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ListTile(
              title: Text('관심 카테고리 / 질문 레벨 변경 (온보딩 재사용 예정)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, OnboardingScreen.routeName);
              },
              child: const Text('온보딩 화면으로 이동'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _logout(context),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
