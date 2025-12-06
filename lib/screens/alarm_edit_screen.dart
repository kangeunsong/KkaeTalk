import 'package:flutter/material.dart';

class AlarmEditScreen extends StatelessWidget {
  const AlarmEditScreen({super.key});

  static const routeName = '/alarm/edit';

  @override
  Widget build(BuildContext context) {
    // Day1: 실제 입력 없이 구조만
    return Scaffold(
      appBar: AppBar(
        title: const Text('알람 생성 / 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text('시간 선택 (TimePicker 예정)'),
            SizedBox(height: 12),
            Text('요일 선택 (토글 버튼 예정)'),
            SizedBox(height: 12),
            Text('소리 / 반복 여부 선택'),
            SizedBox(height: 12),
            Text('토론 주제 선택 (정치/경제/.../랜덤)'),
            SizedBox(height: 24),
            Text('Day1은 라벨만, 실제 위젯은 나중에 넣을 예정'),
          ],
        ),
      ),
    );
  }
}
