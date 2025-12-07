import 'package:cloud_firestore/cloud_firestore.dart';

class Alarm {
  final String id;
  final String time; // "HH:mm" 형태 (예: "07:30")
  final List<int> repeatDays; // 1~7 (월~일)
  final bool isActive;
  final String sound; // 일단 "default"
  final String topicMode; // "fixed" | "random_all" | "random_interest"
  final String? fixedTopic; // topicMode == "fixed" 일 때 사용
  final Timestamp createdAt;

  Alarm({
    required this.id,
    required this.time,
    required this.repeatDays,
    required this.isActive,
    required this.sound,
    required this.topicMode,
    this.fixedTopic,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'repeat_days': repeatDays,
      'is_active': isActive,
      'sound': sound,
      'topic_mode': topicMode,
      'fixed_topic': fixedTopic,
      'created_at': createdAt,
    };
  }

  factory Alarm.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Alarm(
      id: doc.id,
      time: data['time'] as String? ?? '07:00',
      repeatDays: List<int>.from(data['repeat_days'] ?? []),
      isActive: data['is_active'] as bool? ?? true,
      sound: data['sound'] as String? ?? 'default',
      topicMode: data['topic_mode'] as String? ?? 'random_interest',
      fixedTopic: data['fixed_topic'] as String?,
      createdAt: data['created_at'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
