/// Màn hình Cài đặt: chuyển ngôn ngữ Việt / English / Song ngữ.
///
/// TV1-02: màn này dùng thật [LanguageProvider] để đổi ngôn ngữ và lưu xuống máy.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Màn Cài đặt — hiện có nhóm chọn ngôn ngữ.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);
    final lang = context.watch<LanguageProvider>().language;
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          RadioGroup<AppLang>(
            groupValue: lang,
            onChanged: (value) {
              if (value == null) return;
              context.read<LanguageProvider>().setLanguage(value);
            },
            child: Column(
              children: [
                for (final option in AppLang.values)
                  RadioListTile<AppLang>(
                    value: option,
                    title: Text(option.label),
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
