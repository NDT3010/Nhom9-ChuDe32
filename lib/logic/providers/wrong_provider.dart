/// Provider quản lý luồng Làm lại câu sai (tầng Logic).
///
/// Tuân thủ quy tắc: KHÔNG đọc file trong build(), có dispose() giải phóng bộ nhớ.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/logic/repositories/history_repository.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';
import 'package:bilingual_quiz_app/logic/services/quiz_service.dart';
import 'package:flutter/foundation.dart';

/// Quản lý trạng thái làm lại câu sai: lấy danh sách câu sai từ lịch sử, ôn luyện lại.
class WrongProvider extends ChangeNotifier {
  WrongProvider({
    required this.questionRepository,
    required this.historyRepository,
    QuizService? quizService,
  }) : _quizService = quizService ?? QuizService(questionRepository);

  /// Nguồn câu hỏi toàn diện.
  final QuestionRepository questionRepository;

  /// Nguồn lịch sử các lượt làm bài để trích xuất danh sách câu sai.
  final HistoryRepository historyRepository;

  /// Service chấm điểm lượt làm lại.
  final QuizService _quizService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Question> _wrongQuestions = const [];
  int _currentIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _isSubmitted = false;
  QuizResult? _result;

  /// true nếu đang nạp danh sách câu sai từ lịch sử và repository.
  bool get isLoading => _isLoading;

  /// Thông điệp lỗi nếu có.
  String? get errorMessage => _errorMessage;

  /// true nếu gặp lỗi khi tải.
  bool get hasError => _errorMessage != null;

  /// true nếu không có câu hỏi sai nào để ôn luyện.
  bool get isEmpty => !_isLoading && _wrongQuestions.isEmpty;

  /// Danh sách câu hỏi làm sai cần ôn tập.
  List<Question> get wrongQuestions => _wrongQuestions;

  /// Tổng số câu hỏi sai cần ôn tập.
  int get totalQuestions => _wrongQuestions.length;

  /// Chỉ số câu hỏi hiện tại.
  int get currentIndex => _currentIndex;

  /// Câu trả lời của người dùng.
  Map<int, String> get userAnswers => Map.unmodifiable(_userAnswers);

  /// true nếu đã nộp bài làm lại câu sai.
  bool get isSubmitted => _isSubmitted;

  /// Kết quả của lượt làm lại.
  QuizResult? get result => _result;

  /// Câu hỏi hiện tại đang xem.
  Question? get currentQuestion =>
      (_wrongQuestions.isNotEmpty &&
              _currentIndex >= 0 &&
              _currentIndex < _wrongQuestions.length)
          ? _wrongQuestions[_currentIndex]
          : null;

  /// Lấy đáp án đã chọn của một câu hỏi.
  String? selectedAnswerFor(int questionNumber) => _userAnswers[questionNumber];

  /// Nạp các câu hỏi đã làm sai từ lịch sử (gọi từ event/lifecycle, KHÔNG gọi trong build()).
  Future<void> loadWrongQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    _currentIndex = 0;
    _userAnswers.clear();
    _isSubmitted = false;
    _result = null;
    notifyListeners();

    // 1. Đọc lịch sử các lượt làm bài
    final historyRes = await historyRepository.getHistory();
    final List<int> wrongIds = [];
    historyRes.when(
      ok: (history) {
        final seen = <int>{};
        for (final item in history) {
          for (final wn in item.wrongNumbers) {
            if (seen.add(wn)) {
              wrongIds.add(wn);
            }
          }
        }
      },
      err: (e) {
        _errorMessage = e.message;
      },
    );

    if (_errorMessage != null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (wrongIds.isEmpty) {
      _wrongQuestions = const [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 2. Tra cứu dữ liệu câu hỏi chi tiết từ QuestionRepository
    final allRes = await questionRepository.getAll();
    allRes.when(
      ok: (allQuestions) {
        final idSet = wrongIds.toSet();
        _wrongQuestions =
            allQuestions.where((q) => idSet.contains(q.number)).toList();
        _isLoading = false;
        notifyListeners();
      },
      err: (e) {
        _wrongQuestions = const [];
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
  }

  /// Chuyển câu hỏi kế tiếp.
  void nextQuestion() {
    if (_currentIndex < _wrongQuestions.length - 1) {
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
    if (index >= 0 && index < _wrongQuestions.length && index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Chấm điểm và nộp bài làm lại câu sai.
  Future<QuizResult> submitRetry() async {
    if (_isSubmitted && _result != null) return _result!;

    final res = _quizService.grade(
      _wrongQuestions,
      _userAnswers,
      mode: 'retry',
    );
    _result = res;
    _isSubmitted = true;
    notifyListeners();

    await historyRepository.addResult(res);
    return res;
  }

  /// Đặt lại trạng thái làm lại câu sai.
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _wrongQuestions = const [];
    _currentIndex = 0;
    _userAnswers.clear();
    _isSubmitted = false;
    _result = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userAnswers.clear();
    super.dispose();
  }
}
