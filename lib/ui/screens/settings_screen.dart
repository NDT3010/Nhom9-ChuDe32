/// Màn hình Cài đặt: chuyển ngôn ngữ Việt / English / Song ngữ (chuẩn TV2).
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Màn Cài đặt: nhóm tùy chọn ngôn ngữ hiển thị.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);
    final lang = context.watch<LanguageProvider>().language;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
        leading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                s.language,
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
        ),
      ),
    );
  }
}
