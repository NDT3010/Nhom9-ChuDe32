/// Unit-test i18n: bảng chuỗi 3 ngôn ngữ + LanguageProvider lưu/đọc ngôn ngữ.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository giả lưu ngôn ngữ vào bộ nhớ, không cần SharedPreferences thật.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.stored = 'vi']);
  String stored;

  @override
  Future<Result<String>> getLang() async => Result.ok(stored);

  @override
  Future<Result<void>> setLang(String lang) async {
    stored = lang;
    return Result.ok(null);
  }
}

void main() {
  group('AppStrings', () {
    test('cả 3 bản ánh xạ có đủ key', () {
      for (final table in [AppStrings.vi, AppStrings.en, AppStrings.both]) {
        for (final key in AppStrings.vi.keys) {
          expect(table.containsKey(key), isTrue, reason: 'thiếu key $key');
          expect(table[key]!.trim(), isNotEmpty);
        }
      }
    });

    test('tiếng Việt và tiếng Anh khác nhau', () {
      expect(AppStrings.of(AppLang.vi).practice, 'Luyện tập');
      expect(AppStrings.of(AppLang.en).practice, 'Practice');
    });

    test('bản song ngữ chứa cả hai ngôn ngữ', () {
      final both = AppStrings.of(AppLang.both).practice;
      expect(both, contains('Luyện tập'));
      expect(both, contains('Practice'));
    });

    test('fromCode đọc đúng mã và fallback về vi', () {
      expect(AppLang.fromCode('en'), AppLang.en);
      expect(AppLang.fromCode('both'), AppLang.both);
      expect(AppLang.fromCode('vi'), AppLang.vi);
      expect(AppLang.fromCode(null), AppLang.vi);
      expect(AppLang.fromCode('xyz'), AppLang.vi);
    });
  });

  group('LanguageProvider', () {
    test('load() đọc ngôn ngữ đã lưu', () async {
      final repo = FakeSettingsRepository('en');
      final provider = LanguageProvider(settingsRepository: repo);
      await provider.load();
      expect(provider.language, AppLang.en);
      expect(provider.isLoaded, isTrue);
      expect(provider.strings.practice, 'Practice');
    });

    test('setLanguage() cập nhật RAM và lưu xuống máy', () async {
      final repo = FakeSettingsRepository('vi');
      final provider = LanguageProvider(settingsRepository: repo);
      await provider.setLanguage(AppLang.both);
      expect(provider.language, AppLang.both);
      expect(repo.stored, 'both');
    });

    test('setLanguage() thông báo listener', () async {
      final provider = LanguageProvider();
      var notified = 0;
      provider.addListener(() => notified++);
      await provider.setLanguage(AppLang.en);
      expect(notified, 1);
      // Gọi lại cùng ngôn ngữ thì không thông báo lần nữa.
      await provider.setLanguage(AppLang.en);
      expect(notified, 1);
    });
  });
}
