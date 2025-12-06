import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _autoLogin; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadAutoLoginPreference();
  }

  Future<void> _loadAutoLoginPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoLogin = prefs.getBool('autoLogin') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // autoLogin 설정 로딩 중이면 로딩 화면
    if (_autoLogin == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase가 사용자 상태 파악 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // 🔹 로그인된 유저가 있고, 자동 로그인 ON → 홈으로
        if (user != null && _autoLogin == true) {
          return const HomeScreen();
        }

        // 🔹 로그인된 유저가 있는데, 자동 로그인 OFF → 강제 로그아웃 후 로그인 화면
        if (user != null && _autoLogin == false) {
          // build 안에서 바로 signOut 호출하면 경고 뜰 수 있어서 microtask로 처리
          Future.microtask(() => FirebaseAuth.instance.signOut());
          return const LoginScreen();
        }

        // 🔹 로그인 안 되어 있음 → 로그인 화면
        return const LoginScreen();
      },
    );
  }
}
