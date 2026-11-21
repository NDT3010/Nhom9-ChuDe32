/// Bảng chuỗi song ngữ Việt / Anh / Song ngữ cho toàn app.
///
/// Mọi chuỗi hiển thị trong UI đều lấy từ đây, không ghi chuỗi cứng trong widget.
/// Cách dùng: `AppStrings.of(AppLang.vi).appTitle` hoặc `AppStringsScope.of(context)`.
library;

import 'package:flutter/widgets.dart';

/// Ngôn ngữ hiển thị của app.
///
/// - [vi]: Tiếng Việt.
/// - [en]: Tiếng Anh.
/// - [both]: Song ngữ — hiển thị "Tiếng Việt / English" cạnh nhau.
enum AppLang {
  vi,
  en,
  both;

  /// Mã lưu xuống SharedPreferences ('vi' | 'en' | 'both').
  String get code => switch (this) {
        AppLang.vi => 'vi',
        AppLang.en => 'en',
        AppLang.both => 'both',
      };

  /// Đọc ngôn ngữ từ mã lưu trữ, mặc định 'vi' nếu mã lạ.
  static AppLang fromCode(String? code) => switch (code) {
        'en' => AppLang.en,
        'both' => AppLang.both,
        _ => AppLang.vi,
      };

  /// Nhãn hiển thị tên ngôn ngữ (dùng trong màn Cài đặt).
  String get label => switch (this) {
        AppLang.vi => 'Tiếng Việt',
        AppLang.en => 'English',
        AppLang.both => 'Song ngữ / Bilingual',
      };
}

/// Kho chuỗi theo ngôn ngữ.
///
/// Mỗi chuỗi có 1 key hằng ([keyAppTitle], [keyPractice]...) và 3 bản ánh xạ
/// [vi], [en], [both]. Truy cập qua getter: `strings.appTitle`.
class AppStrings {
  const AppStrings._(this.lang, this._map);

  /// Ngôn ngữ của bảng chuỗi này.
  final AppLang lang;

  /// Bảng ánh xạ key -> chuỗi đang dùng.
  final Map<String, String> _map;

  /// Tạo bảng chuỗi theo ngôn ngữ.
  factory AppStrings.of(AppLang lang) => AppStrings._(lang, _tableFor(lang));

  /// Bảng chuỗi theo ngôn ngữ.
  static Map<String, String> _tableFor(AppLang lang) => switch (lang) {
        AppLang.vi => vi,
        AppLang.en => en,
        AppLang.both => both,
      };

  /// Đọc chuỗi theo key, fallback về tiếng Việt rồi mới tới chính key.
  String t(String key) => _map[key] ?? vi[key] ?? key;

  // ---------------------------------------------------------------- keys

  /// Key: tiêu đề ứng dụng.
  static const String keyAppTitle = 'appTitle';
  /// Key: tiêu đề tab/trang chủ.
  static const String keyHome = 'home';
  /// Key: môi trường luyện tập.
  static const String keyPractice = 'practice';
  /// Key: môi trường thi thử.
  static const String keyExam = 'exam';
  /// Key: làm lại câu sai.
  static const String keyWrongRetry = 'wrongRetry';
  /// Key: màn thống kê.
  static const String keyStats = 'stats';
  /// Key: màn cài đặt.
  static const String keySettings = 'settings';
  /// Key: trạng thái đang tải.
  static const String keyLoading = 'loading';
  /// Key: tiêu đề lỗi.
  static const String keyErrorTitle = 'errorTitle';
  /// Key: nội dung lỗi.
  static const String keyErrorBody = 'errorBody';
  /// Key: tiêu đề rỗng.
  static const String keyEmptyTitle = 'emptyTitle';
  /// Key: nội dung rỗng.
  static const String keyEmptyBody = 'emptyBody';
  /// Key: nút thử lại.
  static const String keyRetry = 'retry';
  /// Key: nút về trang chủ.
  static const String keyBackToHome = 'backToHome';
  /// Key: nút câu tiếp theo.
  static const String keyNext = 'next';
  /// Key: nút nộp bài.
  static const String keySubmit = 'submit';
  /// Key: nhãn điểm.
  static const String keyScore = 'score';
  /// Key: số câu đúng.
  static const String keyCorrect = 'correct';
  /// Key: số câu sai.
  static const String keyIncorrect = 'incorrect';
  /// Key: hết giờ.
  static const String keyTimeUp = 'timeUp';
  /// Key: nhãn "Câu".
  static const String keyQuestion = 'question';
  /// Key: dấu phân cách "trong tổng số".
  static const String keyOf = 'of';
  /// Key: nhãn ngôn ngữ.
  static const String keyLanguage = 'language';
  /// Key: xoá dữ liệu.
  static const String keyResetData = 'resetData';
  /// Key: xác nhận xoá.
  static const String keyConfirmDelete = 'confirmDelete';
  /// Key: phụ đề dưới tiêu đề.
  static const String keyHomeSubtitle = 'homeSubtitle';
  /// Key: nút bắt đầu.
  static const String keyStart = 'start';
  /// Key: lịch sử rỗng.
  static const String keyEmptyHistory = 'emptyHistory';
  /// Key: nút xem thống kê.
  static const String keyViewStats = 'viewStats';

