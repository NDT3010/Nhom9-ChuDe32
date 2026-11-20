/// Service trộn đề + chấm điểm (tầng Logic, thuần Dart, dễ unit-test).
library;

import 'dart:math';

import 'package:bilingual_quiz_app/core/app_error.dart';
import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';

/// Sinh đề, chấm điểm và tạo [QuizResult]. Không phụ thuộc Flutter/Provider.
class QuizService {
  QuizService(this.questions, {Random? random}) : _random = random ?? Random();

  final QuestionRepository questions;
  final Random _random;

  /// Lấy [count] câu ngẫu nhiên, lọc theo [block]/[level] nếu có.
  Future<Result<List<Question>>> buildQuiz({int count = 15, int? block, String? level}) async {
    if (count <= 0) {
      return Result.err(const AppError('Số câu phải lớn hơn 0.', code: AppErrorCode.invalidArg));
    }
    final all = await questions.getAll();
    return all.when(
      ok: (items) {
        var pool = items;
        if (block != null) pool = pool.where((q) => q.block == block).toList();
        if (level != null && level.isNotEmpty) {
          pool = pool.where((q) => q.level == level).toList();
        }
        if (pool.isEmpty) {
          return Result.err(const AppError('Không có câu hỏi phù hợp.', code: AppErrorCode.invalidArg));
        }
        final shuffled = [...pool]..shuffle(_random);
        return Result.ok(shuffled.take(count.clamp(1, shuffled.length)).toList());
      },
      err: (e) => Result.err(e),
    );
  }

  /// Chấm [answers] (map number -> choice) trên [quiz], tạo QuizResult chế độ [mode].
  QuizResult grade(List<Question> quiz, Map<int, String> answers, {String mode = 'practice'}) {
    var correct = 0;
    final wrong = <int>[];
    for (final q in quiz) {
      final choice = answers[q.number] ?? '';
      if (q.isCorrect(choice)) {
        correct++;
      } else {
        wrong.add(q.number);
      }
    }
    return QuizResult(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      dateIso: DateTime.now().toIso8601String(),
      mode: mode,
      total: quiz.length,
      correct: correct,
      questionNumbers: quiz.map((q) => q.number).toList(),
      wrongNumbers: wrong,
    );
  }
}
