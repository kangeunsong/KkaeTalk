import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';
import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  String _buildInterestText(UserProfile profile) {
    final interests = <String>[];

    if (profile.interestPolitics) interests.add('정치');
    if (profile.interestEconomy) interests.add('경제');
    if (profile.interestSociety) interests.add('사회');
    if (profile.interestLifeCulture) interests.add('생활·문화');
    if (profile.interestItScience) interests.add('IT·과학');
    if (profile.interestWorld) interests.add('세계');

    if (interests.isEmpty) {
      return '선택된 카테고리가 없습니다.';
    }
    return interests.join(', ');
  }

  String _buildQuestionLevelText(int level) {
    switch (level) {
      case 1:
        return '레벨 1 · 조용한 모드\nAI가 먼저 질문하지 않아요.';
      case 2:
        return '레벨 2 · 기본 대화 모드\nAI가 가끔 가벼운 질문을 해요.';
      case 3:
        return '레벨 3 · 깊은 대화 모드\nAI가 적극적으로 깊은 질문을 해요.';
      default:
        return '레벨 $level';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
      ),
      body: currentUser == null
          ? const Center(
              child: Text('로그인 정보가 없습니다. 다시 로그인해 주세요.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<UserProfile?>(
                future: UserService.instance.getUserProfile(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('프로필 정보를 불러오는 중 오류가 발생했습니다.'),
                    );
                  }

                  final profile = snapshot.data;
                  if (profile == null) {
                    return const Center(
                      child: Text('프로필 정보를 찾을 수 없습니다.'),
                    );
                  }

                  final interestText = _buildInterestText(profile);
                  final questionLevelText =
                      _buildQuestionLevelText(profile.questionLevel);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이름: ${profile.name}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '이메일: ${profile.email}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '관심 카테고리',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(interestText),
                      const SizedBox(height: 16),
                      const Text(
                        '질문 레벨',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(questionLevelText),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, HistoryScreen.routeName);
                        },
                        child: const Text('기록 보기로 이동'),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
