/// Fake dùng chung cho unit-test: giả lập QuestionRepository không cần asset JSON.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';
import 'package:bilingual_quiz_app/logic/repositories/wrong_repository.dart';

/// Câu hỏi mẫu cố định cho test.
Question fakeQuestion({int number = 1, String answer = 'A'}) => Question(
      number: number,
      codeId: 'K01-${number.toString().padLeft(3, '0')}',
      block: 1,
      level: 'remember',
      levelVi: 'Nhớ',
      topicVi: 'Chủ đề mẫu',
      topicEn: 'Sample topic',
      viQuestion: 'Câu hỏi mẫu số $number?',
      enQuestion: 'Sample question $number?',
      options: const {'A': 'Đáp án A', 'B': 'Đáp án B', 'C': 'Đáp án C', 'D': 'Đáp án D'},
      answer: answer,
    );

/// Repository giả trả về danh sách cố định.
class FakeQuestionRepository implements QuestionRepository {
  FakeQuestionRepository([List<Question>? seed])
      : questions = seed ?? [fakeQuestion(number: 1, answer: 'A'), fakeQuestion(number: 2, answer: 'B')];

  final List<Question> questions;

  @override
  Future<Result<List<Question>>> getAll() async => Result.ok(questions);

  @override
  Future<Result<List<Question>>> getByBlock(int? block) async =>
      Result.ok(block == null ? questions : questions.where((q) => q.block == block).toList());

  @override
  Future<Result<List<Question>>> getByLevel(String? level) async =>
      Result.ok(level == null || level.isEmpty ? questions : questions.where((q) => q.level == level).toList());
}

/// Fake WrongRepository dùng cho unit-test.
class FakeWrongRepository implements WrongRepository {
  FakeWrongRepository([List<int>? seed]) : wrongNumbers = List.of(seed ?? const []);

  final List<int> wrongNumbers;

  @override
  Future<Result<List<int>>> getWrongQuestionNumbers() async => Result.ok(wrongNumbers);

  @override
  Future<Result<void>> addWrongQuestion(int questionNumber, {String? codeId}) async {
    if (!wrongNumbers.contains(questionNumber)) {
      wrongNumbers.add(questionNumber);
    }
    return Result.ok(null);
  }

  @override
  Future<Result<void>> removeWrongQuestion(int questionNumber, {String? codeId}) async {
    wrongNumbers.remove(questionNumber);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> clear() async {
    wrongNumbers.clear();
    return Result.ok(null);
  }
}
