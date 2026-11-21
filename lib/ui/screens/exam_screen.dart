/// Màn hình Thi thử (khung Scaffold chuẩn TV2, nội dung chi tiết bổ sung ở prompt 2.3).
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

/// Màn hình Thi thử có đếm ngược thời gian.
class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.exam),
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
                // TODO(tv2-prompt-2.3): bắt đầu ca thi đếm giờ từ ExamProvider
              },
            ),
          ),
        ),
      ),
    );
  }
}
