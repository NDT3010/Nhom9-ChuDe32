/// Unit-test WrongRepository và logic tự động lưu câu sai trong PracticeProvider.
library;

import 'package:bilingual_quiz_app/logic/providers/practice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('WrongRepository & PracticeProvider auto-save', () {
    test('Câu trả lời sai tự lưu vào wrong repository; câu đúng xóa khỏi danh sách sai', () async {
      final qRepo = FakeQuestionRepository([
        fakeQuestion(number: 1, answer: 'A'),
        fakeQuestion(number: 2, answer: 'B'),
      ]);
      final wrongRepo = FakeWrongRepository();

      final provider = PracticeProvider(
        questionRepository: qRepo,
        wrongRepository: wrongRepo,
      );

      await provider.loadQuestions(count: 2);
      final q0 = provider.questions[0];
      final q1 = provider.questions[1];

      // 1. Trả lời sai q0
      final wrongChoice0 = q0.answer == 'A' ? 'B' : 'A';
      provider.selectAnswer(q0.number, wrongChoice0);

      expect(wrongRepo.wrongNumbers, contains(q0.number));
      expect(wrongRepo.wrongNumbers.length, 1);

      // 2. Trả lời sai q1
      final wrongChoice1 = q1.answer == 'A' ? 'B' : 'A';
      provider.selectAnswer(q1.number, wrongChoice1);

      expect(wrongRepo.wrongNumbers, containsAll([q0.number, q1.number]));
      expect(wrongRepo.wrongNumbers.length, 2);

      // 3. Trả lời đúng lại q0 -> Xóa khỏi danh sách sai
      provider.selectAnswer(q0.number, q0.answer);
      expect(wrongRepo.wrongNumbers, isNot(contains(q0.number)));
      expect(wrongRepo.wrongNumbers, contains(q1.number));
      expect(wrongRepo.wrongNumbers.length, 1);

      provider.dispose();
    });

    test('FakeWrongRepository clear() xóa toàn bộ danh sách câu sai', () async {
      final wrongRepo = FakeWrongRepository([10, 20, 30]);
      expect(wrongRepo.wrongNumbers.length, 3);

      await wrongRepo.clear();
      expect(wrongRepo.wrongNumbers, isEmpty);
    });
  });
}
