/// Hợp đồng Repository câu hỏi (tầng Logic) — tầng UI chỉ phụ thuộc interface này.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';

/// Nguồn câu hỏi cho QuizService / các màn hình.
abstract class QuestionRepository {
  /// Lấy toàn bộ câu hỏi.
  Future<Result<List<Question>>> getAll();

  /// Lọc theo block (1..20). Null = tất cả.
  Future<Result<List<Question>>> getByBlock(int? block);

  /// Lọc theo level: remember | understand | apply. Null = tất cả.
  Future<Result<List<Question>>> getByLevel(String? level);
}
