/// Hợp đồng Repository cài đặt (ngôn ngữ Việt/Anh).
library;

import 'package:bilingual_quiz_app/core/result.dart';

/// Đọc/ghi ngôn ngữ hiển thị ('vi' | 'en').
abstract class SettingsRepository {
  Future<Result<String>> getLang();
  Future<Result<void>> setLang(String lang);
}
