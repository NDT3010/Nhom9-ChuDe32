/// Màn hình Luyện tập (khung Scaffold chuẩn TV2, nội dung chi tiết bổ sung ở prompt 2.2).
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

/// Màn hình Luyện tập câu hỏi trắc nghiệm song ngữ.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.practice),
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
              message: s.emptyBody,
              actionLabel: s.start,
              onAction: () {
                // TODO(tv2-prompt-2.2): khởi tạo bài luyện tập từ PracticeProvider
              },
            ),
          ),
        ),
      ),
    );
  }
}
