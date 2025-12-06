import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  Widget build(BuildContext context) {
    // Day1: UI만 배치, 실제 선택/저장은 나중에
    return Scaffold(
      appBar: AppBar(
        title: const Text('관심 설정 / 질문 레벨'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '관심 카테고리 (예정)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('정치 / 경제 / 사회 / 생활·문화 / IT·과학 / 세계 중 선택'),
            const SizedBox(height: 24),
            const Text(
              '질문 레벨 (1~5)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1: 거의 질문 안 함 ~ 5: 말끝마다 질문 이어가기'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                },
                child: const Text('임시 완료 (홈 화면으로 이동)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
