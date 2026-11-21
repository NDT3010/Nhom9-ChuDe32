/// Unit-test TV2: Lọc câu theo khối.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/logic/providers/practice_provider.dart';
import 'package:bilingual_quiz_app/logic/services/quiz_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('TV2 03: Filter Block Test', () {
    late FakeQuestionRepository repo;

    setUp(() {
      final seed = [
        // Khối 1: 3 câu
        fakeQuestion(number: 1, block: 1),
        fakeQuestion(number: 2, block: 1),
        fakeQuestion(number: 3, block: 1),
        // Khối 2: 4 câu
        fakeQuestion(number: 4, block: 2),
        fakeQuestion(number: 5, block: 2),
        fakeQuestion(number: 6, block: 2),
        fakeQuestion(number: 7, block: 2),
        // Khối 3: 2 câu
        fakeQuestion(number: 8, block: 3),
        fakeQuestion(number: 9, block: 3),
      ];
      repo = FakeQuestionRepository(seed);
    });

    test('FakeQuestionRepository.getByBlock lọc đúng khối yêu cầu', () async {
      final block2Res = await repo.getByBlock(2);
      expect(block2Res.isOk, isTrue);
      final block2 = block2Res.valueOrNull!;
      expect(block2.length, 4);
      expect(block2.every((q) => q.block == 2), isTrue);

      final block3Res = await repo.getByBlock(3);
      expect(block3Res.isOk, isTrue);
      expect(block3Res.valueOrNull!.length, 2);
      expect(block3Res.valueOrNull!.every((q) => q.block == 3), isTrue);
    });

    test('QuizService.buildQuiz lọc chính xác theo khối', () async {
      final service = QuizService(repo);

      final res = await service.buildQuiz(block: 2, count: 10);
      expect(res.isOk, isTrue);
      final questions = res.valueOrNull!;
      expect(questions.length, 4);
      expect(questions.every((q) => q.block == 2), isTrue);
    });

    test('PracticeProvider nạp câu hỏi đúng khối đã chọn', () async {
      final provider = PracticeProvider(questionRepository: repo);
      await provider.loadQuestions(block: 1, count: 10);

      expect(provider.questions.length, 3);
      expect(provider.questions.every((q) => q.block == 1), isTrue);
      provider.dispose();
    });

    test('Lọc với block == null trả về câu hỏi từ mọi khối', () async {
      final allRes = await repo.getByBlock(null);
      expect(allRes.isOk, isTrue);
      expect(allRes.valueOrNull!.length, 9);
    });
  });
}
