/// Widget test cho WrongRetryScreen:
/// - Loading state khi đang tải câu sai
/// - Empty/Congratulations khi không có câu sai
/// - Hiển thị QuestionCard khi có câu sai
library;

import 'dart:async';

import 'package:bilingual_quiz_app/core/app_error.dart';
import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/wrong_provider.dart';
import 'package:bilingual_quiz_app/logic/repositories/history_repository.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';
import 'package:bilingual_quiz_app/ui/screens/wrong_retry_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

// ── Fakes ────────────────────────────────────────────────────────────────

final _sampleQuestion = Question(
  number: 42,
  codeId: 'K03-042',
  block: 3,
  level: 'remember',
  levelVi: 'Nhớ',
  topicVi: 'Chủ đề',
  topicEn: 'Topic',
  viQuestion: 'Câu hỏi mẫu?',
  enQuestion: 'Sample question?',
  options: const {'A': 'Chọn A', 'B': 'Chọn B', 'C': 'Chọn C', 'D': 'Chọn D'},
  answer: 'A',
  explanationVi: 'Giải thích tiếng Việt.',
  explanationEn: 'English explanation.',
);

class _FakeQuestionRepository implements QuestionRepository {
  final List<Question> questions;
  _FakeQuestionRepository([this.questions = const []]);

  @override
  Future<Result<List<Question>>> getAll() async => Result.ok(questions);

  @override
  Future<Result<List<Question>>> getByBlock(int? block) async =>
      Result.ok(questions.where((q) => block == null || q.block == block).toList());

  @override
  Future<Result<List<Question>>> getByLevel(String? level) async =>
      Result.ok(questions.where((q) => level == null || q.level == level).toList());
}

class _FakeHistoryRepo implements HistoryRepository {
  final List<int> wrongNums;
  _FakeHistoryRepo([this.wrongNums = const []]);

  @override
  Future<Result<List<QuizResult>>> getHistory() async => Result.ok(
        wrongNums.isEmpty
            ? []
            : [
                QuizResult(
                  id: '1',
                  dateIso: '2026-01-01',
                  mode: 'exam',
                  total: 1,
                  correct: 0,
                  questionNumbers: wrongNums,
                  wrongNumbers: wrongNums,
                ),
              ],
      );

  @override
  Future<Result<void>> addResult(QuizResult result) async => Result.ok(null);

  @override
  Future<Result<void>> clear() async => Result.ok(null);
}

class _ErrorHistoryRepo implements HistoryRepository {
  @override
  Future<Result<List<QuizResult>>> getHistory() async =>
      Result.err(const AppError('Lỗi đọc lịch sử', code: AppErrorCode.storage));

  @override
  Future<Result<void>> addResult(QuizResult result) async => Result.ok(null);

  @override
  Future<Result<void>> clear() async => Result.ok(null);
}

class _SlowHistoryRepo implements HistoryRepository {
  _SlowHistoryRepo(this._future);
  final Future<Result<List<QuizResult>>> _future;

  @override
  Future<Result<List<QuizResult>>> getHistory() => _future;

  @override
  Future<Result<void>> addResult(QuizResult result) async => Result.ok(null);

  @override
  Future<Result<void>> clear() async => Result.ok(null);
}

// ── Helper build ──────────────────────────────────────────────────────────

Widget _build(WrongProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LanguageProvider>(
        create: (_) => LanguageProvider(initial: AppLang.vi),
      ),
    ],
    child: AppStringsScope(
      strings: AppStrings.of(AppLang.vi),
      child: MaterialApp(
        home: WrongRetryScreen(provider: provider),
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  group('WrongRetryScreen', () {
    testWidgets('Hiển thị LoadingView khi đang tải', (tester) async {
      // Dùng Completer để giữ Future mở — provider sẽ ở trạng thái loading
      final completer = Completer<Result<List<QuizResult>>>();
      final slowRepo = _SlowHistoryRepo(completer.future);
      final provider = WrongProvider(
        questionRepository: _FakeQuestionRepository(),
        historyRepository: slowRepo,
      );
      await tester.pumpWidget(_build(provider));
      // Trigger load
      provider.loadWrongQuestions();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Giải phóng completer để tránh pending timer
      completer.complete(Result.ok([]));
      await tester.pumpAndSettle();
      provider.dispose();
    });

    testWidgets('Hiển thị chúc mừng khi không có câu sai', (tester) async {
      final provider = WrongProvider(
        questionRepository: _FakeQuestionRepository([_sampleQuestion]),
        historyRepository: _FakeHistoryRepo([]), // không có câu sai
      );
      await tester.pumpWidget(_build(provider));
      await provider.loadWrongQuestions();
      await tester.pumpAndSettle();
      expect(find.text('Tuyệt vời!'), findsOneWidget);
      expect(find.text('Luyện tập thêm'), findsOneWidget);
      provider.dispose();
    });

    testWidgets('Hiển thị QuestionCard khi có câu sai', (tester) async {
      final provider = WrongProvider(
        questionRepository: _FakeQuestionRepository([_sampleQuestion]),
        historyRepository: _FakeHistoryRepo([42]),
      );
      await tester.pumpWidget(_build(provider));
      await provider.loadWrongQuestions();
      await tester.pumpAndSettle();
      expect(find.text('K03-042'), findsOneWidget);
      expect(find.text('Câu hỏi mẫu?'), findsOneWidget);
      provider.dispose();
    });

    testWidgets('Hiển thị ErrorView khi lỗi đọc lịch sử', (tester) async {
      final provider = WrongProvider(
        questionRepository: _FakeQuestionRepository(),
        historyRepository: _ErrorHistoryRepo(),
      );
      await tester.pumpWidget(_build(provider));
      await provider.loadWrongQuestions();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      provider.dispose();
    });
  });
}
