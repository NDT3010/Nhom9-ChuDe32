/// Cài đặt QuestionRepository đọc từ asset JSON (tầng Data).
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/datasources/question_local_datasource.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';

/// Implementation duy nhất ở TV1: dữ liệu tĩnh từ JSON.
class QuestionRepositoryImpl implements QuestionRepository {
  const QuestionRepositoryImpl(this.datasource);
  final QuestionLocalDatasource datasource;

  @override
  Future<Result<List<Question>>> getAll() => datasource.loadAll();

  @override
  Future<Result<List<Question>>> getByBlock(int? block) async {
    final all = await datasource.loadAll();
    return all.when(
      ok: (items) {
        if (block == null) return Result.ok(items);
        return Result.ok(items.where((q) => q.block == block).toList());
      },
      err: (e) => Result.err(e),
    );
  }

  @override
  Future<Result<List<Question>>> getByLevel(String? level) async {
    final all = await datasource.loadAll();
    return all.when(
      ok: (items) {
        if (level == null || level.isEmpty) return Result.ok(items);
        return Result.ok(items.where((q) => q.level == level).toList());
      },
      err: (e) => Result.err(e),
    );
  }
}

/// TODO(tv2): thêm cache trong RAM + tìm kiếm theo từ khóa (search_v2).
