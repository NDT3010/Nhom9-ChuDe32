/// Một dòng đáp án A/B/C/D đạt chuẩn tiếp cận accessibility và phản hồi đúng/sai.
library;

import 'package:material_ui/material_ui.dart';

/// Tile đáp án trắc nghiệm: chiều cao tối thiểu 48dp, có semantics, tô màu đúng/sai, hỗ trợ song ngữ.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.text,
    this.textEn,
    this.isBilingual = false,
    this.selected = false,
    this.isCorrect = false,
    this.isAnswered = false,
    this.onTap,
  });

  /// Ký tự nhãn đáp án: 'A', 'B', 'C', hoặc 'D'.
  final String label;

  /// Nội dung đáp án (tiếng Việt hoặc ngôn ngữ đang chọn).
  final String text;

  /// Bản dịch tiếng Anh của đáp án (dùng khi ở chế độ song ngữ).
  final String? textEn;

  /// Cờ bật hiển thị bản dịch tiếng Anh bên dưới.
  final bool isBilingual;

  /// true nếu người dùng đang chọn đáp án này.
  final bool selected;

  /// true nếu đây là đáp án chính xác của câu hỏi.
  final bool isCorrect;

  /// true nếu câu hỏi đã được trả lời (để hiển thị kết quả đúng/sai).
  final bool isAnswered;

  /// Callback khi người dùng chạm vào ô đáp án.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 1. Xác định màu sắc viền và nền theo trạng thái
    Color borderColor;
    Color? backgroundColor;
    Color avatarColor;
    Color avatarTextColor;
    Widget? trailingIcon;

    if (isAnswered) {
      if (isCorrect) {
        // Đáp án đúng -> Tô xanh lá cây
        borderColor = const Color(0xFF2E7D32);
        backgroundColor = const Color(0xFFE8F5E9);
        avatarColor = const Color(0xFF2E7D32);
        avatarTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.check_circle,
          color: Color(0xFF2E7D32),
          size: 24,
        );
      } else if (selected) {
        // Đã chọn nhưng sai -> Tô màu đỏ
        borderColor = const Color(0xFFC62828);
        backgroundColor = const Color(0xFFFFEBEE);
        avatarColor = const Color(0xFFC62828);
        avatarTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.cancel,
          color: Color(0xFFC62828),
          size: 24,
        );
      } else {
        // Các lựa chọn còn lại mờ đi
        borderColor = Colors.grey.shade300;
        backgroundColor = null;
        avatarColor = Colors.grey.shade200;
        avatarTextColor = Colors.grey.shade700;
      }
    } else {
      if (selected) {
        borderColor = Theme.of(context).colorScheme.primary;
        backgroundColor = Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.35);
        avatarColor = Theme.of(context).colorScheme.primary;
        avatarTextColor = Colors.white;
      } else {
        borderColor = Colors.grey.shade300;
        backgroundColor = null;
        avatarColor = Colors.grey.shade100;
        avatarTextColor = Colors.black87;
      }
    }

    // 2. Chuẩn bị Semantics Label cho trình đọc màn hình (Screen Reader / a11y)
    final semanticBuffer = StringBuffer('Lựa chọn $label: $text');
    final hasEnglish = isBilingual &&
        textEn != null &&
        textEn!.trim().isNotEmpty &&
        textEn != text;
    if (hasEnglish) {
      semanticBuffer.write(', Tiếng Anh: $textEn');
    }
    if (isAnswered) {
      if (isCorrect) {
        semanticBuffer.write(', Đáp án chính xác');
      } else if (selected) {
        semanticBuffer.write(', Lựa chọn của bạn là sai');
      }
    }

    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: selected,
      label: semanticBuffer.toString(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: backgroundColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: avatarColor,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: avatarTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (hasEnglish) ...[
                        const SizedBox(height: 3),
                        Text(
                          textEn!,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.blueGrey.shade700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  trailingIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
