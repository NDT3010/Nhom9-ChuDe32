/// Unit-test TV2: Đổi ngôn ngữ giữa bài không làm mất câu đang làm.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/practice_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('TV2 06: Language Switch Test', () {
    test('Đổi ngôn ngữ giữa bài không làm mất tiến trình và câu đang làm', () async {
      final questions = [
        fakeQuestion(
          number: 1,
          viQuestion: 'Câu 1 tiếng Việt?',
          enQuestion: 'Question 1 English?',
          answer: 'A',
        ),
        fakeQuestion(
          number: 2,
          viQuestion: 'Câu 2 tiếng Việt?',
          enQuestion: 'Question 2 English?',
          answer: 'B',
        ),
        fakeQuestion(
          number: 3,
          viQuestion: 'Câu 3 tiếng Việt?',
          enQuestion: 'Question 3 English?',
          answer: 'C',
        ),
      ];

      final qRepo = FakeQuestionRepository(questions);
      final practiceProvider = PracticeProvider(questionRepository: qRepo);
      final langProvider = LanguageProvider(initial: AppLang.vi);

      // Bắt đầu làm bài
      await practiceProvider.loadQuestions(count: 3);

      // Trả lời câu thứ 1
      final q1 = practiceProvider.currentQuestion!;
      practiceProvider.selectAnswer(q1.number, q1.answer);
      practiceProvider.nextQuestion(); // sang câu thứ 2

      // Trả lời câu thứ 2
      final q2 = practiceProvider.currentQuestion!;
      practiceProvider.selectAnswer(q2.number, q2.answer);
      practiceProvider.nextQuestion(); // sang câu thứ 3

      final q3 = practiceProvider.currentQuestion!;
      expect(practiceProvider.currentIndex, 2);
      expect(practiceProvider.currentQuestion?.number, q3.number);
      expect(practiceProvider.userAnswers.length, 2);

      // Chuyển ngôn ngữ sang tiếng Anh (en)
      await langProvider.setLanguage(AppLang.en);
      expect(langProvider.language, AppLang.en);

      // Kiểm tra tiến trình của PracticeProvider hoàn toàn không bị ảnh hưởng
      expect(practiceProvider.currentIndex, 2);
      expect(practiceProvider.currentQuestion?.number, q3.number);
      expect(practiceProvider.userAnswers[q1.number], q1.answer);
      expect(practiceProvider.userAnswers[q2.number], q2.answer);
      expect(practiceProvider.questions.length, 3);

      // Kiểm tra nội dung câu hỏi hiển thị đúng ngôn ngữ mới mà không làm mất trạng thái
      final currentQ = practiceProvider.currentQuestion!;
      expect(currentQ.prompt(langProvider.language.code), currentQ.enQuestion);

      // Chuyển sang chế độ song ngữ (both)
      await langProvider.setLanguage(AppLang.both);
      expect(langProvider.language, AppLang.both);

      // Tiến trình vẫn được bảo toàn nguyên vẹn
      expect(practiceProvider.currentIndex, 2);
      expect(practiceProvider.currentQuestion?.number, q3.number);
      expect(practiceProvider.userAnswers[q1.number], q1.answer);
      expect(practiceProvider.userAnswers[q2.number], q2.answer);

      practiceProvider.dispose();
      langProvider.dispose();
    });
  });
}
