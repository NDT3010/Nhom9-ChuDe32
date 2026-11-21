/// Unit-test TV2: Thêm / xóa câu sai qua FakeWrongRepository.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/logic/providers/practice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('TV2 05: Wrong List Test', () {
    late FakeWrongRepository wrongRepo;

    setUp(() {
      wrongRepo = FakeWrongRepository();
    });

    test('addWrongQuestion thêm câu sai và không bị trùng lặp', () async {
      await wrongRepo.addWrongQuestion(101);
      final list1 = (await wrongRepo.getWrongQuestionNumbers()).valueOrNull!;
      expect(list1, [101]);

      // Thêm lại cùng câu số 101 -> không bị lặp
      await wrongRepo.addWrongQuestion(101);
      final list2 = (await wrongRepo.getWrongQuestionNumbers()).valueOrNull!;
      expect(list2, [101]);

      // Thêm câu khác
      await wrongRepo.addWrongQuestion(102);
      final list3 = (await wrongRepo.getWrongQuestionNumbers()).valueOrNull!;
      expect(list3, [101, 102]);
    });

    test('removeWrongQuestion xóa đúng câu khỏi danh sách', () async {
      await wrongRepo.addWrongQuestion(10);
      await wrongRepo.addWrongQuestion(20);
      await wrongRepo.addWrongQuestion(30);

      await wrongRepo.removeWrongQuestion(20);
      final list = (await wrongRepo.getWrongQuestionNumbers()).valueOrNull!;
      expect(list, [10, 30]);

      // Xóa câu không tồn tại -> không lỗi
      await wrongRepo.removeWrongQuestion(999);
      final list2 = (await wrongRepo.getWrongQuestionNumbers()).valueOrNull!;
      expect(list2, [10, 30]);
    });

    test('clear xóa toàn bộ danh sách câu sai', () async {
      await wrongRepo.addWrongQuestion(1);
      await wrongRepo.addWrongQuestion(2);
      expect((await wrongRepo.getWrongQuestionNumbers()).valueOrNull!.length, 2);

      await wrongRepo.clear();
      expect((await wrongRepo.getWrongQuestionNumbers()).valueOrNull!, isEmpty);
    });

    test('PracticeProvider tự động thêm câu sai khi trả lời sai và xóa khi trả lời đúng', () async {
      final questions = [
        fakeQuestion(number: 1, answer: 'A'),
        fakeQuestion(number: 2, answer: 'B'),
      ];
      final qRepo = FakeQuestionRepository(questions);
      final pProvider = PracticeProvider(
        questionRepository: qRepo,
        wrongRepository: wrongRepo,
      );

      await pProvider.loadQuestions(count: 2);

      // Trả lời sai câu 1 (chọn 'C' thay vì 'A')
      pProvider.selectAnswer(1, 'C');
      expect(wrongRepo.wrongNumbers, contains(1));

      // Trả lời đúng câu 2 (chọn 'B')
      pProvider.selectAnswer(2, 'B');
      expect(wrongRepo.wrongNumbers, isNot(contains(2)));

      // Trả lời lại câu 1 đúng (chọn 'A') -> phải được xóa khỏi danh sách sai
      pProvider.selectAnswer(1, 'A');
      expect(wrongRepo.wrongNumbers, isNot(contains(1)));

      pProvider.dispose();
    });
  });
}
