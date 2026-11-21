/// Kết quả trả về dùng chung cho mọi Repository/Service (3 tầng).
///
/// Dùng [Result.ok] khi thành công, [Result.err] khi thất bại kèm [AppError].
/// Giúp tầng UI chỉ cần `when` một chỗ thay vì try/catch rải rác.
library;

import 'package:bilingual_quiz_app/core/app_error.dart';

/// Kiểu Result đóng (sealed): chỉ có đúng 2 trạng thái Ok / Err.
sealed class Result<T> {
  const Result();

  /// Tạo kết quả thành công.
  factory Result.ok(T value) = Ok<T>;

  /// Tạo kết quả thất bại.
  factory Result.err(AppError error) = Err<T>;
}

/// Thành công, giữ [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

/// Thất bại, giữ [error].
final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;
}

/// Tiện ích `when` để rẽ nhánh gọn trong UI.
extension ResultWhen<T> on Result<T> {
  R when<R>({required R Function(T value) ok, required R Function(AppError e) err}) {
    final self = this;
    if (self is Ok<T>) return ok(self.value);
    return err((self as Err<T>).error);
  }

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Trả về giá trị nếu thành công, null nếu thất bại.
  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;
}
