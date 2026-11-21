/// Widget-test kiểm tra OptionTile (>= 48dp, semantics, màu đúng/sai) và QuestionCard (monospace, codeId, mức độ, giải thích).
library;

import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/ui/widgets/option_tile.dart';
import 'package:bilingual_quiz_app/ui/widgets/question_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _wrap(Widget child, [AppLang lang = AppLang.vi]) =>
    ChangeNotifierProvider<LanguageProvider>(
      create: (_) => LanguageProvider(initial: lang),
      child: AppStringsScope(
        strings: AppStrings.of(lang),
        child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
      ),
    );

void main() {
  group('OptionTile', () {
    testWidgets('Chiều cao OptionTile tối thiểu đạt 48dp và có Semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const OptionTile(
            label: 'A',
            text: 'const',
            textEn: 'const keyword',
            isBilingual: true,
          ),
        ),
      );

      final size = tester.getSize(find.byType(OptionTile));
      expect(size.height, greaterThanOrEqualTo(48.0));

      final semantics = tester.getSemantics(find.byType(OptionTile));
      expect(semantics.label, contains('Lựa chọn A: const'));
    });

    testWidgets('Hiển thị màu xanh khi đúng và màu đỏ khi sai sau khi trả lời', (
      tester,
    ) async {
      // 1. Đáp án đúng
      await tester.pumpWidget(
        _wrap(
          const OptionTile(
            label: 'C',
            text: 'const',
            isCorrect: true,
            isAnswered: true,
            selected: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // 2. Đáp án sai đã chọn
      await tester.pumpWidget(
        _wrap(
          const OptionTile(
            label: 'A',
            text: 'final',
            isCorrect: false,
            isAnswered: true,
            selected: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });
  });

  group('QuestionCard', () {
    final sampleQ = Question(
      number: 1,
      codeId: 'K01-001',
      block: 1,
      level: 'remember',
      levelVi: 'Nhớ',
      topicVi: 'Ngôn ngữ Dart',
      topicEn: 'The Dart language',
      viQuestion: 'Trong Dart, từ khoá nào là hằng số biên dịch?',
      enQuestion: 'In Dart, which keyword is a compile-time constant?',
      options: const {'A': 'final', 'B': 'var', 'C': 'const', 'D': 'late'},
      optionsEn: const {'A': 'final', 'B': 'var', 'C': 'const', 'D': 'late'},
      answer: 'C',
      code: '  const int x = 10;\n  final y = 20;',
      explanationVi: 'const là hằng số biên dịch.',
      explanationEn: 'const creates a compile-time constant.',
      source: 'https://dart.dev/language/variables',
    );

    testWidgets('Hiển thị mã câu, mức độ, khối code monospace và giải thích khi trả lời', (
      tester,
    ) async {
      var nextPressed = false;
      await tester.pumpWidget(
        _wrap(
          QuestionCard(
            question: sampleQ,
            lang: AppLang.both,
            selected: 'C',
            revealAnswer: true,
            onNext: () => nextPressed = true,
          ),
        ),
      );

      // 1. Mã câu và mức độ
      expect(find.text('K01-001'), findsOneWidget);
      expect(find.text('Câu 1'), findsOneWidget);
      expect(find.textContaining('Nhớ'), findsOneWidget);

      // 2. Nội dung song ngữ
      expect(find.text(sampleQ.viQuestion), findsOneWidget);
      expect(find.text(sampleQ.enQuestion), findsOneWidget);

      // 3. Khối code monospace
      expect(find.text(sampleQ.code!), findsOneWidget);

      // 4. Khối giải thích song ngữ và source
      expect(find.text(sampleQ.explanationVi), findsOneWidget);
      expect(find.text(sampleQ.explanationEn), findsOneWidget);
      expect(find.text(sampleQ.source), findsOneWidget);

      // 5. Nút chuyển câu
      final nextBtn = find.byType(ElevatedButton);
      expect(nextBtn, findsOneWidget);
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      expect(nextPressed, isTrue);
    });
  });
}
