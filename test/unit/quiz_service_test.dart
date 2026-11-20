/// Unit-test khung TV1: model Question + QuizService.grade + StatsService.
library;

import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/logic/services/quiz_service.dart';
import 'package:bilingual_quiz_app/logic/services/stats_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

Question q({required int number, required String answer}) =>
    fakeQuestion(number: number, answer: answer);

void main() {
  test('Question.isCorrect so sánh không phân biệt hoa/thường', () {
    final question = q(number: 1, answer: 'C');
    expect(question.isCorrect('c'), isTrue);
    expect(question.isCorrect(' C '), isTrue);
    expect(question.isCorrect('A'), isFalse);
  });

  test('QuizService.grade chấm đúng số câu đúng/sai', () {
    final quiz = [q(number: 1, answer: 'A'), q(number: 2, answer: 'B')];
    final service = QuizService(FakeQuestionRepository(quiz));
    final result = service.grade(quiz, {1: 'A', 2: 'C'}, mode: 'practice');
    expect(result.correct, 1);
    expect(result.total, 2);
    expect(result.wrongNumbers, [2]);
    expect(result.score10, 5.0);
  });

  test('StatsService.summarize tính đúng attempts/best/avg', () {
    const history = [
      QuizResult(
        id: '1',
        dateIso: '2026-11-21',
        mode: 'practice',
        total: 10,
        correct: 8,
        questionNumbers: [],
        wrongNumbers: [],
      ),
      QuizResult(
        id: '2',
        dateIso: '2026-11-21',
        mode: 'exam',
        total: 10,
        correct: 6,
        questionNumbers: [],
        wrongNumbers: [],
      ),
    ];
    final summary = const StatsService().summarize(history);
    expect(summary.attempts, 2);
    expect(summary.bestScore10, 8.0);
    expect(summary.avgScore10, 7.0);
    expect(summary.accuracy, closeTo(0.7, 0.001));
  });
}
