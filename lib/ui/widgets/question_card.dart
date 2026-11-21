/// Thẻ hiển thị câu hỏi trắc nghiệm song ngữ, code monospace giữ nguyên thụt lề, và giải thích chi tiết.
library;

import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/ui/widgets/option_tile.dart';
import 'package:material_ui/material_ui.dart';

/// Card câu hỏi: tiêu đề song ngữ, mã câu, mức độ, khối code monospace thụt lề chuẩn,
/// 4 đáp án OptionTile (>= 48dp), giải thích tức thì (vi/en/source) và nút chuyển câu.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.lang,
    this.selected,
    this.onSelect,
    this.revealAnswer = false,
    this.onNext,
    this.nextLabel,
  });

  /// Dữ liệu câu hỏi.
  final Question question;

  /// Ngôn ngữ hiển thị (vi / en / both).
  final AppLang lang;

  /// Đáp án người dùng đang chọn ('A'..'D').
  final String? selected;

  /// Callback khi người dùng chọn một đáp án.
  final ValueChanged<String>? onSelect;

  /// true nếu đã trả lời xong và cần mở khóa đáp án đúng/sai + giải thích.
  final bool revealAnswer;

  /// Callback khi bấm nút Câu tiếp theo / Nộp bài.
  final VoidCallback? onNext;

  /// Nhãn tùy biến cho nút hành động kế tiếp.
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final keys = const ['A', 'B', 'C', 'D'];
    final isBilingual = lang == AppLang.both;

    // Màu huy hiệu mức độ câu hỏi
    Color levelColor;
    String levelDisplay;
    switch (question.level) {
      case 'apply':
        levelColor = Colors.purple.shade700;
        levelDisplay = isBilingual ? 'Vận dụng / Apply' : (lang == AppLang.en ? 'Apply' : 'Vận dụng');
        break;
      case 'understand':
        levelColor = Colors.orange.shade800;
        levelDisplay = isBilingual ? 'Hiểu / Understand' : (lang == AppLang.en ? 'Understand' : 'Hiểu');
        break;
      case 'remember':
      default:
        levelColor = Colors.blue.shade700;
        levelDisplay = isBilingual ? 'Nhớ / Remember' : (lang == AppLang.en ? 'Remember' : 'Nhớ');
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thanh tiêu đề: Mã câu (K01-001), số câu, và Mức độ
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.codeId,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Câu ${question.number}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: levelColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    levelDisplay,
                    style: TextStyle(
                      color: levelColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Nội dung đề bài theo ngôn ngữ (vi / en / song ngữ)
            if (lang == AppLang.vi) ...[
              Text(
                question.viQuestion,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
              ),
            ] else if (lang == AppLang.en) ...[
              Text(
                question.enQuestion,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
              ),
            ] else ...[
              Text(
                question.viQuestion,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                question.enQuestion,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.blueGrey.shade800,
                      height: 1.3,
                    ),
              ),
            ],

            // 3. Khối code minh họa: widget Monospace giữ nguyên thụt lề
            if (question.code != null && question.code!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    question.code!,
                    softWrap: true,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFFD4D4D4),
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // 4. Bốn ô lựa chọn đáp án A/B/C/D (chiều cao >= 48dp)
            for (final k in keys)
              OptionTile(
                label: k,
                text: question.optionText(k, lang == AppLang.en ? 'en' : 'vi'),
                textEn: question.optionsEn[k],
                isBilingual: isBilingual,
                selected: selected == k,
                isCorrect: question.isCorrect(k),
                isAnswered: revealAnswer,
                onTap: (revealAnswer || onSelect == null) ? null : () => onSelect!(k),
              ),

            // 5. Khối giải thích chi tiết (xuất hiện ngay sau khi chọn đáp án)
            if (revealAnswer) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isBilingual
                              ? 'Giải thích / Explanation'
                              : (lang == AppLang.en ? 'Explanation' : 'Giải thích'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Giải thích tiếng Việt
                    if (question.explanationVi.isNotEmpty && lang != AppLang.en) ...[
                      Text(
                        question.explanationVi,
                        style: const TextStyle(fontSize: 14, height: 1.35),
                      ),
                    ],
                    // Giải thích tiếng Anh
                    if (question.explanationEn.isNotEmpty && (lang == AppLang.en || isBilingual)) ...[
                      if (question.explanationVi.isNotEmpty && isBilingual) const SizedBox(height: 6),
                      Text(
                        question.explanationEn,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontStyle: isBilingual ? FontStyle.italic : FontStyle.normal,
                          color: Colors.blueGrey.shade800,
                          height: 1.35,
                        ),
                      ),
                    ],
                    // Nguồn tài liệu tham khảo
                    if (question.source.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.link, size: 16, color: Colors.blue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: SelectableText(
                              question.source,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 6. Nút "Câu tiếp theo" / "Nộp bài" (chiều cao >= 48dp)
              if (onNext != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      nextLabel ?? (isBilingual ? 'Câu tiếp theo / Next' : 'Câu tiếp theo'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
