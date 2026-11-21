/// Màn hình Kết quả (khung Scaffold chuẩn TV2, nội dung chi tiết bổ sung ở prompt 2.4).
library;

import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

/// Màn hình hiển thị kết quả sau khi nộp bài thi / luyện tập.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, this.result});

  /// Kết quả bài thi / luyện tập truyền vào.
  final QuizResult? result;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.score),
        leading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: result == null
                ? EmptyView(
                    message: s.emptyBody,
                    actionLabel: s.backToHome,
                    onAction: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  )
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${s.score}: ${result!.score10.toStringAsFixed(1)} / 10',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${s.correct}: ${result!.correct} / ${result!.total}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              icon: const Icon(Icons.home),
                              label: Text(s.backToHome),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
