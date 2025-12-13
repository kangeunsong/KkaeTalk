import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../models/alarm.dart';
import 'alarm_edit_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'alarm_chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  String _repeatDaysText(List<int> days) {
    if (days.isEmpty) return '한 번만 울림';

    const labels = {
      1: '월',
      2: '화',
      3: '수',
      4: '목',
      5: '금',
      6: '토',
      7: '일',
    };

    final sorted = [...days]..sort();
    return sorted.map((d) => labels[d] ?? '').join(' ');
  }

  String _topicSummary(Alarm alarm) {
    switch (alarm.topicMode) {
      case 'random_interest':
        return '관심 카테고리 중 랜덤';
      case 'random_all':
        return '전체 카테고리 중 랜덤';
      case 'fixed':
        return '고정: ${alarm.fixedTopic ?? '미설정'}';
      default:
        return alarm.topicMode;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: '알람 대화 테스트',
            onPressed: () {
              Navigator.pushNamed(context, AlarmChatScreen.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Alarm>>(
        stream: AlarmService.instance.alarmsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('알람을 불러오는 중 오류가 발생했습니다.\n${snapshot.error}'),
            );
          }

          final alarms = snapshot.data ?? [];

          if (alarms.isEmpty) {
            return const Center(
              child: Text(
                '등록된 알람이 없습니다.\n오른쪽 아래 + 버튼으로 알람을 추가해 보세요.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alarms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return ListTile(
                onTap: () {
                  showAlarmEditDialog(context, alarm: alarm);
                },
                leading: const Icon(Icons.alarm),
                title: Text(
                  alarm.time,
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_repeatDaysText(alarm.repeatDays)),
                    Text(
                      _topicSummary(alarm),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: alarm.isActive,
                      onChanged: (value) {
                        AlarmService.instance
                            .toggleAlarmActive(alarm.id, value);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('알람 삭제'),
                            content: const Text('이 알람을 삭제할까요?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await AlarmService.instance.deleteAlarm(alarm.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showAlarmEditDialog(context); // ✅ 팝업으로 알람 생성
        },
        icon: const Icon(Icons.add_alarm),
        label: const Text('알람 추가'),
      ),
    );
  }
}
