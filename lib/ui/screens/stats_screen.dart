/// Màn hình Thống kê (khung Scaffold chuẩn TV2, nội dung chi tiết bổ sung ở prompt 3.1-3.2).
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

/// Màn hình Thống kê kết quả học tập và tiến độ.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.stats),
        leading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: EmptyView(
              message: s.emptyHistory,
              actionLabel: s.practice,
              onAction: () {
                // TODO(tv2-prompt-3.1): đọc lịch sử từ StatsService và vẽ biểu đồ
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
