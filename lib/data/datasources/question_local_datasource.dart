/// Đọc ngân hàng câu hỏi từ asset JSON (tầng Data).
library;

import 'dart:convert';

import 'package:bilingual_quiz_app/core/app_error.dart';
import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Datasource duy nhất đọc câu hỏi: từ `assets/data/flutter_300_questions.json`.
class QuestionLocalDatasource {
  const QuestionLocalDatasource({this.assetPath = 'assets/data/flutter_300_questions.json'});

  /// Đường dẫn asset JSON.
  final String assetPath;

  /// Tải toàn bộ câu hỏi. Trả [Result.err] khi thiếu file hoặc sai định dạng.
  Future<Result<List<Question>>> loadAll() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      final List<dynamic> list;
      if (decoded is Map<String, dynamic>) {
        final q = decoded['questions'];
        if (q is! List) {
          return Result.err(const AppError('Thiếu mảng "questions" trong JSON.', code: AppErrorCode.dataParse));
        }
        list = q;
      } else if (decoded is List) {
        list = decoded;
      } else {
        return Result.err(const AppError('Định dạng JSON không hỗ trợ.', code: AppErrorCode.dataParse));
      }
      final questions = list.whereType<Map<String, dynamic>>().map(Question.fromJson).toList();
      return Result.ok(questions);
    } on AppError catch (e) {
      return Result.err(e);
    } catch (_) {
      return Result.err(const AppError('Không tải được file câu hỏi.', code: AppErrorCode.dataLoad));
    }
  }
}
