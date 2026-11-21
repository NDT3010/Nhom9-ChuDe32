/// Màn hình chính: menu 5 chế độ + tiêu đề song ngữ lấy từ [AppStrings].
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/screens/exam_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/practice_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/settings_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/stats_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/wrong_retry_screen.dart';
import 'package:flutter/material.dart';

/// Trang chủ chạy được thật ở TV1: bấm các nút sẽ sang màn hình tương ứng.
///
/// Mọi chuỗi hiển thị đều đọc từ [AppStringsScope] — không hardcode chuỗi.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.appTitle, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(s.homeSubtitle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _MenuButton(
            icon: Icons.sports_esports,
            label: s.practice,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PracticeScreen()),
            ),
          ),
          _MenuButton(
            icon: Icons.timer,
            label: s.exam,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExamScreen()),
            ),
          ),
          _MenuButton(
            icon: Icons.replay,
            label: s.wrongRetry,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WrongRetryScreen()),
            ),
          ),
          _MenuButton(
            icon: Icons.bar_chart,
            label: s.stats,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
          _MenuButton(
            icon: Icons.settings,
            label: s.settings,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút menu to, cao tối thiểu 48dp theo yêu cầu đề bài.
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}
