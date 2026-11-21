/// Unit-test TV2: Trộn câu không trùng, giữ nguyên số câu yêu cầu.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/logic/services/quiz_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('TV2 01: Shuffle Test', () {
    test('buildQuiz trả về đúng số lượng câu hỏi yêu cầu', () async {
      final seed = List.generate(30, (i) => fakeQuestion(number: i + 1));
      final repo = FakeQuestionRepository(seed);
      final service = QuizService(repo);

      final res10 = await service.buildQuiz(count: 10);
      expect(res10.isOk, isTrue);
      expect(res10.valueOrNull?.length, 10);

      final res20 = await service.buildQuiz(count: 20);
      expect(res20.isOk, isTrue);
      expect(res20.valueOrNull?.length, 20);

      final res5 = await service.buildQuiz(count: 5);
      expect(res5.isOk, isTrue);
      expect(res5.valueOrNull?.length, 5);
    });

    test('buildQuiz không chứa câu hỏi trùng lặp', () async {
      final seed = List.generate(40, (i) => fakeQuestion(number: i + 1));
      final repo = FakeQuestionRepository(seed);
      final service = QuizService(repo);

      final res = await service.buildQuiz(count: 25);
      expect(res.isOk, isTrue);

      final questions = res.valueOrNull!;
      final numbers = questions.map((q) => q.number).toList();
      final uniqueNumbers = numbers.toSet();

      // Số câu hỏi duy nhất phải bằng đúng độ dài danh sách
      expect(uniqueNumbers.length, numbers.length);
      expect(uniqueNumbers.length, 25);
    });

    test('buildQuiz với count lớn hơn số câu hiện có thì trả về tối đa số câu trong kho', () async {
      final seed = List.generate(8, (i) => fakeQuestion(number: i + 1));
      final repo = FakeQuestionRepository(seed);
      final service = QuizService(repo);

      final res = await service.buildQuiz(count: 15);
      expect(res.isOk, isTrue);
      expect(res.valueOrNull?.length, 8);

      final uniqueNumbers = res.valueOrNull!.map((q) => q.number).toSet();
      expect(uniqueNumbers.length, 8);
    });
  });
}
