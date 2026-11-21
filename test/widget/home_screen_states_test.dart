/// Widget-test kiểm tra 3 trạng thái Loading / Error / Empty của HomeScreen và các lối ra.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/home_screen.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _wrap(Widget child, [AppLang lang = AppLang.vi]) =>
    ChangeNotifierProvider<LanguageProvider>(
      create: (_) => LanguageProvider(initial: lang),
      child: AppStringsScope(
        strings: AppStrings.of(lang),
        child: MaterialApp(home: child),
      ),
    );

void main() {
  testWidgets('HomeScreen hiển thị trạng thái Loading và lối ra Về trang chủ', (
    tester,
  ) async {
    var homePressed = false;
    await tester.pumpWidget(
      _wrap(
        HomeScreen.loading(
          onBackToHome: () => homePressed = true,
        ),
      ),
    );

    expect(find.byType(LoadingView), findsOneWidget);
    final backBtn = find.text(AppStrings.of(AppLang.vi).backToHome);
    expect(backBtn, findsOneWidget);

    await tester.tap(backBtn);
    expect(homePressed, isTrue);
  });

  testWidgets('HomeScreen hiển thị trạng thái Error với lối ra Thử lại & Về trang chủ', (
    tester,
  ) async {
    var retryPressed = false;
    var homePressed = false;

    await tester.pumpWidget(
      _wrap(
        HomeScreen.error(
          message: 'Không thể kết nối máy chủ',
          onRetry: () => retryPressed = true,
          onBackToHome: () => homePressed = true,
        ),
      ),
    );

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Không thể kết nối máy chủ'), findsOneWidget);

    final retryBtn = find.text(AppStrings.of(AppLang.vi).retry);
    final homeBtn = find.text(AppStrings.of(AppLang.vi).backToHome);
    expect(retryBtn, findsOneWidget);
    expect(homeBtn, findsOneWidget);

    await tester.tap(retryBtn);
    expect(retryPressed, isTrue);

    await tester.tap(homeBtn);
    expect(homePressed, isTrue);
  });

  testWidgets('HomeScreen hiển thị trạng thái Empty với lối ra Thử lại & Về trang chủ', (
    tester,
  ) async {
    var retryPressed = false;
    var homePressed = false;

    await tester.pumpWidget(
      _wrap(
        HomeScreen.empty(
          onRetry: () => retryPressed = true,
          onBackToHome: () => homePressed = true,
        ),
      ),
    );

    expect(find.byType(EmptyView), findsOneWidget);
    final retryBtn = find.text(AppStrings.of(AppLang.vi).retry);
    final homeBtn = find.text(AppStrings.of(AppLang.vi).backToHome);
    expect(retryBtn, findsOneWidget);
    expect(homeBtn, findsOneWidget);

    await tester.tap(retryBtn);
    expect(retryPressed, isTrue);

    await tester.tap(homeBtn);
    expect(homePressed, isTrue);
  });
}
