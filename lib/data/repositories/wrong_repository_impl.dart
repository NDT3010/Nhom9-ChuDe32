/// Triển khai WrongRepository lưu vào LocalStore (tầng Data).
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/datasources/local_store.dart';
import 'package:bilingual_quiz_app/logic/repositories/wrong_repository.dart';

/// Quản lý danh sách câu làm sai bằng SharedPreferences qua LocalStore.
class WrongRepositoryImpl implements WrongRepository {
  const WrongRepositoryImpl(this.store);

  final LocalStore store;

  @override
  Future<Result<List<int>>> getWrongQuestionNumbers() =>
      store.loadWrongQuestionNumbers();

  @override
  Future<Result<void>> addWrongQuestion(int questionNumber, {String? codeId}) async {
    final current = await store.loadWrongQuestionNumbers();
    return current.when(
      ok: (numbers) {
        if (!numbers.contains(questionNumber)) {
          final next = [...numbers, questionNumber];
          return store.saveWrongQuestionNumbers(next);
        }
        return Result.ok(null);
      },
      err: (e) => Result.err(e),
    );
  }

  @override
  Future<Result<void>> removeWrongQuestion(int questionNumber, {String? codeId}) async {
    final current = await store.loadWrongQuestionNumbers();
    return current.when(
      ok: (numbers) {
        if (numbers.contains(questionNumber)) {
          final next = numbers.where((n) => n != questionNumber).toList();
          return store.saveWrongQuestionNumbers(next);
        }
        return Result.ok(null);
      },
      err: (e) => Result.err(e),
    );
  }

  @override
  Future<Result<void>> clear() => store.saveWrongQuestionNumbers(const []);
}
