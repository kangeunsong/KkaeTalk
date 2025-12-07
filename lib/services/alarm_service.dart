import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/alarm.dart';

class AlarmService {
  AlarmService._internal();
  static final AlarmService instance = AlarmService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 로그인된 유저의 알람 컬렉션 레퍼런스
  CollectionReference<Map<String, dynamic>> _userAlarmsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('alarms');
  }

  /// 알람 생성
  Future<void> createAlarm({
    required String time,
    required List<int> repeatDays,
    String sound = 'default',
    String topicMode = 'random_interest',
    String? fixedTopic,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('로그인된 유저가 없습니다.');
    }

    final ref = _userAlarmsRef(user.uid).doc();

    final alarm = Alarm(
      id: ref.id,
      time: time,
      repeatDays: repeatDays,
      isActive: true,
      sound: sound,
      topicMode: topicMode,
      fixedTopic: fixedTopic,
      createdAt: Timestamp.now(),
    );

    await ref.set(alarm.toMap());
  }

  /// 알람 목록 스트림 (홈 화면에서 사용)
  Stream<List<Alarm>> alarmsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 로그아웃 상태일 때는 빈 스트림
      return const Stream<List<Alarm>>.empty();
    }

    return _userAlarmsRef(user.uid)
        .orderBy('time')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Alarm.fromDoc).toList());
  }

  /// 알람 삭제
  Future<void> deleteAlarm(String alarmId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('로그인된 유저가 없습니다.');
    }

    await _userAlarmsRef(user.uid).doc(alarmId).delete();
  }

  /// 알람 on/off 토글
  Future<void> toggleAlarmActive(String alarmId, bool isActive) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('로그인된 유저가 없습니다.');
    }

    await _userAlarmsRef(user.uid).doc(alarmId).update({'is_active': isActive});
  }

  /// 알람 수정
  Future<void> updateAlarm({
    required String alarmId,
    required String time,
    required List<int> repeatDays,
    String topicMode = 'random_interest',
    String? fixedTopic,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('로그인된 유저가 없습니다.');
    }

    await _userAlarmsRef(user.uid).doc(alarmId).update({
      'time': time,
      'repeat_days': repeatDays,
      'topic_mode': topicMode,
      'fixed_topic': topicMode == 'fixed' ? fixedTopic : null,
    });
  }
}
