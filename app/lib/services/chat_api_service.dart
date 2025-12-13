import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_summary.dart';

class ChatTurn {
  final String role; // 'user' or 'assistant'
  final String content;

  ChatTurn({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ChatApiService {
  // TODO: 실제 백엔드 주소로 변경 (로컬 테스트면 10.0.2.2)
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<String> sendChat({
    required NewsSummary summary,
    required int questionLevel,
    required List<ChatTurn> history,
  }) async {
    final url = Uri.parse('$baseUrl/chat');

    final body = jsonEncode({
      'summary': summary.summary, // 네가 news_summary.dart에서 어떤 필드명 썼는지 맞춰서
      'question_level': questionLevel,
      'history': history.map((h) => h.toJson()).toList(),
    });

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode != 200) {
      throw Exception('Chat API 실패: ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['reply'] as String;
  }
}
