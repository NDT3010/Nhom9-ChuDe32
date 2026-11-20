/// Chuỗi song ngữ Việt/Anh dùng chung toàn app (thay cho gen_l10n ở TV1).
///
/// HomeScreen và các màn hình lấy tiêu đề/label từ đây để thầy thấy rõ
/// app hỗ trợ 2 ngôn ngữ ngay từ khung.
library;

/// Ngôn ngữ hiển thị của app.
enum AppLang { vi, en }

/// Kho chuỗi tĩnh, truy cập kiểu `AppStrings.of(lang).appTitle`.
class AppStrings {
  const AppStrings._(this.lang);
  final AppLang lang;

  bool get isVi => lang == AppLang.vi;

  /// Chuỗi theo ngôn ngữ hiện tại.
  factory AppStrings.of(AppLang lang) => AppStrings._(lang);

  String get appTitle => isVi ? 'Trắc nghiệm Flutter song ngữ' : 'Bilingual Flutter Quiz';
  String get homeSubtitle => isVi
      ? 'Ngân hàng 300 câu hỏi Việt – Anh'
      : '300-question Vietnamese – English bank';
  String get practice => isVi ? 'Luyện tập' : 'Practice';
  String get exam => isVi ? 'Thi thử' : 'Mock exam';
  String get retryWrong => isVi ? 'Làm lại câu sai' : 'Retry wrong answers';
  String get stats => isVi ? 'Thống kê' : 'Statistics';
  String get settings => isVi ? 'Cài đặt' : 'Settings';
  String get start => isVi ? 'Bắt đầu' : 'Start';
  String get loading => isVi ? 'Đang tải câu hỏi…' : 'Loading questions…';
  String get emptyHistory => isVi ? 'Chưa có lịch sử làm bài.' : 'No quiz history yet.';
  String get viewStats => isVi ? 'Xem thống kê' : 'View statistics';

  /// Chuỗi cố định không phụ thuộc ngôn ngữ.
  static const String assetQuestionsPath = 'assets/data/flutter_300_questions.json';
}
