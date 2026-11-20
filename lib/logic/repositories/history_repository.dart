/// Hợp đồng Repository lịch sử (tầng Logic).
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';

/// Lưu/đọc các lượt làm bài.
abstract class HistoryRepository {
  Future<Result<List<QuizResult>>> getHistory();
  Future<Result<void>> addResult(QuizResult result);
  Future<Result<void>> clear();
}
