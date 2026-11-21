/// Provider quản lý trạng thái luồng Luyện tập (tầng Logic).
///
/// Tuân thủ quy tắc: KHÔNG đọc file trong build(), có dispose() giải phóng bộ nhớ.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/logic/repositories/history_repository.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';
import 'package:bilingual_quiz_app/logic/repositories/wrong_repository.dart';
import 'package:bilingual_quiz_app/logic/services/quiz_service.dart';
import 'package:flutter/foundation.dart';

/// Quản lý trạng thái luyện tập (tải câu hỏi, chuyển câu, chọn đáp án, nộp bài).
class PracticeProvider extends ChangeNotifier {
  PracticeProvider({
    required this.questionRepository,
    QuizService? quizService,
    this.historyRepository,
    this.wrongRepository,
  }) : _quizService = quizService ?? QuizService(questionRepository);

  /// Nguồn câu hỏi.
  final QuestionRepository questionRepository;

  /// Service trộn câu hỏi và chấm điểm.
  final QuizService _quizService;

  /// Nơi lưu lịch sử nộp bài (tùy chọn).
  final HistoryRepository? historyRepository;

  /// Nơi lưu/xóa câu hỏi sai vào bộ nhớ máy.
  final WrongRepository? wrongRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Question> _questions = const [];
  int _currentIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _isSubmitted = false;
  QuizResult? _result;

  int? _selectedBlock;
  String? _selectedLevel;

  /// true nếu đang nạp câu hỏi từ repository.
  bool get isLoading => _isLoading;

  /// Thông điệp lỗi khi nạp câu hỏi (nếu có).
  String? get errorMessage => _errorMessage;

  /// true nếu có lỗi nạp dữ liệu.
  bool get hasError => _errorMessage != null;

  /// true nếu danh sách câu hỏi rỗng sau khi tải xong.
  bool get isEmpty => !_isLoading && _questions.isEmpty;

  /// Danh sách câu hỏi của lượt luyện tập.
  List<Question> get questions => _questions;

  /// Tổng số câu trong lượt luyện tập.
  int get totalQuestions => _questions.length;

  /// Chỉ số câu hỏi hiện tại (0..totalQuestions - 1).
  int get currentIndex => _currentIndex;

  /// Bản đồ câu trả lời của người dùng: số câu -> đáp án 'A'..'D'.
  Map<int, String> get userAnswers => Map.unmodifiable(_userAnswers);

  /// true nếu bài luyện tập đã được nộp.
  bool get isSubmitted => _isSubmitted;

  /// Kết quả bài luyện tập sau khi nộp.
  QuizResult? get result => _result;

  /// Khối kiến thức đang lọc (nếu có).
  int? get selectedBlock => _selectedBlock;

  /// Cấp độ đang lọc (nếu có).
  String? get selectedLevel => _selectedLevel;

  /// Câu hỏi hiện tại đang xem.
  Question? get currentQuestion =>
      (_questions.isNotEmpty &&
              _currentIndex >= 0 &&
              _currentIndex < _questions.length)
          ? _questions[_currentIndex]
          : null;

  /// Lấy đáp án đã chọn của một câu hỏi.
  String? selectedAnswerFor(int questionNumber) => _userAnswers[questionNumber];

  /// Nạp danh sách câu hỏi theo bộ lọc (gọi từ event/lifecycle, KHÔNG gọi trong build()).
  Future<void> loadQuestions({
    int? block,
    String? level,
    int count = 15,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedBlock = block;
    _selectedLevel = level;
    _currentIndex = 0;
    _userAnswers.clear();
    _isSubmitted = false;
    _result = null;
    notifyListeners();

    final quizResult = await _quizService.buildQuiz(
      count: count,
      block: block,
      level: level,
    );

    quizResult.when(
      ok: (items) {
        _questions = items;
        _isLoading = false;
        notifyListeners();
      },
      err: (e) {
        _questions = const [];
        _errorMessage = e.message;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Chọn đáp án cho câu hỏi.
  void selectAnswer(int questionNumber, String choice) {
    if (_isSubmitted) return;
    _userAnswers[questionNumber] = choice;
    notifyListeners();

    // Tự động lưu mã câu sai / xóa câu đúng vào WrongRepository
    if (wrongRepository != null) {
      final q = _questions.cast<Question?>().firstWhere(
            (item) => item?.number == questionNumber,
            orElse: () => null,
          );
      if (q != null) {
        if (!q.isCorrect(choice)) {
          wrongRepository!.addWrongQuestion(q.number, codeId: q.codeId);
        } else {
          wrongRepository!.removeWrongQuestion(q.number, codeId: q.codeId);
        }
      }
    }
  }

  /// Chuyển câu hỏi tiếp theo.
  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// Quay lại câu hỏi trước.
  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// Chuyển đến vị trí câu hỏi cụ thể.
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length && index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Chấm điểm và nộp bài luyện tập.
  Future<QuizResult> submitQuiz() async {
    if (_isSubmitted && _result != null) return _result!;

    final res = _quizService.grade(
      _questions,
      _userAnswers,
      mode: 'practice',
    );
    _result = res;
    _isSubmitted = true;
    notifyListeners();

    if (historyRepository != null) {
      await historyRepository!.addResult(res);
    }
    return res;
  }

  /// Đặt lại toàn bộ trạng thái bài luyện tập.
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _questions = const [];
    _currentIndex = 0;
    _userAnswers.clear();
    _isSubmitted = false;
    _result = null;
    _selectedBlock = null;
    _selectedLevel = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userAnswers.clear();
    super.dispose();
  }
}
