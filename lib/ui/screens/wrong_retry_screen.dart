/// Màn hình Làm lại câu sai: đọc danh sách mã câu sai từ máy, nạp câu tương ứng,
/// hiển thị từng câu theo kiểu Luyện tập (QuestionCard + OptionTile).
///
/// Luồng:
///   Loading → đọc WrongRepository + QuestionRepository
///   Empty   → không có câu sai (chúc mừng)
///   Error   → hiện thông báo + nút Thử lại
///   Quiz    → làm từng câu, đúng → xóa khỏi danh sách, sai → giữ lại + giải thích
library;

import 'package:bilingual_quiz_app/data/datasources/local_store.dart';
import 'package:bilingual_quiz_app/data/datasources/question_local_datasource.dart';
import 'package:bilingual_quiz_app/data/repositories/history_repository_impl.dart';
import 'package:bilingual_quiz_app/data/repositories/question_repository_impl.dart';
import 'package:bilingual_quiz_app/data/repositories/wrong_repository_impl.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/wrong_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/practice_setup_screen.dart';
import 'package:bilingual_quiz_app/ui/widgets/question_card.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Màn hình ôn tập các câu hỏi đã làm sai trong lịch sử.
class WrongRetryScreen extends StatefulWidget {
  const WrongRetryScreen({super.key, this.provider});

  /// Provider được inject (dùng khi test hoặc DI).
  final WrongProvider? provider;

  @override
  State<WrongRetryScreen> createState() => _WrongRetryScreenState();
}

class _WrongRetryScreenState extends State<WrongRetryScreen> {
  late final WrongProvider _provider;
  bool _isInternalProvider = false;

  @override
  void initState() {
    super.initState();
    if (widget.provider != null) {
      _provider = widget.provider!;
    } else {
      _isInternalProvider = true;
      _provider = WrongProvider(
        questionRepository:
            QuestionRepositoryImpl(const QuestionLocalDatasource()),
        historyRepository: HistoryRepositoryImpl(const LocalStore()),
      );
    }
    // Nạp câu sai ngay sau khi build hoàn tất — KHÔNG gọi trong build()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _provider.loadWrongQuestions();
    });
  }

  @override
  void dispose() {
    if (_isInternalProvider) _provider.dispose();
    super.dispose();
  }

  // ── Xác nhận xóa toàn bộ câu sai ─────────────────────────────────────────
  Future<void> _confirmClearAll(BuildContext ctx) async {
    final s = AppStringsScope.of(ctx);
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Xóa toàn bộ câu sai?'),
        content: Text(s.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final wrongRepo = WrongRepositoryImpl(const LocalStore());
      await wrongRepo.clear();
      if (ctx.mounted) _provider.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    return ListenableBuilder(
      listenable: _provider,
      builder: (ctx, _) {
        // ── Loading ────────────────────────────────────────────────────────
        if (_provider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(s.wrongRetry)),
            body: const LoadingView(message: 'Đang tải danh sách câu sai…'),
          );
        }

        // ── Error ──────────────────────────────────────────────────────────
        if (_provider.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(s.wrongRetry),
              leading: BackButton(
                  onPressed: () => Navigator.of(ctx).maybePop()),
            ),
            body: ErrorView(
              message: _provider.errorMessage ?? s.errorBody,
              retryLabel: s.retry,
              onRetry: _provider.loadWrongQuestions,
            ),
          );
        }

        // ── Empty: không còn câu sai nào ──────────────────────────────────
        if (_provider.isEmpty) {
          return _EmptyCongratulationsScreen(onRetry: _provider.loadWrongQuestions);
        }

        // ── Màn hình làm bài ───────────────────────────────────────────────
        return _WrongQuizView(
          provider: _provider,
          onClearAll: () => _confirmClearAll(ctx),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Màn hình chúc mừng khi hết câu sai
// ════════════════════════════════════════════════════════════════════════════

class _EmptyCongratulationsScreen extends StatelessWidget {
  const _EmptyCongratulationsScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.wrongRetry),
        leading: BackButton(
            onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text(
                  'Tuyệt vời!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã làm đúng tất cả các câu sai.\nHãy tiếp tục luyện tập để củng cố thêm!',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Nút Luyện tập thêm
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const PracticeSetupScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.school),
                    label: const Text('Luyện tập thêm'),
                  ),
                ),
                const SizedBox(height: 12),

                // Nút Về trang chủ
                SizedBox(
                  width: double.infinity,
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
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Màn hình làm bài câu sai
// ════════════════════════════════════════════════════════════════════════════

class _WrongQuizView extends StatelessWidget {
  const _WrongQuizView({
    required this.provider,
    required this.onClearAll,
  });

  final WrongProvider provider;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);
    final lang = context.watch<LanguageProvider>().language;
    final q = provider.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.wrongRetry),
        leading: BackButton(
            onPressed: () => Navigator.of(context).maybePop()),
        actions: [
          // Nút xóa toàn bộ câu sai (có xác nhận)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Xóa toàn bộ câu sai',
            onPressed: onClearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Thanh tiến trình ────────────────────────────────────────────
          LinearProgressIndicator(
            value: provider.totalQuestions == 0
                ? 0
                : (provider.currentIndex + 1) / provider.totalQuestions,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${s.question} ${provider.currentIndex + 1} ${s.of} ${provider.totalQuestions}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  'Còn lại: ${provider.totalQuestions - provider.currentIndex} câu',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),

          // ── Câu hỏi ─────────────────────────────────────────────────────
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: q == null
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _WrongQuestionWrapper(
                          key: ValueKey(q.number),
                          question: q,
                          lang: lang,
                          provider: provider,
                          strings: s,
                        ),
                      ),
              ),
            ),
          ),

          // ── Điều hướng Trước / Sau ─────────────────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: provider.currentIndex > 0
                          ? provider.previousQuestion
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Trước'),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          provider.currentIndex < provider.totalQuestions - 1
                              ? provider.nextQuestion
                              : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(s.next),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Wrapper câu hỏi — xử lý logic xóa câu khi trả lời đúng
