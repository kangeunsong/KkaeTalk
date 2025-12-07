import 'package:flutter/material.dart';
import '../services/alarm_service.dart';

/// 홈 화면에서 호출할 함수
Future<void> showAlarmEditDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false, // 바깥 탭해서 닫히지 않게
    builder: (context) => const AlarmEditDialog(),
  );
}

class AlarmEditDialog extends StatefulWidget {
  const AlarmEditDialog({super.key});

  @override
  State<AlarmEditDialog> createState() => _AlarmEditDialogState();
}

class _AlarmEditDialogState extends State<AlarmEditDialog> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  final List<int> _selectedDays = []; // 1~7 (월~일)
  String _topicMode = 'random_interest'; // "관심 중 랜덤"
  String? _fixedTopic;
  bool _isSaving = false;

  final List<int> _dayValues = [1, 2, 3, 4, 5, 6, 7];
  final List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  final List<String> _topics = [
    '정치',
    '경제',
    '사회',
    '생활·문화',
    'IT·과학',
    '세계',
  ];

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime() {
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveAlarm() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('반복 요일을 최소 1개 이상 선택해 주세요.')),
      );
      return;
    }

    if (_topicMode == 'fixed' && _fixedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('고정 토론 주제를 선택해 주세요.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AlarmService.instance.createAlarm(
        time: _formatTime(),
        repeatDays: _selectedDays,
        topicMode: _topicMode,
        fixedTopic: _topicMode == 'fixed' ? _fixedTopic : null,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // ✅ 팝업 닫기
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알람 저장 중 오류가 발생했습니다.')),
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
    return AlertDialog(
      title: const Text('알람 생성'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 시간 선택
            const Text(
              '알람 시간',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatTime(),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _pickTime,
                  child: const Text('시간 선택'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 요일 선택
            const Text(
              '반복 요일',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: List.generate(_dayValues.length, (index) {
                final value = _dayValues[index];
                final label = _dayLabels[index];
                final isSelected = _selectedDays.contains(value);
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(value);
                      } else {
                        _selectedDays.remove(value);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),

            // 토론 주제
            const Text(
              '토론 주제',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('관심 카테고리 중 랜덤'),
              value: 'random_interest',
              groupValue: _topicMode,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _topicMode = value;
                });
              },
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('전체 카테고리 중 랜덤'),
              value: 'random_all',
              groupValue: _topicMode,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _topicMode = value;
                });
              },
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('특정 카테고리 고정'),
              value: 'fixed',
              groupValue: _topicMode,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _topicMode = value;
                });
              },
            ),
            if (_topicMode == 'fixed')
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: DropdownButton<String>(
                  hint: const Text('카테고리 선택'),
                  value: _fixedTopic,
                  items: _topics
                      .map(
                        (topic) => DropdownMenuItem(
                          value: topic,
                          child: Text(topic),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _fixedTopic = value;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveAlarm,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('생성'),
        ),
      ],
    );
  }
}
