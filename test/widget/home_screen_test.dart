/// Widget-test i18n: HomeScreen hiển thị tiêu đề + đủ 5 nút menu theo ngôn ngữ.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Dựng HomeScreen với ngôn ngữ cho trước.
Widget _home(AppLang lang) => ChangeNotifierProvider<LanguageProvider>(
      create: (_) => LanguageProvider(initial: lang),
      child: AppStringsScope(
        strings: AppStrings.of(lang),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

void main() {
  testWidgets('HomeScreen hiện tiêu đề song ngữ từ app_strings', (tester) async {
    await tester.pumpWidget(_home(AppLang.vi));
    expect(find.text(AppStrings.of(AppLang.vi).appTitle), findsWidgets);
  });

  testWidgets('HomeScreen có đủ 5 nút menu', (tester) async {
    await tester.pumpWidget(_home(AppLang.vi));
    final s = AppStrings.of(AppLang.vi);
    for (final label in [s.practice, s.exam, s.wrongRetry, s.stats, s.settings]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('Đổi ngôn ngữ sang EN thì nhãn đổi theo', (tester) async {
    await tester.pumpWidget(_home(AppLang.en));
    final s = AppStrings.of(AppLang.en);
    expect(find.text(s.practice), findsOneWidget);
    expect(find.text(s.exam), findsOneWidget);
  });

  testWidgets('Chế độ song ngữ hiển thị cả VI và EN', (tester) async {
    await tester.pumpWidget(_home(AppLang.both));
    expect(find.textContaining('Luyện tập'), findsOneWidget);
    expect(find.textContaining('Practice'), findsOneWidget);
  });
}
