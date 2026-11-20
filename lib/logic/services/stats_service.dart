/// Service tính thống kê từ lịch sử làm bài (tầng Logic, thuần Dart).
library;

import 'package:bilingual_quiz_app/data/models/quiz_result.dart';

/// Bản tóm tắt hiển thị ở StatsScreen.
class StatsSummary {
  const StatsSummary({
    required this.attempts,
    required this.bestScore10,
    required this.avgScore10,
    required this.totalCorrect,
    required this.totalQuestions,
  });

  /// Số lượt đã làm.
  final int attempts;

  /// Điểm cao nhất thang 10.
  final double bestScore10;

  /// Điểm trung bình thang 10.
  final double avgScore10;
  final int totalCorrect;
  final int totalQuestions;

  /// Tỉ lệ đúng toàn thời gian (0..1).
  double get accuracy => totalQuestions == 0 ? 0 : totalCorrect / totalQuestions;
}

/// Tính toán thống kê — TODO(tv2): thêm thống kê theo block/level (stats_v2).
class StatsService {
  const StatsService();

  StatsSummary summarize(List<QuizResult> history) {
    if (history.isEmpty) {
      return const StatsSummary(
        attempts: 0,
        bestScore10: 0,
        avgScore10: 0,
        totalCorrect: 0,
        totalQuestions: 0,
      );
    }
    var best = 0.0;
    var sum = 0.0;
    var c = 0;
    var t = 0;
    for (final r in history) {
      final s = r.score10;
      if (s > best) best = s;
      sum += s;
      c += r.correct;
      t += r.total;
    }
    return StatsSummary(
      attempts: history.length,
      bestScore10: best,
      avgScore10: sum / history.length,
      totalCorrect: c,
      totalQuestions: t,
    );
  }
}

// TODO(tv2): thống kê chi tiết theo từng block/level + biểu đồ tiến bộ.
