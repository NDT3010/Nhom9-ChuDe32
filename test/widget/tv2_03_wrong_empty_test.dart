/// Widget-test TV2: Không có câu sai thì hiện Empty chúc mừng.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/wrong_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/wrong_retry_screen.dart';
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
  testWidgets('TV2 03 Widget Test: Không có câu sai thì hiện Empty chúc mừng', (
    tester,
  ) async {
    final qRepo = FakeQuestionRepository();
    // Lịch sử rỗng -> không có câu sai nào
    final hRepo = FakeHistoryRepo([]);
    final provider = WrongProvider(
      questionRepository: qRepo,
      historyRepository: hRepo,
    );

    await tester.pumpWidget(_wrap(WrongRetryScreen(provider: provider)));
    await tester.pumpAndSettle();

    // Xác nhận hiển thị giao diện chúc mừng / Empty khi không còn câu sai
    expect(find.text('Tuyệt vời!'), findsOneWidget);
    expect(find.text('Luyện tập thêm'), findsOneWidget);
    expect(find.text('Về trang chủ'), findsOneWidget);
  });
}
