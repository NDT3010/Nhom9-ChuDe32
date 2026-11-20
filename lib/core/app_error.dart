/// Lỗi dùng chung toàn app: mỗi tầng đều trả về [AppError] thay vì Exception thô.
library;

/// Mã lỗi quy ước để UI/test có thể so sánh.
enum AppErrorCode {
  /// Không đọc được asset JSON.
  dataLoad,
  /// Dữ liệu JSON sai định dạng.
  dataParse,
  /// Lỗi đọc/ghi bộ nhớ máy (SharedPreferences).
  storage,
  /// Tham số không hợp lệ (ví dụ xin 0 câu hỏi).
  invalidArg,
  /// Lỗi chưa phân loại.
  unknown,
}

/// Đối tượng lỗi chuẩn của app.
class AppError implements Exception {
  const AppError(this.message, {this.code = AppErrorCode.unknown});

  /// Thông điệp hiển thị được cho người dùng (tiếng Việt).
  final String message;

  /// Mã phân loại lỗi.
  final AppErrorCode code;

  @override
  String toString() => 'AppError($code): $message';
}
