/// Thẻ hiển thị một câu hỏi + đáp án (UI dùng ở TV2).
library;

import 'package:bilingual_quiz_app/data/models/question.dart';
import 'package:bilingual_quiz_app/ui/widgets/option_tile.dart';
import 'package:flutter/material.dart';

/// Card câu hỏi: tiêu đề, code minh họa, 4 đáp án. TV1 chỉ dựng khung.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.lang,
    this.selected,
    this.onSelect,
    this.revealAnswer = false,
  });

  final Question question;

  /// 'vi' hoặc 'en'.
  final String lang;

  /// Đáp án đang chọn ('A'..'D').
  final String? selected;
  final ValueChanged<String>? onSelect;

  /// true = tô xanh/đỏ đáp án sau khi nộp bài.
  final bool revealAnswer;

  @override
  Widget build(BuildContext context) {
    // TODO(tv2): hoàn thiện chấm màu đáp án + giải thích (quiz_ui_v2).
    final keys = ['A', 'B', 'C', 'D'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Câu ${question.number} · ${question.codeId}', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(question.prompt(lang), style: Theme.of(context).textTheme.titleMedium),
            for (final k in keys)
              OptionTile(
                label: k,
                text: question.options[k] ?? '',
                selected: selected == k,
                onTap: onSelect == null ? null : () => onSelect!(k),
              ),
          ],
        ),
      ),
    );
  }
}
