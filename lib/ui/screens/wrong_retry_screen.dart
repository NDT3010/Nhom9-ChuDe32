/// Màn hình Làm lại câu sai — khung TV1 (làm thật ở TV2).
library;

import 'package:flutter/material.dart';

// TODO(tv2): lấy wrongNumbers từ lịch sử gần nhất để luyện lại (retry_v2).
class WrongRetryScreen extends StatelessWidget {
  const WrongRetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Làm lại câu sai')),
      body: const Center(child: Text('TODO(tv2): màn làm lại câu sai sẽ làm ở TV2.')),
    );
  }
}
