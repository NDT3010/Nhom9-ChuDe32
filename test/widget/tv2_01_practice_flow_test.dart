/// Widget-test TV2: Vào Luyện tập, chạm 1 lựa chọn, xác nhận hiện giải thích.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/practice_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/practice_screen.dart';
import 'package:bilingual_quiz_app/ui/widgets/option_tile.dart';
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
  testWidgets('TV2 01 Widget Test: Vào Luyện tập, chạm 1 lựa chọn, xác nhận hiện giải thích', (
    tester,
  ) async {
    const customExplanation = 'Giải thích chi tiết cho câu 1 từ TV2 test.';
    final qRepo = FakeQuestionRepository([
      fakeQuestion(
        number: 1,
        viQuestion: 'Câu hỏi kiểm tra giải thích?',
        answer: 'A',
        explanationVi: customExplanation,
      ),
    ]);
    final provider = PracticeProvider(questionRepository: qRepo);

    await tester.pumpWidget(_wrap(PracticeScreen(provider: provider, count: 1)));
    await tester.pumpAndSettle();

    // Ban đầu chưa chọn đáp án -> chưa hiển thị giải thích
    expect(find.textContaining(customExplanation), findsNothing);

    // Chạm vào lựa chọn đáp án A
    final optionA = find.widgetWithText(OptionTile, 'Đáp án A');
    expect(optionA, findsOneWidget);
    await tester.tap(optionA);
    await tester.pumpAndSettle();

    // Xác nhận đã hiện giải thích chi tiết tiếng Việt
    expect(find.textContaining(customExplanation), findsOneWidget);

    // Xác nhận hiện nút "Câu tiếp theo" (hoặc hoàn thành)
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
