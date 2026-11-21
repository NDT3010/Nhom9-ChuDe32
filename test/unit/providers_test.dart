/// Unit-test các Provider của TV2: PracticeProvider, ExamProvider, WrongProvider.
library;

import 'package:bilingual_quiz_app/core/app_error.dart';
import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/logic/providers/exam_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/practice_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/wrong_provider.dart';
import 'package:bilingual_quiz_app/logic/repositories/history_repository.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

/// Fake HistoryRepository dùng cho unit-test.
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository([List<QuizResult>? seed])
      : results = List.of(seed ?? const []);

  final List<QuizResult> results;

  @override
  Future<Result<List<QuizResult>>> getHistory() async => Result.ok(results);

  @override
  Future<Result<void>> addResult(QuizResult result) async {
    results.insert(0, result);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> clear() async {
    results.clear();
    return Result.ok(null);
  }
}

/// Fake QuestionRepository trả về lỗi để test trạng thái Error.
class FailingQuestionRepository implements QuestionRepository {
  @override
  Future<Result<List<Question>>> getAll() async =>
      Result.err(const AppError('Lỗi đọc ngân hàng câu hỏi.', code: AppErrorCode.dataLoad));

  @override
  Future<Result<List<Question>>> getByBlock(int? block) async =>
      Result.err(const AppError('Lỗi đọc câu hỏi theo block.', code: AppErrorCode.dataLoad));

  @override
  Future<Result<List<Question>>> getByLevel(String? level) async =>
      Result.err(const AppError('Lỗi đọc câu hỏi theo level.', code: AppErrorCode.dataLoad));
}

