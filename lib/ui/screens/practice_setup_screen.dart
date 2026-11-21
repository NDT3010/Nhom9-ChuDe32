/// Màn hình Cài đặt cấu hình Luyện tập: Chọn khối kiến thức (1..20) và số lượng câu hỏi (10/20/30/50).
library;

import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/practice_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Cấu trúc thông tin của một khối kiến thức trong 20 khối.
class PracticeBlockItem {
  const PracticeBlockItem({
    required this.number,
    required this.titleVi,
    required this.titleEn,
    required this.count,
  });

  final int number;
  final String titleVi;
  final String titleEn;
  final int count;

  String title(AppLang lang) => lang == AppLang.en
      ? titleEn
      : (lang == AppLang.both ? '$titleVi / $titleEn' : titleVi);
}

/// Màn hình chọn khối câu hỏi và số lượng câu luyện tập.
class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({super.key});

  /// Danh sách 20 khối kiến thức chuẩn trích từ flutter_300_questions.json.
  static const List<PracticeBlockItem> allBlocks = [
    PracticeBlockItem(number: 1, titleVi: 'Ngôn ngữ Dart', titleEn: 'The Dart language', count: 20),
    PracticeBlockItem(number: 2, titleVi: 'Môi trường và công cụ', titleEn: 'Environment and tools', count: 22),
    PracticeBlockItem(number: 3, titleVi: 'Cách Flutter hoạt động', titleEn: 'How Flutter works', count: 18),
    PracticeBlockItem(number: 4, titleVi: 'Bố cục và cuộn', titleEn: 'Layout and scrolling', count: 20),
    PracticeBlockItem(number: 5, titleVi: 'Thiết kế và giao diện chung', titleEn: 'Design and theming', count: 15),
    PracticeBlockItem(number: 6, titleVi: 'Thích ứng và co giãn', titleEn: 'Adaptive and responsive design', count: 15),
    PracticeBlockItem(number: 7, titleVi: 'Tương tác và biểu mẫu', titleEn: 'Interactivity and forms', count: 15),
    PracticeBlockItem(number: 8, titleVi: 'Tài nguyên và đa phương tiện', titleEn: 'Assets and media', count: 10),
    PracticeBlockItem(number: 9, titleVi: 'Điều hướng', titleEn: 'Navigation and routing', count: 15),
    PracticeBlockItem(number: 10, titleVi: 'Hoạt ảnh', titleEn: 'Animations', count: 15),
    PracticeBlockItem(number: 11, titleVi: 'Trợ năng và đa ngôn ngữ', titleEn: 'Accessibility and internationalization', count: 10),
    PracticeBlockItem(number: 12, titleVi: 'Quản lý trạng thái', titleEn: 'State management', count: 20),
    PracticeBlockItem(number: 13, titleVi: 'Dữ liệu và backend', titleEn: 'Data and backend', count: 15),
    PracticeBlockItem(number: 14, titleVi: 'Kiến trúc ứng dụng', titleEn: 'App architecture', count: 15),
    PracticeBlockItem(number: 15, titleVi: 'Gói và plugin', titleEn: 'Packages and plugins', count: 15),
    PracticeBlockItem(number: 16, titleVi: 'Kiểm thử và gỡ lỗi', titleEn: 'Testing and debugging', count: 15),
    PracticeBlockItem(number: 17, titleVi: 'Hiệu năng', titleEn: 'Performance', count: 15),
    PracticeBlockItem(number: 18, titleVi: 'Tích hợp nền tảng và mã gốc', titleEn: 'Platform integration and native interop', count: 10),
    PracticeBlockItem(number: 19, titleVi: 'Triển khai', titleEn: 'Deployment', count: 10),
    PracticeBlockItem(number: 20, titleVi: 'AI trong Flutter', titleEn: 'AI in Flutter', count: 10),
  ];

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  int? _selectedBlock;
  int _selectedCount = 10;
  final List<int> _countOptions = const [10, 20, 30, 50];

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);
    final lang = context.watch<LanguageProvider>().language;
    final isBilingual = lang == AppLang.both;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBilingual ? 'Thiết lập luyện tập / Practice Setup' : s.practice),
        leading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Header Card giới thiệu
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.tune,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBilingual ? 'Tuỳ chỉnh bài luyện tập' : 'Thiết lập luyện tập',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isBilingual
                                  ? 'Chọn khối chủ đề và số lượng câu hỏi phù hợp'
                                  : 'Chọn khối chủ đề trong 20 khối và số câu mong muốn',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 1. Chọn số câu hỏi: 10 / 20 / 30 / 50
              Text(
                isBilingual ? 'Số câu hỏi / Number of questions' : 'Số câu hỏi',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _countOptions.map((count) {
                  final isSelected = _selectedCount == count;
                  return ChoiceChip(
                    label: Text(
                      '$count câu',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCount = count);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 2. Chọn khối trong 20 khối kiến thức
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBilingual ? 'Khối kiến thức / Topic Blocks' : 'Khối kiến thức',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (_selectedBlock != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedBlock = null),
                      child: Text(isBilingual ? 'Chọn tất cả / All' : 'Chọn tất cả'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Mục chọn: Tất cả khối
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _selectedBlock == null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: _selectedBlock == null ? 2 : 1,
                  ),
                ),
                color: _selectedBlock == null
                    ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _selectedBlock == null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade200,
                    foregroundColor: _selectedBlock == null ? Colors.white : Colors.black87,
                    child: const Icon(Icons.all_inclusive, size: 20),
                  ),
                  title: Text(
                    isBilingual ? 'Tất cả các khối (Toàn bộ 300 câu)' : 'Tất cả các khối (300 câu)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isBilingual
                        ? 'Trộn ngẫu nhiên câu hỏi từ toàn bộ 20 khối'
                        : 'Câu hỏi ngẫu nhiên trong toàn bộ ngân hàng đề',
                  ),
                  trailing: _selectedBlock == null
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () => setState(() => _selectedBlock = null),
                ),
              ),

              // 20 khối danh sách
              for (final block in PracticeSetupScreen.allBlocks)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _selectedBlock == block.number
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: _selectedBlock == block.number ? 2 : 1,
                    ),
                  ),
                  color: _selectedBlock == block.number
                      ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _selectedBlock == block.number
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      foregroundColor: _selectedBlock == block.number ? Colors.white : Colors.black87,
                      child: Text(
                        'K${block.number.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      block.title(lang),
                      style: TextStyle(
                        fontWeight: _selectedBlock == block.number ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('${block.count} câu hỏi'),
                    trailing: _selectedBlock == block.number
                        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () => setState(() => _selectedBlock = block.number),
                  ),
                ),

              const SizedBox(height: 24),

              // 3. Nút bắt đầu luyện tập (chiều cao >= 48dp)
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(
                          block: _selectedBlock,
                          count: _selectedCount,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    isBilingual
                        ? 'Bắt đầu luyện tập / Start Practice'
                        : 'Bắt đầu luyện tập ($_selectedCount câu)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
