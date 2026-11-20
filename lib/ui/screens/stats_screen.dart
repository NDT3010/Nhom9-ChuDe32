/// Màn hình Thống kê — khung TV1 (làm thật ở TV2).
library;

import 'package:flutter/material.dart';

// TODO(tv2): đọc lịch sử + vẽ biểu đồ bằng StatsService (stats_v2).
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: const Center(child: Text('TODO(tv2): màn thống kê sẽ làm ở TV2.')),
    );
  }
}