void main() {
  group('PracticeProvider', () {
    late FakeQuestionRepository qRepo;
    late FakeHistoryRepository hRepo;
    late PracticeProvider provider;

    setUp(() {
      qRepo = FakeQuestionRepository([
        fakeQuestion(number: 1, answer: 'A'),
        fakeQuestion(number: 2, answer: 'B'),
        fakeQuestion(number: 3, answer: 'C'),
      ]);
      hRepo = FakeHistoryRepository();
      provider = PracticeProvider(
        questionRepository: qRepo,
        historyRepository: hRepo,
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('loadQuestions() nạp đúng số câu và thông báo listeners', () async {
      var notified = 0;
      provider.addListener(() => notified++);

      await provider.loadQuestions(count: 2);
      expect(provider.isLoading, isFalse);
      expect(provider.totalQuestions, 2);
      expect(provider.currentIndex, 0);
      expect(provider.currentQuestion, isNotNull);
      expect(notified, greaterThan(0));
    });

    test('selectAnswer() cập nhật câu trả lời và chuyển câu', () async {
      await provider.loadQuestions(count: 3);
      final q0 = provider.questions[0];
      final q1 = provider.questions[1];

      provider.selectAnswer(q0.number, 'A');
      expect(provider.selectedAnswerFor(q0.number), 'A');

      provider.nextQuestion();
      expect(provider.currentIndex, 1);
      provider.selectAnswer(q1.number, 'D');
      expect(provider.selectedAnswerFor(q1.number), 'D');

      provider.previousQuestion();
      expect(provider.currentIndex, 0);
    });

    test('submitQuiz() chấm điểm và lưu kết quả vào HistoryRepository', () async {
      await provider.loadQuestions(count: 2);
      final q0 = provider.questions[0];
      final q1 = provider.questions[1];

      // q0 chọn đúng đáp án
      provider.selectAnswer(q0.number, q0.answer);
      // q1 chọn sai đáp án
      final wrongChoice = q1.answer == 'A' ? 'B' : 'A';
      provider.selectAnswer(q1.number, wrongChoice);

      final res = await provider.submitQuiz();
      expect(provider.isSubmitted, isTrue);
      expect(res.correct, 1);
      expect(res.total, 2);
      expect(res.wrongNumbers, [q1.number]);
      expect(hRepo.results.length, 1);
      expect(hRepo.results.first.mode, 'practice');
    });

    test('Xử lý lỗi nạp câu hỏi trong PracticeProvider', () async {
      final failProvider = PracticeProvider(
        questionRepository: FailingQuestionRepository(),
      );
      await failProvider.loadQuestions();
      expect(failProvider.hasError, isTrue);
      expect(failProvider.errorMessage, contains('Lỗi đọc ngân hàng câu hỏi.'));
      expect(failProvider.questions, isEmpty);
      failProvider.dispose();
    });
  });

  group('ExamProvider', () {
    late FakeQuestionRepository qRepo;
    late FakeHistoryRepository hRepo;
    late ExamProvider provider;

    setUp(() {
      qRepo = FakeQuestionRepository([
        fakeQuestion(number: 1, answer: 'A'),
        fakeQuestion(number: 2, answer: 'B'),
      ]);
      hRepo = FakeHistoryRepository();
      provider = ExamProvider(
        questionRepository: qRepo,
        historyRepository: hRepo,
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('startExam() khởi động thời gian và nạp câu hỏi', () async {
      await provider.startExam(count: 2, durationSeconds: 60);
      expect(provider.isLoading, isFalse);
      expect(provider.totalQuestions, 2);
      expect(provider.remainingSeconds, 60);
      expect(provider.formattedRemainingTime, '01:00');
    });

    test('submitExam() dừng timer và lưu vào lịch sử', () async {
      await provider.startExam(count: 2, durationSeconds: 60);
      provider.selectAnswer(1, 'A');
      provider.selectAnswer(2, 'B');

      final res = await provider.submitExam();
      expect(provider.isSubmitted, isTrue);
      expect(res.correct, 2);
      expect(res.total, 2);
      expect(hRepo.results.length, 1);
      expect(hRepo.results.first.mode, 'exam');
    });
  });

  group('WrongProvider', () {
    late FakeQuestionRepository qRepo;
    late FakeHistoryRepository hRepo;
    late WrongProvider provider;

    setUp(() {
      qRepo = FakeQuestionRepository([
        fakeQuestion(number: 1, answer: 'A'),
        fakeQuestion(number: 2, answer: 'B'),
        fakeQuestion(number: 3, answer: 'C'),
      ]);
      hRepo = FakeHistoryRepository([
        const QuizResult(
          id: '1',
          dateIso: '2026-11-21',
          mode: 'exam',
          total: 3,
          correct: 1,
          questionNumbers: [1, 2, 3],
          wrongNumbers: [2, 3],
        ),
      ]);
      provider = WrongProvider(
        questionRepository: qRepo,
        historyRepository: hRepo,
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('loadWrongQuestions() trích đúng câu sai từ lịch sử', () async {
      await provider.loadWrongQuestions();
      expect(provider.isLoading, isFalse);
      expect(provider.totalQuestions, 2);
      expect(provider.wrongQuestions.map((q) => q.number), containsAll([2, 3]));
    });

    test('submitRetry() nộp bài và lưu vào lịch sử với mode retry', () async {
      await provider.loadWrongQuestions();
      provider.selectAnswer(2, 'B'); // đúng
      provider.selectAnswer(3, 'C'); // đúng

      final res = await provider.submitRetry();
      expect(provider.isSubmitted, isTrue);
      expect(res.correct, 2);
      expect(res.total, 2);
      expect(hRepo.results.first.mode, 'retry');
    });

    test('loadWrongQuestions() khi lịch sử không có câu sai trả về isEmpty', () async {
      final emptyHistoryRepo = FakeHistoryRepository();
      final emptyWrongProvider = WrongProvider(
        questionRepository: qRepo,
        historyRepository: emptyHistoryRepo,
      );
      await emptyWrongProvider.loadWrongQuestions();
      expect(emptyWrongProvider.isEmpty, isTrue);
      expect(emptyWrongProvider.wrongQuestions, isEmpty);
      emptyWrongProvider.dispose();
    });
  });
}
