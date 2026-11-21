/// Widget-test TV2: Vào Thi thử, nộp bài, xác nhận hiện điểm.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/exam_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/exam_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../helpers/fakes.dart';

Widget _wrap(Widget child) => ChangeNotifierProvider<LanguageProvider>(
      create: (_) => LanguageProvider(initial: AppLang.vi),
      child: AppStringsScope(
        strings: AppStrings.of(AppLang.vi),
        child: MaterialApp(home: child),
      ),
    );

void main() {
  testWidgets('TV2 02 Widget Test: Vào Thi thử, nộp bài, xác nhận hiện điểm', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final qRepo = FakeQuestionRepository([
      fakeQuestion(number: 1, answer: 'A'),
      fakeQuestion(number: 2, answer: 'B'),
    ]);
    final hRepo = FakeHistoryRepo();
    final provider = ExamProvider(
      questionRepository: qRepo,
      historyRepository: hRepo,
    );

    await tester.pumpWidget(_wrap(ExamScreen(provider: provider)));
    await tester.pumpAndSettle();

    // 1. Màn hình cấu hình: Chạm nút "Bắt đầu"
    final startButton = find.widgetWithText(ElevatedButton, 'Bắt đầu');
    expect(startButton, findsOneWidget);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    // 2. Màn hình làm bài: Chạm vào đáp án A cho câu 1
    final optionA = find.text('Đáp án A');
    expect(optionA, findsOneWidget);
    await tester.tap(optionA);
    await tester.pumpAndSettle();

    // Chạm nút "Nộp bài" trên AppBar
    final submitButton = find.widgetWithText(TextButton, 'Nộp bài');
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // 3. Hộp thoại xác nhận nộp bài: Bấm xác nhận
    expect(find.byType(AlertDialog), findsOneWidget);
    final confirmSubmit = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(ElevatedButton, 'Nộp bài'),
    );
    expect(confirmSubmit, findsOneWidget);
    await tester.tap(confirmSubmit);
    await tester.pumpAndSettle();

    // 4. Màn hình kết quả: Xác nhận hiển thị điểm số trên thang 10
    expect(find.textContaining('/ 10'), findsOneWidget);
    expect(find.textContaining('chính xác'), findsOneWidget);
    expect(find.text('Về trang chủ'), findsOneWidget);
  });
}
