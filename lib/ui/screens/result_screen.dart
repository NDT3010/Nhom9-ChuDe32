/// Màn hình Kết quả: điểm số, danh sách câu sai, nút làm lại / về nhà.
library;

import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/data/models/quiz_result.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/wrong_retry_screen.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Màn hình hiển thị kết quả sau khi nộp bài thi / luyện tập.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, this.result, this.questions = const []});

  /// Kết quả bài thi truyền vào.
  final QuizResult? result;

  /// Danh sách câu hỏi đã làm (để tra cứu câu sai).
  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(s.score),
          leading: BackButton(
              onPressed: () => Navigator.of(context).maybePop()),
        ),
        body: EmptyView(
          message: s.emptyBody,
          actionLabel: s.backToHome,
          onAction: () =>
              Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      );
    }

    final res = result!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(s.score),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Thẻ tổng kết ─────────────────────────────────────────
              _SummaryCard(result: res, strings: s),
              const SizedBox(height: 20),

              // ── Danh sách câu sai ─────────────────────────────────────
              if (res.wrongNumbers.isNotEmpty) ...[
                Text(
                  'Câu trả lời sai (${res.wrongNumbers.length} câu)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...res.wrongNumbers.map((qNum) {
                  final q = questions.where((q) => q.number == qNum).firstOrNull;
                  return _WrongQuestionTile(
                    questionNumber: qNum,
                    question: q,
                    lang: context.watch<LanguageProvider>().language,
                  );
                }),
                const SizedBox(height: 20),
              ],

              // ── Nút Làm lại câu sai ───────────────────────────────────
              if (res.wrongNumbers.isNotEmpty)
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WrongRetryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay),
                    label: Text(s.wrongRetry),
                  ),
                ),
              const SizedBox(height: 12),

              // ── Nút Về trang chủ ──────────────────────────────────────
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
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
}

// ════════════════════════════════════════════════════════════════════════════
//  Thẻ tóm tắt điểm số
// ════════════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result, required this.strings});

  final QuizResult result;
  final AppStrings strings;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = result.total == 0
        ? 0.0
        : result.correct / result.total;
    final scoreColor = result.score10 >= 5
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Biểu tượng
            Icon(
              result.score10 >= 5
                  ? Icons.emoji_events_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              size: 72,
              color: scoreColor,
            ),
            const SizedBox(height: 12),

            // Điểm
            Text(
              '${result.score10.toStringAsFixed(1)} / 10',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 4),

            // % đúng
            Text(
              '${(pct * 100).round()}% chính xác',
              style: theme.textTheme.titleMedium,
            ),
            const Divider(height: 24),

            // Bảng thống kê
            _StatRow(
              label: strings.correct,
              value: '${result.correct}',
              color: Colors.green.shade700,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: strings.incorrect,
              value: '${result.total - result.correct}',
              color: Colors.red.shade700,
              icon: Icons.cancel_outlined,
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: 'Tổng câu',
              value: '${result.total}',
              icon: Icons.quiz_outlined,
            ),
            if (result.durationSeconds > 0) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Thời gian làm bài',
                value: _formatDuration(result.durationSeconds),
                icon: Icons.timer_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Tile hiển thị câu sai
// ════════════════════════════════════════════════════════════════════════════

class _WrongQuestionTile extends StatelessWidget {
  const _WrongQuestionTile({
    required this.questionNumber,
    required this.question,
    required this.lang,
  });

  final int questionNumber;
  final Question? question;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return ListTile(
        leading: const Icon(Icons.close, color: Colors.red),
        title: Text('Câu $questionNumber (không tìm thấy chi tiết)'),
      );
    }

    final q = question!;
    final isBilingual = lang == AppLang.both;
    final promptText = isBilingual
        ? '${q.viQuestion}\n${q.enQuestion}'
        : (lang == AppLang.en ? q.enQuestion : q.viQuestion);
    final correctText = q.options[q.answer] ?? q.answer;
    final explVi = q.explanationVi;
    final explEn = q.explanationEn;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã câu + câu hỏi
            Row(
              children: [
                Chip(
                  label: Text(q.codeId,
                      style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.red.shade100,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Khối ${q.block}',
                      style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(promptText,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),

            // Đáp án đúng
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đáp án đúng (${q.answer}): $correctText',
                      style:
                          const TextStyle(color: Colors.green, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Giải thích
            if (explVi.isNotEmpty || explEn.isNotEmpty) ...[
              const SizedBox(height: 8),
              if (explVi.isNotEmpty)
                Text('📌 $explVi',
                    style: const TextStyle(fontSize: 13, height: 1.4)),
              if (isBilingual && explEn.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('📌 $explEn',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4)),
              ],
            ],

            // Link nguồn
            if (q.source.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '🔗 ${q.source}',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
