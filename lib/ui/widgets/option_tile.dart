/// Một dòng đáp án A/B/C/D (UI dùng ở TV2).
library;

import 'package:material_ui/material_ui.dart';

/// Tile đáp án, chiều cao tối thiểu 48dp để dễ bấm trên điện thoại.
class OptionTile extends StatelessWidget {
  const OptionTile({super.key, required this.label, required this.text, this.selected = false, this.onTap});

  /// Ký tự đáp án: A/B/C/D.
  final String label;

  /// Nội dung đáp án.
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // TODO(tv2): thêm trạng thái đúng/sai (màu xanh/đỏ) sau khi nộp bài.
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: selected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35) : null,
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 14, child: Text(label)),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
