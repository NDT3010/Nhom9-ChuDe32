/// Cài đặt SettingsRepository lưu ngôn ngữ vào SharedPreferences.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/datasources/local_store.dart';
import 'package:bilingual_quiz_app/logic/repositories/settings_repository.dart';

/// Chỉ quản lý 'vi' | 'en' ở TV1.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this.store);
  final LocalStore store;

  @override
  Future<Result<String>> getLang() => store.loadLang();

  @override
  Future<Result<void>> setLang(String lang) {
    final normalized = lang == 'en' ? 'en' : 'vi';
    return store.saveLang(normalized);
  }
}
