/// Provider quản lý phòng Thi thử có đếm giờ (tầng Logic).
///
/// Tuân thủ quy tắc: KHÔNG chạy timer trong build(), có dispose() hủy Timer.
library;

import 'dart:async';

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/logic/repositories/history_repository.dart';
import 'package:bilingual_quiz_app/logic/repositories/question_repository.dart';
import 'package:bilingual_quiz_app/logic/services/quiz_service.dart';
import 'package:flutter/foundation.dart';

/// Quản lý trạng thái thi thử: sinh đề, đếm ngược thời gian, tự nộp khi hết giờ.
class ExamProvider extends ChangeNotifier {
  ExamProvider({
    required this.questionRepository,
    QuizService? quizService,
    this.historyRepository,
  }) : _quizService = quizService ?? QuizService(questionRepository);

  /// Nguồn câu hỏi.
  final QuestionRepository questionRepository;

  /// Service sinh đề ngẫu nhiên và chấm điểm.
  final QuizService _quizService;

  /// Nơi lưu kết quả thi thử.
  final HistoryRepository? historyRepository;

  Timer? _timer;
  int _remainingSeconds = 0;
  int _initialDurationSeconds = 0;
  bool _isLoading = false;
  String? _errorMessage;
  List<Question> _questions = const [];
  int _currentIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _isSubmitted = false;
  bool _isTimeUp = false;
  QuizResult? _result;

  /// true nếu đang nạp đề thi.
  bool get isLoading => _isLoading;

  /// Thông điệp lỗi nếu có.
  String? get errorMessage => _errorMessage;

  /// true nếu gặp lỗi khi sinh đề thi.
  bool get hasError => _errorMessage != null;

  /// true nếu không có câu hỏi nào sau khi tải.
  bool get isEmpty => !_isLoading && _questions.isEmpty;

  /// Danh sách câu hỏi trong đề thi.
  List<Question> get questions => _questions;

  /// Tổng số câu trong đề thi.
  int get totalQuestions => _questions.length;

  /// Chỉ số câu hỏi hiện tại.
  int get currentIndex => _currentIndex;

  /// Đáp án người dùng đã chọn.
  Map<int, String> get userAnswers => Map.unmodifiable(_userAnswers);

  /// true nếu bài thi đã được nộp.
  bool get isSubmitted => _isSubmitted;

  /// true nếu bài thi kết thúc do hết thời gian làm bài.
  bool get isTimeUp => _isTimeUp;

  /// Kết quả sau khi nộp bài thi.
  QuizResult? get result => _result;

  /// Số giây còn lại của bài thi.
  int get remainingSeconds => _remainingSeconds;

  /// Thời gian ban đầu của ca thi (tính bằng giây).
  int get initialDurationSeconds => _initialDurationSeconds;

  /// Thời gian đã trôi qua kể từ khi bắt đầu thi.
  int get elapsedSeconds => _initialDurationSeconds - _remainingSeconds;

  /// Câu hỏi hiện tại đang xem.
  Question? get currentQuestion =>
      (_questions.isNotEmpty &&
              _currentIndex >= 0 &&
              _currentIndex < _questions.length)
          ? _questions[_currentIndex]
          : null;

  /// Lấy đáp án đã chọn của một câu hỏi.
  String? selectedAnswerFor(int questionNumber) => _userAnswers[questionNumber];

  /// Định dạng mm:ss hiển thị đồng hồ đếm ngược trên giao diện.
  String get formattedRemainingTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Khởi động bài thi thử (gọi từ sự kiện của người dùng, KHÔNG gọi trong build()).
  Future<void> startExam({
    int count = 20,
    int durationSeconds = 15 * 60,
  }) async {
    _stopTimer();
    _isLoading = true;
    _errorMessage = null;
    _isSubmitted = false;
    _isTimeUp = false;
    _currentIndex = 0;
    _userAnswers.clear();
    _result = null;
    _initialDurationSeconds = durationSeconds;
    _remainingSeconds = durationSeconds;
    notifyListeners();

    final res = await _quizService.buildQuiz(count: count);
    res.when(
      ok: (items) {
        _questions = items;
        _isLoading = false;
        _startTimer();
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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _remainingSeconds = 0;
        _isTimeUp = true;
        _stopTimer();
        submitExam();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Chọn đáp án cho câu hỏi.
  void selectAnswer(int questionNumber, String choice) {
    if (_isSubmitted) return;
    _userAnswers[questionNumber] = choice;
    notifyListeners();
  }

  /// Chuyển câu hỏi kế tiếp.
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

  /// Nộp bài thi thử và lưu kết quả vào lịch sử.
  Future<QuizResult> submitExam() async {
    if (_isSubmitted && _result != null) return _result!;

    _stopTimer();
    final res = _quizService.grade(
      _questions,
      _userAnswers,
      mode: 'exam',
    );
    final gradedResult = QuizResult(
      id: res.id,
      dateIso: res.dateIso,
      mode: res.mode,
      total: res.total,
      correct: res.correct,
      questionNumbers: res.questionNumbers,
      wrongNumbers: res.wrongNumbers,
      durationSeconds: elapsedSeconds,
    );
    _result = gradedResult;
    _isSubmitted = true;
    notifyListeners();

    if (historyRepository != null) {
      await historyRepository!.addResult(gradedResult);
    }
    return gradedResult;
  }

  /// Hủy tài nguyên và Timer khi provider bị dispose.
  @override
  void dispose() {
    _stopTimer();
    _userAnswers.clear();
    super.dispose();
  }
}