  // ------------------------------------------------------- bảng tiếng Việt

  /// Bản ánh xạ tiếng Việt.
  static const Map<String, String> vi = <String, String>{
    keyAppTitle: 'Trắc nghiệm Flutter song ngữ',
    keyHome: 'Trang chủ',
    keyPractice: 'Luyện tập',
    keyExam: 'Thi thử',
    keyWrongRetry: 'Làm lại câu sai',
    keyStats: 'Thống kê',
    keySettings: 'Cài đặt',
    keyLoading: 'Đang tải câu hỏi…',
    keyErrorTitle: 'Đã xảy ra lỗi',
    keyErrorBody: 'Không thể tải dữ liệu câu hỏi. Vui lòng thử lại.',
    keyEmptyTitle: 'Chưa có dữ liệu',
    keyEmptyBody: 'Bạn chưa có kết quả nào. Hãy bắt đầu một bài luyện tập.',
    keyRetry: 'Thử lại',
    keyBackToHome: 'Về trang chủ',
    keyNext: 'Tiếp theo',
    keySubmit: 'Nộp bài',
    keyScore: 'Điểm',
    keyCorrect: 'Đúng',
    keyIncorrect: 'Sai',
    keyTimeUp: 'Hết giờ',
    keyQuestion: 'Câu',
    keyOf: 'trên',
    keyLanguage: 'Ngôn ngữ',
    keyResetData: 'Xoá dữ liệu',
    keyConfirmDelete: 'Bạn có chắc muốn xoá toàn bộ lịch sử làm bài?',
    keyHomeSubtitle: 'Ngân hàng 300 câu hỏi Việt – Anh',
    keyStart: 'Bắt đầu',
    keyEmptyHistory: 'Chưa có lịch sử làm bài.',
    keyViewStats: 'Xem thống kê',
  };

  // ---------------------------------------------------------- bảng tiếng Anh

  /// Bản ánh xạ tiếng Anh.
  static const Map<String, String> en = <String, String>{
    keyAppTitle: 'Bilingual Flutter Quiz',
    keyHome: 'Home',
    keyPractice: 'Practice',
    keyExam: 'Mock Exam',
    keyWrongRetry: 'Retry Wrong Answers',
    keyStats: 'Statistics',
    keySettings: 'Settings',
    keyLoading: 'Loading questions…',
    keyErrorTitle: 'Something went wrong',
    keyErrorBody: 'We could not load the question data. Please try again.',
    keyEmptyTitle: 'No data yet',
    keyEmptyBody: 'You have no results yet. Start a practice session to begin.',
    keyRetry: 'Retry',
    keyBackToHome: 'Back to Home',
    keyNext: 'Next',
    keySubmit: 'Submit',
    keyScore: 'Score',
    keyCorrect: 'Correct',
    keyIncorrect: 'Incorrect',
    keyTimeUp: "Time's up",
    keyQuestion: 'Question',
    keyOf: 'of',
    keyLanguage: 'Language',
    keyResetData: 'Reset Data',
    keyConfirmDelete: 'Are you sure you want to delete all your quiz history?',
    keyHomeSubtitle: 'A 300-question Vietnamese – English question bank',
    keyStart: 'Start',
    keyEmptyHistory: 'No quiz history yet.',
    keyViewStats: 'View Statistics',
  };

  // -------------------------------------------------------- bảng song ngữ

