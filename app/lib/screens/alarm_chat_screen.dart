import 'package:flutter/material.dart';
import '../models/news_summary.dart';
import '../services/news_api_service.dart';
import '../services/chat_api_service.dart';

class AlarmChatScreen extends StatefulWidget {
  const AlarmChatScreen({super.key});

  static const routeName = '/alarm/chat';

  @override
  State<AlarmChatScreen> createState() => _AlarmChatScreenState();
}

// 간단한 채팅 메시지 모델
class _ChatMessage {
  final bool isUser; // true: 사용자, false: AI
  final String text;

  _ChatMessage({required this.isUser, required this.text});
}

class _AlarmChatScreenState extends State<AlarmChatScreen> {
  // 상단 뉴스 요약 (전체 객체 + 요약 텍스트)
  NewsSummary? _newsSummary;
  String? _newsSummaryText;
  bool _isLoadingSummary = false;
  String? _summaryError;

  // 채팅 메시지 리스트
  final List<_ChatMessage> _messages = [];

  // 텍스트 입력 컨트롤러
  final TextEditingController _inputController = TextEditingController();

  // LLM 요청 중 상태
  bool _isSending = false;

  // TODO: 나중에 Firestore에서 사용자 설정(questionLevel) 읽어오도록 변경
  final int _questionLevel = 2;

  @override
  void initState() {
    super.initState();
    _loadNewsSummaryAndStartChat();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _loadNewsSummaryAndStartChat() async {
    setState(() {
      _isLoadingSummary = true;
      _summaryError = null;
    });

    try {
      // TODO: 나중에는 알람 설정에 따라 URL을 다르게 넘기기
      const demoNewsUrl =
          'https://n.news.naver.com/mnews/article/015/0005012345';

      final NewsSummary summary =
          await NewsApiService.instance.fetchNewsSummary(demoNewsUrl);

      if (!mounted) return;

      setState(() {
        _newsSummary = summary;
        _newsSummaryText = summary.summary;
        _isLoadingSummary = false;

        // 첫 AI 메시지로 요약 내용 추가
        _messages.insert(
          0,
          _ChatMessage(
            isUser: false,
            text: '좋은 아침이에요! 오늘 이런 뉴스가 있었어요:\n\n${summary.summary}',
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSummary = false;
        _summaryError = '뉴스 요약을 가져오지 못했어요. 나중에 다시 시도해 주세요.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('뉴스 요약 로딩 실패: $e')),
      );
    }
  }

  Future<void> _sendUserMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    if (_newsSummary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('뉴스 요약을 아직 불러오지 못했어요. 잠시 후 다시 시도해 주세요.')),
      );
      return;
    }
    if (_isSending) return;

    setState(() {
      // 사용자 메시지 추가
      _messages.insert(
        0,
        _ChatMessage(isUser: true, text: text),
      );
      _inputController.clear();
      _isSending = true;
    });

    try {
      // 기존 대화 기록을 ChatTurn 리스트로 변환
      // (가장 오래된 메시지가 먼저 오도록 뒤집어서 보냄)
      final history = _messages.reversed.map((m) {
        return ChatTurn(
          role: m.isUser ? 'user' : 'assistant',
          content: m.text,
        );
      }).toList();

      // 백엔드 /chat 호출
      final reply = await ChatApiService.sendChat(
        summary: _newsSummary!, // 뉴스 요약 객체
        questionLevel: _questionLevel,
        history: history,
      );

      if (!mounted) return;

      setState(() {
        _messages.insert(
          0,
          _ChatMessage(isUser: false, text: reply),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('대화 중 오류가 발생했습니다: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget topArea;

    if (_isLoadingSummary) {
      topArea = Container(
        width: double.infinity,
        color: Colors.grey.shade200,
        padding: const EdgeInsets.all(12),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('오늘의 뉴스를 불러오는 중...'),
          ],
        ),
      );
    } else if (_summaryError != null) {
      topArea = Container(
        width: double.infinity,
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(12),
        child: Text(
          _summaryError!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (_newsSummaryText != null) {
      topArea = Container(
        width: double.infinity,
        color: Colors.grey.shade200,
        padding: const EdgeInsets.all(12),
        child: Text(
          _newsSummaryText!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // 이론상 거의 안 오는 상태지만, 안전하게 기본 텍스트
      topArea = Container(
        width: double.infinity,
        color: Colors.grey.shade200,
        padding: const EdgeInsets.all(12),
        child: const Text(
          '오늘의 뉴스 요약을 불러오지 못했어요.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('깨톡 알람 대화'),
      ),
      body: Column(
        children: [
          // 상단 뉴스 요약 영역
          topArea,
          const Divider(height: 1),

          // 채팅 영역
          Expanded(
            child: ListView.builder(
              reverse: true, // index 0이 가장 아래에 가도록
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final alignment =
                    msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
                final bubbleColor =
                    msg.isUser ? Colors.blue.shade100 : Colors.grey.shade300;

                return Align(
                  alignment: alignment,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(msg.text),
                    ),
                  ),
                );
              },
            ),
          ),

          // 입력 / STT 버튼 영역
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: 나중에 STT 연동
                    },
                    icon: const Icon(Icons.mic),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendUserMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _isSending ? null : _sendUserMessage,
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('전송'),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      // 나중에 "이제 그만할래" 등 종료 멘트 처리 → 일단은 단순 종료
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
