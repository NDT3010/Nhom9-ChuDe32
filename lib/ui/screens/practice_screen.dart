/// Màn hình Luyện tập: Làm từng câu một, chấm tức thì, giải thích song ngữ, lưu câu sai.
library;

import 'package:bilingual_quiz_app/data/datasources/local_store.dart';
import 'package:bilingual_quiz_app/data/datasources/question_local_datasource.dart';
import 'package:bilingual_quiz_app/data/repositories/history_repository_impl.dart';
import 'package:bilingual_quiz_app/data/repositories/question_repository_impl.dart';
import 'package:bilingual_quiz_app/data/repositories/wrong_repository_impl.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/practice_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/result_screen.dart';
import 'package:bilingual_quiz_app/ui/widgets/question_card.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Màn hình Luyện tập câu hỏi: làm từng câu, có giải thích song ngữ tức thì,
/// lưu câu sai vào WrongRepository, nút Làm lại từ đầu & Thoát có AlertDialog.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    this.block,
    this.count = 15,
    this.provider,
  });

  /// Khối câu hỏi được lọc (1..20), null = tất cả.
  final int? block;

  /// Số lượng câu hỏi muốn luyện tập.
  final int count;

  /// Provider được truyền vào (dùng khi kiểm thử hoặc DI).
  final PracticeProvider? provider;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late PracticeProvider _provider;
  bool _isInternalProvider = false;

  @override
  void initState() {
    super.initState();
    if (widget.provider != null) {
      _provider = widget.provider!;
    } else {
      const store = LocalStore();
      _provider = PracticeProvider(
        questionRepository: const QuestionRepositoryImpl(QuestionLocalDatasource()),
        historyRepository: const HistoryRepositoryImpl(store),
        wrongRepository: const WrongRepositoryImpl(store),
      );
      _isInternalProvider = true;
    }

    // Tải danh sách câu hỏi sau khi khung hình dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadQuestions(
        block: widget.block,
        count: widget.count,
      );
    });
  }

  @override
  void dispose() {
    if (_isInternalProvider) {
      _provider.dispose();
    }
    super.dispose();
  }

  Future<void> _handleExit(BuildContext context) async {
    if (_provider.userAnswers.isEmpty || _provider.isSubmitted) {
      Navigator.of(context).pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận thoát?'),
        content: const Text(
          'Bạn đang làm dở bài luyện tập. Tiến độ hiện tại chưa được lưu hoàn tất. Bạn có chắc muốn thoát?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ở lại làm tiếp'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleRestart(BuildContext context) async {
    if (_provider.userAnswers.isEmpty) {
      _provider.loadQuestions(block: widget.block, count: widget.count);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Làm lại từ đầu?'),
        content: const Text(
          'Toàn bộ câu trả lời của bài luyện tập này sẽ bị xóa. Bạn có chắc muốn bắt đầu lại?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Làm lại'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _provider.loadQuestions(block: widget.block, count: widget.count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);
    final lang = context.watch<LanguageProvider>().language;
    final isBilingual = lang == AppLang.both;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleExit(context);
      },
      child: AnimatedBuilder(
        animation: _provider,
        builder: (context, _) {
          final total = _provider.totalQuestions;
          final currentIdx = _provider.currentIndex;
          final currentQ = _provider.currentQuestion;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                total > 0
                    ? (isBilingual
                        ? 'Luyện tập · Câu ${currentIdx + 1}/$total'
                        : 'Luyện tập · Câu ${currentIdx + 1}/$total')
                    : s.practice,
              ),
              leading: BackButton(
                onPressed: () => _handleExit(context),
              ),
              actions: [
                // Nút Làm lại từ đầu (hỏi xác nhận nếu đang làm dở)
                IconButton(
                  tooltip: 'Làm lại từ đầu',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _handleRestart(context),
                ),
                // Nút Thoát (hỏi xác nhận nếu đang làm dở)
                IconButton(
                  tooltip: 'Thoát',
                  icon: const Icon(Icons.close),
                  onPressed: () => _handleExit(context),
                ),
              ],
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _buildBody(context, s, lang, isBilingual, total, currentIdx, currentQ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppStrings s,
    AppLang lang,
    bool isBilingual,
    int total,
    int currentIdx,
    dynamic currentQ,
  ) {
    // Trạng thái 1: Đang nạp câu hỏi
    if (_provider.isLoading) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingView(message: s.loading),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home),
                  label: Text(s.backToHome),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Trạng thái 2: Lỗi tải dữ liệu JSON
    if (_provider.hasError) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorView(
                message: _provider.errorMessage!,
                onRetry: () => _provider.loadQuestions(
                  block: widget.block,
                  count: widget.count,
                ),
                retryLabel: s.retry,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home),
                  label: Text(s.backToHome),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Trạng thái 3: Không có câu hỏi nào (Empty)
    if (_provider.isEmpty || currentQ == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmptyView(
                message: isBilingual
                    ? 'Không tìm thấy câu hỏi phù hợp trong khối đã chọn.'
                    : 'Không tìm thấy câu hỏi phù hợp.',
                actionLabel: isBilingual ? 'Chọn khối khác / Back' : 'Chọn khối khác',
                onAction: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home),
                  label: Text(s.backToHome),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Trạng thái 4: Hiển thị câu hỏi làm từng câu một
    final selectedChoice = _provider.selectedAnswerFor(currentQ.number);
    final isAnswered = selectedChoice != null;
    final isLast = currentIdx >= total - 1;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Thanh tiến độ làm bài
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? (currentIdx + 1) / total : 0,
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${currentIdx + 1}/$total',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Thẻ câu hỏi + các lựa chọn + giải thích chi tiết
        QuestionCard(
          question: currentQ,
          lang: lang,
          selected: selectedChoice,
          revealAnswer: isAnswered,
          onSelect: (choice) => _provider.selectAnswer(currentQ.number, choice),
          nextLabel: isLast
              ? (isBilingual ? 'Xem kết quả / Finish' : 'Xem kết quả')
              : (isBilingual ? 'Câu tiếp theo / Next' : 'Câu tiếp theo'),
          onNext: isAnswered
              ? () async {
                  if (isLast) {
                    final res = await _provider.submitQuiz();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(result: res),
                        ),
                      );
                    }
                  } else {
                    _provider.nextQuestion();
                  }
                }
              : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
