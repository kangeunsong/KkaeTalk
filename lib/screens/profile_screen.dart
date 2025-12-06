import 'package:flutter/material.dart';
import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    // Day1: Firebase 유저 정보 없이 더미 텍스트
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이름: (나중에 Firebase에서 불러오기)',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text('이메일: (나중에 Firebase Auth에서 가져오기)'),
            const SizedBox(height: 8),
            const Text('관심 카테고리: (Firestore에서 가져오기)'),
            const SizedBox(height: 8),
            const Text('질문 레벨: (Firestore에서 가져오기)'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, HistoryScreen.routeName);
              },
              child: const Text('기록 보기로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