// ════════════════════════════════════════════════════════════════════════════

class _WrongQuestionWrapper extends StatefulWidget {
  const _WrongQuestionWrapper({
    super.key,
    required this.question,
    required this.lang,
    required this.provider,
    required this.strings,
  });

  final dynamic question; // Question
  final AppLang lang;
  final WrongProvider provider;
  final AppStrings strings;

  @override
  State<_WrongQuestionWrapper> createState() => _WrongQuestionWrapperState();
}

class _WrongQuestionWrapperState extends State<_WrongQuestionWrapper> {
  String? _selected;
  bool _revealed = false;
  bool _removedFromWrong = false;

  Future<void> _onSelect(String choice) async {
    if (_revealed) return;
    setState(() {
      _selected = choice;
      _revealed = true;
    });

    final q = widget.question;
    final isCorrect = q.isCorrect(choice);

    // Cập nhật WrongRepository ngay tức thì
    final wrongRepo = WrongRepositoryImpl(const LocalStore());
    if (isCorrect && !_removedFromWrong) {
      _removedFromWrong = true;
      await wrongRepo.removeWrongQuestion(q.number, codeId: q.codeId);
    } else if (!isCorrect) {
      // Vẫn giữ lại — đảm bảo có trong danh sách
      await wrongRepo.addWrongQuestion(q.number, codeId: q.codeId);
    }
  }

  void _onNext() {
    // Nếu đúng và còn câu → chuyển câu tiếp; nếu là câu cuối → reload
    if (widget.provider.currentIndex < widget.provider.totalQuestions - 1) {
      widget.provider.nextQuestion();
    } else {
      // Hết bộ → reload để loại bỏ câu đã đúng khỏi UI
      widget.provider.loadWrongQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: widget.question,
      lang: widget.lang,
      selected: _selected,
      revealAnswer: _revealed,
      onSelect: _revealed ? null : _onSelect,
      onNext: _revealed ? _onNext : null,
      nextLabel: widget.provider.currentIndex < widget.provider.totalQuestions - 1
          ? widget.strings.next
          : 'Cập nhật danh sách',
    );
  }
}
