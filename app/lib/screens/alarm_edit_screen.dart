import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../models/alarm.dart';

/// 홈 화면에서 호출할 함수
Future<void> showAlarmEditDialog(
  BuildContext context, {
  Alarm? alarm, // null이면 생성, 있으면 수정
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlarmEditDialog(alarm: alarm),
  );
}

class AlarmEditDialog extends StatefulWidget {
  const AlarmEditDialog({super.key, this.alarm});

  final Alarm? alarm; // null => 새 알람, not null => 수정 모드

  @override
  State<AlarmEditDialog> createState() => _AlarmEditDialogState();
}

class _AlarmEditDialogState extends State<AlarmEditDialog> {
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;
  late String _topicMode;
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

  bool get _isEditMode => widget.alarm != null;

  @override
  void initState() {
    super.initState();

    // 🔹 수정 모드면 기존 값으로 초기화, 아니면 기본값
    if (widget.alarm != null) {
      final alarm = widget.alarm!;
      _selectedTime = _parseTimeOfDay(alarm.time);
      _selectedDays = List<int>.from(alarm.repeatDays);
      _topicMode = alarm.topicMode;
      _fixedTopic = alarm.fixedTopic;
    } else {
      _selectedTime = const TimeOfDay(hour: 7, minute: 0);
      _selectedDays = [];
      _topicMode = 'random_interest';
      _fixedTopic = null;
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    // "HH:mm" → TimeOfDay
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

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

    final timeStr = _formatTime();

    try {
      if (_isEditMode) {
        // 🔹 수정 모드
        await AlarmService.instance.updateAlarm(
          alarmId: widget.alarm!.id,
          time: timeStr,
          repeatDays: _selectedDays,
          topicMode: _topicMode,
          fixedTopic: _fixedTopic,
        );
      } else {
        // 🔹 생성 모드
        await AlarmService.instance.createAlarm(
          time: timeStr,
          repeatDays: _selectedDays,
          topicMode: _topicMode,
          fixedTopic: _fixedTopic,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // 팝업 닫기
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
    final titleText = _isEditMode ? '알람 수정' : '알람 생성';
    final actionText = _isEditMode ? '수정' : '생성';

    return AlertDialog(
      title: Text(titleText),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 시간
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

            // 요일
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
              : Text(actionText), // 생성 / 수정
        ),
      ],
    );
  }
}
