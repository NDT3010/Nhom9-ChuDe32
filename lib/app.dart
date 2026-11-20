/// Gốc MaterialApp: gắn Provider + theme + HomeScreen.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/screens/home_screen.dart';
import 'package:bilingual_quiz_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget App: bọc [LangController] để toàn app dùng chung ngôn ngữ.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LangController(AppLang.vi),
      child: Consumer<LangController>(
        builder: (context, lang, _) {
          return MaterialApp(
            title: lang.s.appTitle,
            theme: AppTheme.light,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
