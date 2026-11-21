/// Gốc MaterialApp: cấp [LanguageProvider] + [AppStringsScope] + theme + HomeScreen.
library;

import 'package:bilingual_quiz_app/data/datasources/local_store.dart';
import 'package:bilingual_quiz_app/data/repositories/settings_repository_impl.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/repositories/settings_repository.dart';
import 'package:bilingual_quiz_app/ui/screens/home_screen.dart';
import 'package:bilingual_quiz_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget App: bọc [LanguageProvider] để toàn app dùng chung ngôn ngữ.
class App extends StatelessWidget {
  const App({super.key, this.repository});

  /// Repository cài đặt (mặc định dùng SharedPreferences thật).
  final SettingsRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageProvider>(
      create: (_) => LanguageProvider(settingsRepository: repository ?? SettingsRepositoryImpl(const LocalStore()))..load(),
      child: Consumer<LanguageProvider>(
        builder: (context, lang, _) {
          return AppStringsScope(
            strings: lang.strings,
            child: MaterialApp(
              title: lang.strings.appTitle,
              theme: AppTheme.light,
              home: const HomeScreen(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
