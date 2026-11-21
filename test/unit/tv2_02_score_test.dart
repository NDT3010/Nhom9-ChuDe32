/// Unit-test TV2: Chấm điểm đúng, tính % đúng.
library;

import 'package:bilingual_quiz_app/logic/services/quiz_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('TV2 02: Score Test', () {
    late QuizService service;

    setUp(() {
      service = QuizService(FakeQuestionRepository());
    });

    test('Chấm 10 câu: đúng 8, sai 2 -> điểm 8.0, 80% đúng', () {
      final questions = List.generate(
        10,
        (i) => fakeQuestion(number: i + 1, answer: 'A'),
      );
      final answers = {
        1: 'A',
        2: 'A',
        3: 'A',
        4: 'A',
        5: 'A',
        6: 'A',
        7: 'A',
        8: 'A',
        9: 'B', // sai
        10: 'C', // sai
      };

      final result = service.grade(questions, answers);

      expect(result.total, 10);
      expect(result.correct, 8);
      expect(result.wrongNumbers, [9, 10]);
      expect(result.score10, closeTo(8.0, 0.001));

      final percent = result.total == 0 ? 0.0 : (result.correct / result.total) * 100;
      expect(percent, 80.0);
    });

    test('Chấm 20 câu: đúng 15, sai 5 -> điểm 7.5, 75% đúng', () {
      final questions = List.generate(
        20,
        (i) => fakeQuestion(number: i + 1, answer: 'B'),
      );
      final answers = <int, String>{};
      for (int i = 1; i <= 15; i++) {
        answers[i] = 'B'; // đúng
      }
      for (int i = 16; i <= 20; i++) {
        answers[i] = 'D'; // sai
      }

      final result = service.grade(questions, answers, mode: 'exam');

      expect(result.total, 20);
      expect(result.correct, 15);
      expect(result.wrongNumbers.length, 5);
      expect(result.score10, closeTo(7.5, 0.001));

      final percent = (result.correct / result.total) * 100;
      expect(percent, 75.0);
    });

    test('Đúng 100% -> điểm 10.0 và sai 100% -> điểm 0.0', () {
      final questions = [
        fakeQuestion(number: 1, answer: 'A'),
        fakeQuestion(number: 2, answer: 'B'),
      ];

      // Trường hợp 100%
      final allCorrect = service.grade(questions, {1: 'A', 2: 'B'});
      expect(allCorrect.correct, 2);
      expect(allCorrect.score10, 10.0);
      expect(allCorrect.wrongNumbers, isEmpty);

      // Trường hợp 0%
      final allWrong = service.grade(questions, {1: 'C', 2: 'D'});
      expect(allWrong.correct, 0);
      expect(allWrong.score10, 0.0);
      expect(allWrong.wrongNumbers, [1, 2]);
    });

    test('So sánh đáp án không phân biệt chữ hoa chữ thường', () {
      final questions = [fakeQuestion(number: 1, answer: 'C')];
      final res = service.grade(questions, {1: 'c'}); // 'c' thường
      expect(res.correct, 1);
      expect(res.score10, 10.0);
    });
  });
}
