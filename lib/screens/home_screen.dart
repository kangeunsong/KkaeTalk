import 'package:flutter/material.dart';
import 'alarm_edit_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'alarm_chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    // Day1: 알람 데이터 없이 더미 목록/버튼만
    return Scaffold(
      appBar: AppBar(
        title: const Text('KkaeTalk 홈 (알람 목록)'),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.pushNamed(context, ProfileScreen.routeName);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('여기에 알람 목록이 보일 예정 (Day1 더미 텍스트)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AlarmEditScreen.routeName);
              },
              child: const Text('알람 생성 화면으로'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 알람 울린 후 대화 화면 테스트 용
                Navigator.pushNamed(context, AlarmChatScreen.routeName);
              },
              child: const Text('알람 대화 화면 테스트로 이동'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AlarmEditScreen.routeName);
        },
        icon: const Icon(Icons.add_alarm),
        label: const Text('알람 추가'),
      ),
    );
  }
}
