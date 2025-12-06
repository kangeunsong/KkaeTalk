import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context) {
    // Day1: 날짜 선택 / 대화 표시 구조만
    return Scaffold(
      appBar: AppBar(
        title: const Text('대화 기록 보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '날짜 선택 (나중에 DatePicker / 캘린더 예정)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('선택한 날짜의 대화가 여기 채팅 형태로 보일 예정'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Chip(label: Text('(사용자) 예시 메시지')),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(label: Text('(AI) 예시 응답')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
