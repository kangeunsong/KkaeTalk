import 'package:flutter/material.dart';

class AlarmChatScreen extends StatelessWidget {
  const AlarmChatScreen({super.key});

  static const routeName = '/alarm/chat';

  @override
  Widget build(BuildContext context) {
    // Day1: 채팅 UI 골격만
    return Scaffold(
      appBar: AppBar(
        title: const Text('깨톡 알람 대화'),
      ),
      body: Column(
        children: [
          // 상단 뉴스 요약 영역 (나중에 백엔드 연동)
          Container(
            width: double.infinity,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(12),
            child: const Text(
              '여기에 오늘 뉴스 요약이 보일 예정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          // 채팅 영역
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text('(AI) 안녕하세요, 오늘의 뉴스를 알려드릴게요.')),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Chip(label: Text('(나) 네, 알려주세요.')),
                ),
              ],
            ),
          ),
          // 입력 / STT 버튼 영역 (Day1: 더미 버튼)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // 나중에 STT 버튼
                    },
                    icon: const Icon(Icons.mic),
                  ),
                  const Expanded(
                    child: Text('Day1: STT 결과가 들어올 자리'),
                  ),
                  TextButton(
                    onPressed: () {
                      // 나중에 종료 멘트 처리
                      Navigator.pop(context);
                    },
                    child: const Text('대화 종료'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
