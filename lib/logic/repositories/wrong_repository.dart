/// Hợp đồng Repository câu hỏi làm sai (tầng Logic).
library;

import 'package:bilingual_quiz_app/core/result.dart';

/// Lưu trữ và cập nhật danh sách các câu làm sai xuống bộ nhớ máy.
abstract class WrongRepository {
  /// Lấy danh sách số thứ tự câu hỏi làm sai.
  Future<Result<List<int>>> getWrongQuestionNumbers();

  /// Thêm một câu làm sai vào bộ nhớ.
  Future<Result<void>> addWrongQuestion(int questionNumber, {String? codeId});

  /// Xóa một câu khỏi danh sách câu sai khi người dùng đã trả lời đúng.
  Future<Result<void>> removeWrongQuestion(int questionNumber, {String? codeId});

  /// Xóa toàn bộ danh sách câu hỏi làm sai.
  Future<Result<void>> clear();
}
