// [예시] 회원가입 UI

import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: const Center(child: SizedBox.shrink()),
      // 예시
      // body: Padding(
      //   padding: EdgeInsets.all(24),
      //   child: Column(
      //     children: [
      //       TextField(decoration: InputDecoration(labelText: '이메일')),
      //       TextField(decoration: InputDecoration(labelText: '비밀번호')),
      //     ],
      //   ),
      // ),
    );
  }
}
