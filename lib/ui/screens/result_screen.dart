/// Màn hình Kết quả — khung TV1 (làm thật ở TV2).
library;

import 'package:flutter/material.dart';

// TODO(tv2): hiển thị điểm + đáp án đúng/sai + giải thích (result_v2).
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả')),
      body: const Center(child: Text('TODO(tv2): màn kết quả sẽ làm ở TV2.')),
    );
  }
}
