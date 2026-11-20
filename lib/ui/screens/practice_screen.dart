/// Màn hình Luyện tập — khung TV1 (làm thật ở TV2).
library;

import 'package:flutter/material.dart';

// TODO(tv2): làm màn luyện tập thật (practice_v2): chọn block/level, trả lời từng câu, chấm ngay.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập')),
      body: const Center(child: Text('TODO(tv2): màn luyện tập sẽ làm ở TV2.')),
    );
  }
}
