import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _interestPolitics = false;
  bool _interestEconomy = false;
  bool _interestSociety = false;
  bool _interestLifeCulture = false;
  bool _interestItScience = false;
  bool _interestWorld = false;
  int _questionLevel = 2;
  bool _isSaving = false;

  String get _questionLevelTitle {
    switch (_questionLevel) {
      case 1:
        return '레벨 1 · 조용한 모드';
      case 2:
        return '레벨 2 · 기본 대화 모드';
      case 3:
        return '레벨 3 · 깊은 대화 모드';
      default:
        return '';
    }
  }

  String get _questionLevelDescription {
    switch (_questionLevel) {
      case 1:
        return 'AI가 먼저 질문하지 않아요.\n내가 주도적으로 이야기하고 싶을 때 추천해요.';
      case 2:
        return 'AI가 가끔 가벼운 질문을 해요.\n자연스럽게 대화를 이어가고 싶다면 추천해요.';
      case 3:
        return 'AI가 적극적으로 깊은 질문을 해요.\n생각을 정리하고 싶은 아침에 추천해요.';
      default:
        return '';
    }
  }

  Future<void> _saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다. 다시 시도해 주세요.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await UserService.instance.updateOnboardingSettings(
        uid: user.uid,
        interestPolitics: _interestPolitics,
        interestEconomy: _interestEconomy,
        interestSociety: _interestSociety,
        interestLifeCulture: _interestLifeCulture,
        interestItScience: _interestItScience,
        interestWorld: _interestWorld,
        questionLevel: _questionLevel,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정이 저장되었습니다.')),
      );

      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 저장 중 오류가 발생했습니다. 다시 시도해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관심 설정 / 질문 레벨'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 관심 카테고리 영역 (임시)
            const Text(
              '관심 카테고리',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '아침에 함께 이야기하고 싶은 뉴스 주제를 선택해 주세요.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('정치'),
                  selected: _interestPolitics,
                  onSelected: (selected) {
                    setState(() {
                      _interestPolitics = selected;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('경제'),
                  selected: _interestEconomy,
                  onSelected: (selected) {
                    setState(() {
                      _interestEconomy = selected;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('사회'),
                  selected: _interestSociety,
                  onSelected: (selected) {
                    setState(() {
                      _interestSociety = selected;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('생활·문화'),
                  selected: _interestLifeCulture,
                  onSelected: (selected) {
                    setState(() {
                      _interestLifeCulture = selected;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('IT·과학'),
                  selected: _interestItScience,
                  onSelected: (selected) {
                    setState(() {
                      _interestItScience = selected;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('세계'),
                  selected: _interestWorld,
                  onSelected: (selected) {
                    setState(() {
                      _interestWorld = selected;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 질문 레벨 영역
            const Text(
              '질문 레벨',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _questionLevelTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Text('1'),
                Expanded(
                  child: Slider(
                    value: _questionLevel.toDouble(),
                    min: 1,
                    max: 3,
                    divisions: 2,
                    label: '$_questionLevel',
                    onChanged: (value) {
                      setState(() {
                        _questionLevel = value.round();
                      });
                    },
                  ),
                ),
                const Text('3'),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              _questionLevelDescription,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('설정 완료하고 홈으로 이동'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
