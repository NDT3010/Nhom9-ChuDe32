/// Cài đặt HistoryRepository lưu vào SharedPreferences (tầng Data).
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/datasources/local_store.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/logic/repositories/history_repository.dart';

/// Lịch sử các lượt làm bài, mới nhất đứng đầu.
class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this.store);
  final LocalStore store;

  @override
  Future<Result<List<QuizResult>>> getHistory() => store.loadHistory();

  @override
  Future<Result<void>> addResult(QuizResult result) async {
    final current = await store.loadHistory();
    return current.when(
      ok: (items) {
        final next = [result, ...items];
        return store.saveHistory(next);
      },
      err: (e) => Result.err(e),
    );
  }

  @override
  Future<Result<void>> clear() => store.saveHistory(const []);
}
