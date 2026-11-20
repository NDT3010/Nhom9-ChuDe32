/// Màn hình Cài đặt — khung TV1 (làm thật ở TV2).
library;

import 'package:flutter/material.dart';

// TODO(tv2): chuyển ngôn ngữ Việt/Anh + lưu bằng SettingsRepository (settings_v2).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: const Center(child: Text('TODO(tv2): màn cài đặt sẽ làm ở TV2.')),
    );
  }
}
