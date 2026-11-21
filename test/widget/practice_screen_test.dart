/// Widget-test kiểm tra PracticeSetupScreen và PracticeScreen (3 trạng thái, làm từng câu, AlertDialog xác nhận).
library;

import 'dart:async';

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/practice_provider.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';
import 'package:bilingual_quiz_app/ui/screens/practice_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/practice_setup_screen.dart';
import 'package:bilingual_quiz_app/ui/widgets/option_tile.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/fakes.dart';

class DelayedQuestionRepository implements QuestionRepository {
  final Completer<Result<List<Question>>> completer = Completer();
  @override
  Future<Result<List<Question>>> getAll() => completer.future;
  @override
  Future<Result<List<Question>>> getByBlock(int? block) => completer.future;
  @override
  Future<Result<List<Question>>> getByLevel(String? level) => completer.future;
}

Widget _wrap(Widget child, [AppLang lang = AppLang.vi]) =>
    ChangeNotifierProvider<LanguageProvider>(
      create: (_) => LanguageProvider(initial: lang),
      child: AppStringsScope(
        strings: AppStrings.of(lang),
        child: MaterialApp(home: child),
      ),
    );

void main() {
  group('PracticeSetupScreen', () {
    testWidgets('Hiển thị đủ các tùy chọn số câu (10, 20, 30, 50) và 20 khối', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PracticeSetupScreen()));

      expect(find.text('10 câu'), findsOneWidget);
      expect(find.text('20 câu'), findsOneWidget);
      expect(find.text('30 câu'), findsOneWidget);
      expect(find.text('50 câu'), findsOneWidget);

      expect(find.textContaining('Ngôn ngữ Dart'), findsOneWidget);
      expect(find.textContaining('Tất cả các khối'), findsOneWidget);
    });
  });

  group('PracticeScreen', () {
    testWidgets('Hiển thị câu hỏi làm từng câu, chọn đáp án và hiện nút Câu tiếp theo', (
      tester,
    ) async {
      final qRepo = FakeQuestionRepository([
        fakeQuestion(number: 1, answer: 'A'),
        fakeQuestion(number: 2, answer: 'B'),
      ]);
      final wrongRepo = FakeWrongRepository();
      final provider = PracticeProvider(
        questionRepository: qRepo,
        wrongRepository: wrongRepo,
      );

      await tester.pumpWidget(
        _wrap(PracticeScreen(provider: provider, count: 2)),
      );
      await tester.pumpAndSettle();

      // Kiểm tra thanh tiến độ
      expect(find.text('1/2'), findsOneWidget);

      // Chọn đáp án A
      final optionA = find.widgetWithText(OptionTile, 'Đáp án A');
      expect(optionA, findsOneWidget);
      await tester.tap(optionA);
      await tester.pumpAndSettle();

      // Hiện nút Câu tiếp theo
      expect(find.text('Câu tiếp theo'), findsOneWidget);
    });

    testWidgets('Bấm nút Thoát khi đang làm dở hiện AlertDialog xác nhận', (
      tester,
    ) async {
      final qRepo = FakeQuestionRepository([
        fakeQuestion(number: 1, answer: 'A'),
      ]);
      final provider = PracticeProvider(questionRepository: qRepo);

      await tester.pumpWidget(
        _wrap(PracticeScreen(provider: provider, count: 1)),
      );
      await tester.pumpAndSettle();

      // Chọn đáp án để bài thành "đang làm dở"
      await tester.tap(find.widgetWithText(OptionTile, 'Đáp án A'));
      await tester.pumpAndSettle();

      // Bấm nút Thoát (Icon close)
      final exitBtn = find.byTooltip('Thoát');
      expect(exitBtn, findsOneWidget);
      await tester.tap(exitBtn);
      await tester.pumpAndSettle();

      // Hiện AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Xác nhận thoát?'), findsOneWidget);
      expect(find.text('Ở lại làm tiếp'), findsOneWidget);
    });

    testWidgets('PracticeScreen hiển thị LoadingView khi đang tải', (
      tester,
    ) async {
      final delayedRepo = DelayedQuestionRepository();
      final provider = PracticeProvider(questionRepository: delayedRepo);

      await tester.pumpWidget(
        _wrap(PracticeScreen(provider: provider)),
      );
      // Chưa complete future -> Đang nạp câu hỏi
      await tester.pump();
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Về trang chủ'), findsOneWidget);

      delayedRepo.completer.complete(Result.ok([fakeQuestion(number: 1, answer: 'A')]));
      await tester.pumpAndSettle();
    });
  });
}
