/// Màn hình chính: menu 4 chế độ lớn + cài đặt, hỗ trợ 3 trạng thái Loading/Error/Empty.
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/screens/exam_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/practice_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/settings_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/stats_screen.dart';
import 'package:bilingual_quiz_app/ui/screens/wrong_retry_screen.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

/// Trang chủ: 4 nút lớn >= 48dp + nút Cài đặt, bố cục cuộn tương thích màn hình nhỏ (320dp) và tablet.
///
/// Hỗ trợ hiển thị 3 trạng thái Loading / Error / Empty khi nạp dữ liệu với lối ra (Thử lại / Về trang chủ).
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.isLoading = false,
    this.errorMessage,
    this.isEmpty = false,
    this.onRetry,
    this.onBackToHome,
  });

  /// Trạng thái đang tải dữ liệu.
  const HomeScreen.loading({
    super.key,
    this.onBackToHome,
  })  : isLoading = true,
        errorMessage = null,
        isEmpty = false,
        onRetry = null;

  /// Trạng thái lỗi tải dữ liệu với lối ra Thử lại & Về trang chủ.
  const HomeScreen.error({
    super.key,
    required String message,
    this.onRetry,
    this.onBackToHome,
  })  : isLoading = false,
        errorMessage = message,
        isEmpty = false;

  /// Trạng thái dữ liệu rỗng.
  const HomeScreen.empty({
    super.key,
    this.onRetry,
    this.onBackToHome,
  })  : isLoading = false,
        errorMessage = null,
        isEmpty = true;

  /// Cờ hiển thị trạng thái Loading.
  final bool isLoading;

  /// Thông điệp lỗi khi nạp dữ liệu (khác null sẽ hiển thị ErrorView).
  final String? errorMessage;

  /// Cờ hiển thị trạng thái Empty.
  final bool isEmpty;

  /// Callback cho hành động Thử lại.
  final VoidCallback? onRetry;

  /// Callback cho hành động Về trang chủ.
  final VoidCallback? onBackToHome;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    // 1. Trạng thái Đang tải (Loading) kèm lối ra Về trang chủ
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(s.appTitle)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingView(message: s.loading),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onBackToHome ?? () => _resetToHome(context),
                    icon: const Icon(Icons.home),
                    label: Text(s.backToHome),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Trạng thái Lỗi (Error) kèm 2 lối ra: Thử lại & Về trang chủ
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.appTitle)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ErrorView(
                  message: errorMessage!,
                  onRetry: onRetry ?? () {},
                  retryLabel: s.retry,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onBackToHome ?? () => _resetToHome(context),
                    icon: const Icon(Icons.home),
                    label: Text(s.backToHome),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Trạng thái Rỗng (Empty) kèm 2 lối ra: Thử lại & Về trang chủ
    if (isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(s.appTitle)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EmptyView(
                  message: s.emptyBody,
                  actionLabel: s.retry,
                  onAction: onRetry,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onBackToHome ?? () => _resetToHome(context),
                    icon: const Icon(Icons.home),
                    label: Text(s.backToHome),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Trạng thái chuẩn: 4 nút lớn >= 48dp + nút Cài đặt
    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.appTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(s.homeSubtitle),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Nút 1: Luyện tập (>= 48dp)
              _MenuButton(
                icon: Icons.sports_esports,
                label: s.practice,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PracticeScreen()),
                ),
              ),
              // Nút 2: Thi thử (>= 48dp)
              _MenuButton(
                icon: Icons.timer,
                label: s.exam,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExamScreen()),
                ),
              ),
              // Nút 3: Làm lại câu sai (>= 48dp)
              _MenuButton(
                icon: Icons.replay,
                label: s.wrongRetry,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WrongRetryScreen()),
                ),
              ),
              // Nút 4: Thống kê (>= 48dp)
              _MenuButton(
                icon: Icons.bar_chart,
                label: s.stats,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
              ),
              const SizedBox(height: 8),
              // Nút Cài đặt (>= 48dp)
              _MenuButton(
                icon: Icons.settings,
                label: s.settings,
                isSecondary: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetToHome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

/// Nút menu to, chiều cao tối thiểu 56dp (>= 48dp) theo tiêu chuẩn accessibility.
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSecondary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 56,
        child: isSecondary
            ? OutlinedButton.icon(
                onPressed: onTap,
                icon: Icon(icon),
                label: Text(label),
              )
            : ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(icon),
                label: Text(label),
              ),
      ),
    );
  }
}