  /// Bản ánh xạ song ngữ: "Tiếng Việt / English".
  static const Map<String, String> both = <String, String>{
    keyAppTitle: 'Trắc nghiệm Flutter song ngữ / Bilingual Flutter Quiz',
    keyHome: 'Trang chủ / Home',
    keyPractice: 'Luyện tập / Practice',
    keyExam: 'Thi thử / Mock Exam',
    keyWrongRetry: 'Làm lại câu sai / Retry Wrong Answers',
    keyStats: 'Thống kê / Statistics',
    keySettings: 'Cài đặt / Settings',
    keyLoading: 'Đang tải câu hỏi… / Loading questions…',
    keyErrorTitle: 'Đã xảy ra lỗi / Something went wrong',
    keyErrorBody:
        'Không thể tải dữ liệu câu hỏi. Vui lòng thử lại. / We could not load the question data. Please try again.',
    keyEmptyTitle: 'Chưa có dữ liệu / No data yet',
    keyEmptyBody:
        'Bạn chưa có kết quả nào. Hãy bắt đầu một bài luyện tập. / You have no results yet. Start a practice session to begin.',
    keyRetry: 'Thử lại / Retry',
    keyBackToHome: 'Về trang chủ / Back to Home',
    keyNext: 'Tiếp theo / Next',
    keySubmit: 'Nộp bài / Submit',
    keyScore: 'Điểm / Score',
    keyCorrect: 'Đúng / Correct',
    keyIncorrect: 'Sai / Incorrect',
    keyTimeUp: "Hết giờ / Time's up",
    keyQuestion: 'Câu / Question',
    keyOf: 'trên / of',
    keyLanguage: 'Ngôn ngữ / Language',
    keyResetData: 'Xoá dữ liệu / Reset Data',
    keyConfirmDelete:
        'Bạn có chắc muốn xoá toàn bộ lịch sử làm bài? / Are you sure you want to delete all your quiz history?',
    keyHomeSubtitle: 'Ngân hàng 300 câu hỏi Việt – Anh / A 300-question Vietnamese – English question bank',
    keyStart: 'Bắt đầu / Start',
    keyEmptyHistory: 'Chưa có lịch sử làm bài. / No quiz history yet.',
    keyViewStats: 'Xem thống kê / View Statistics',
  };

  // -------------------------------------------------------------- getters

  /// Tiêu đề ứng dụng.
  String get appTitle => t(keyAppTitle);
  /// Tiêu đề trang chủ.
  String get home => t(keyHome);
  /// Môi trường luyện tập.
  String get practice => t(keyPractice);
  /// Môi trường thi thử.
  String get exam => t(keyExam);
  /// Làm lại câu sai.
  String get wrongRetry => t(keyWrongRetry);

  /// Tên cũ của [wrongRetry], giữ để tương thích code cũ.
  String get retryWrong => t(keyWrongRetry);
  /// Màn thống kê.
  String get stats => t(keyStats);
  /// Màn cài đặt.
  String get settings => t(keySettings);
  /// Trạng thái đang tải.
  String get loading => t(keyLoading);
  /// Tiêu đề lỗi.
  String get errorTitle => t(keyErrorTitle);
  /// Nội dung lỗi.
  String get errorBody => t(keyErrorBody);
  /// Tiêu đề rỗng.
  String get emptyTitle => t(keyEmptyTitle);
  /// Nội dung rỗng.
  String get emptyBody => t(keyEmptyBody);
  /// Nút thử lại.
  String get retry => t(keyRetry);
  /// Nút về trang chủ.
  String get backToHome => t(keyBackToHome);
  /// Nút câu tiếp theo.
  String get next => t(keyNext);
  /// Nút nộp bài.
  String get submit => t(keySubmit);
  /// Nhãn điểm.
  String get score => t(keyScore);
  /// Số câu đúng.
  String get correct => t(keyCorrect);
  /// Số câu sai.
  String get incorrect => t(keyIncorrect);
  /// Hết giờ.
  String get timeUp => t(keyTimeUp);
  /// Nhãn "Câu".
  String get question => t(keyQuestion);
  /// Dấu phân cách "trong tổng số".
  String get of => t(keyOf);
  /// Nhãn ngôn ngữ.
  String get language => t(keyLanguage);
  /// Xoá dữ liệu.
  String get resetData => t(keyResetData);
  /// Xác nhận xoá.
  String get confirmDelete => t(keyConfirmDelete);
  /// Phụ đề dưới tiêu đề.
  String get homeSubtitle => t(keyHomeSubtitle);
  /// Nút bắt đầu.
  String get start => t(keyStart);
  /// Lịch sử rỗng.
  String get emptyHistory => t(keyEmptyHistory);
  /// Nút xem thống kê.
  String get viewStats => t(keyViewStats);

  /// Đường dẫn asset JSON (không phụ thuộc ngôn ngữ).
  static const String assetQuestionsPath = 'assets/data/flutter_300_questions.json';
}

/// Cung cấp [AppStrings] cho cây widget con qua InheritedWidget.
///
/// Màn hình đọc bằng: `AppStringsScope.of(context).practice`.
class AppStringsScope extends InheritedWidget {
  /// Bọc cây con với bảng chuỗi tương ứng ngôn ngữ hiện tại.
  const AppStringsScope({super.key, required this.strings, required super.child});

  /// Bảng chuỗi được cung cấp.
  final AppStrings strings;

  /// Đọc bảng chuỗi từ context (tự đăng ký dependency).
  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    assert(scope != null, 'AppStringsScope.of() được gọi ngoài AppStringsScope.');
    return scope!.strings;
  }

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) => oldWidget.strings.lang != strings.lang;
}
