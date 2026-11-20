/// Lưu trữ cục bộ bằng SharedPreferences (lịch sử + cài đặt).
library;

import 'dart:convert';

import 'package:bilingual_quiz_app/core/app_error.dart';
import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key lưu trong SharedPreferences.
abstract class LocalStoreKeys {
  static const String history = 'quiz_history_v1';
  static const String lang = 'app_lang_v1';
}

/// Lớp bọc SharedPreferences để tầng Repository không phụ thuộc trực tiếp plugin.
class LocalStore {
  const LocalStore();

  Future<Result<List<QuizResult>>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(LocalStoreKeys.history);
      if (raw == null || raw.isEmpty) return Result.ok(const []);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return Result.err(const AppError('Lịch sử bị lỗi định dạng.', code: AppErrorCode.storage));
      }
      final items = decoded.whereType<Map<String, dynamic>>().map(QuizResult.fromJson).toList();
      return Result.ok(items);
    } catch (_) {
      return Result.err(const AppError('Không đọc được lịch sử.', code: AppErrorCode.storage));
    }
  }

  Future<Result<void>> saveHistory(List<QuizResult> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(LocalStoreKeys.history, raw);
      return Result.ok(null);
    } catch (_) {
      return Result.err(const AppError('Không lưu được lịch sử.', code: AppErrorCode.storage));
    }
  }

  Future<Result<String>> loadLang() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Result.ok(prefs.getString(LocalStoreKeys.lang) ?? 'vi');
    } catch (_) {
      return Result.err(const AppError('Không đọc được ngôn ngữ.', code: AppErrorCode.storage));
    }
  }

  Future<Result<void>> saveLang(String lang) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStoreKeys.lang, lang);
      return Result.ok(null);
    } catch (_) {
      return Result.err(const AppError('Không lưu được ngôn ngữ.', code: AppErrorCode.storage));
    }
  }
}
