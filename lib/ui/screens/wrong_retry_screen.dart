/// Màn hình Làm lại câu sai (khung Scaffold chuẩn TV2, nội dung chi tiết bổ sung ở prompt 2.4).
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

/// Màn hình ôn tập các câu hỏi đã làm sai trong lịch sử.
class WrongRetryScreen extends StatelessWidget {
  const WrongRetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.wrongRetry),
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
                // TODO(tv2-prompt-2.4): điều hướng sang luyện tập hoặc tải lại câu sai
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
