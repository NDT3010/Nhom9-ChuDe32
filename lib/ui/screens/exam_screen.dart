/// Màn hình Thi thử — khung TV1 (làm thật ở TV2).
library;

import 'package:flutter/material.dart';

// TODO(tv2): làm màn thi thử thật (exam_v2): bấm giờ, nộp bài, lưu lịch sử.
class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thi thử')),
      body: const Center(child: Text('TODO(tv2): màn thi thử sẽ làm ở TV2.')),
    );
  }
}
