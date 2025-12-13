import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_summary.dart';

class NewsApiService {
  NewsApiService._();
  static final instance = NewsApiService._();

  // 에뮬레이터에서는 localhost 대신 10.0.2.2 사용 (중요!)
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<NewsSummary> fetchNewsSummary(String url) async {
    final uri = Uri.parse('$_baseUrl/news-summary');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return NewsSummary.fromJson(json);
    } else {
      throw Exception(
        '뉴스 요약 실패: ${response.statusCode} ${response.body}',
      );
    }
  }
}
