/// Model kết quả một lượt làm bài, lưu vào lịch sử (SharedPreferences).
library;

/// Một lần nộp bài của người dùng.
class QuizResult {
  const QuizResult({
    required this.id,
    required this.dateIso,
    required this.mode,
    required this.total,
    required this.correct,
    required this.questionNumbers,
    required this.wrongNumbers,
    this.durationSeconds = 0,
  });

  /// id duy nhất (microsecondsSinceEpoch).
  final String id;

  /// Thời điểm nộp bài (ISO 8601).
  final String dateIso;

  /// Chế độ: practice | exam | retry.
  final String mode;
  final int total;
  final int correct;

  /// Danh sách số câu đã làm / làm sai (để làm lại câu sai ở TV2).
  final List<int> questionNumbers;
  final List<int> wrongNumbers;
  final int durationSeconds;

  /// Điểm thang 10.
  double get score10 => total == 0 ? 0 : correct * 10 / total;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    List<int> asInts(dynamic v) {
      if (v is List) {
        return v.map((e) => int.tryParse(e.toString()) ?? 0).toList();
      }
      return const [];
    }

    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return QuizResult(
      id: json['id']?.toString() ?? '',
      dateIso: json['dateIso']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'practice',
      total: asInt(json['total']),
      correct: asInt(json['correct']),
      questionNumbers: asInts(json['questionNumbers']),
      wrongNumbers: asInts(json['wrongNumbers']),
      durationSeconds: asInt(json['durationSeconds']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'mode': mode,
        'total': total,
        'correct': correct,
        'questionNumbers': questionNumbers,
        'wrongNumbers': wrongNumbers,
        'durationSeconds': durationSeconds,
      };
}
