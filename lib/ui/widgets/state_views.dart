/// 3 widget trạng thái dùng chung: Loading / Error / Empty.
library;

import 'package:material_ui/material_ui.dart';

/// Màn hình chờ khi đang tải JSON — dùng ở mọi Screen.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Đang tải câu hỏi…'});

  /// Thông điệp hiển thị dưới vòng xoay.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

/// Màn hình lỗi có nút thử lại, nút cao tối thiểu 48dp.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry, this.retryLabel = 'Thử lại'});

  /// Thông điệp lỗi tiếng Việt.
  final String message;

  /// Callback khi bấm thử lại.
  final VoidCallback onRetry;

  /// Nhãn nút thử lại.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Màn hình rỗng có nút hành động, nút cao tối thiểu 48dp.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.actionLabel, this.onAction});

  /// Thông điệp khi không có dữ liệu.
  final String message;

  /// Nhãn nút hành động (null = ẩn nút).
  final String? actionLabel;

  /// Callback khi bấm nút hành động.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
