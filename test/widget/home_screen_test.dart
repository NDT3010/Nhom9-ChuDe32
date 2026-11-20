/// Widget-test khung TV1: HomeScreen hiển thị tiêu đề + đủ 5 nút menu.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _home() => ChangeNotifierProvider(
      create: (_) => LangController(AppLang.vi),
      child: const MaterialApp(home: HomeScreen()),
    );

void main() {
  testWidgets('HomeScreen hiện tiêu đề song ngữ từ app_strings', (tester) async {
    await tester.pumpWidget(_home());
    expect(find.text(AppStrings.of(AppLang.vi).appTitle), findsWidgets);
  });

  testWidgets('HomeScreen có đủ 5 nút menu', (tester) async {
    await tester.pumpWidget(_home());
    final s = AppStrings.of(AppLang.vi);
    for (final label in [s.practice, s.exam, s.retryWrong, s.stats, s.settings]) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
