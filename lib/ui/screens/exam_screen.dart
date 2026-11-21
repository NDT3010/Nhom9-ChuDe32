/// Màn hình Thi thử: cấu hình → làm bài → kết quả.
///
/// Luồng: [_ExamConfigView] → [_ExamQuizView] → ResultScreen.
/// Timer tự động tạm dừng khi app vào nền, tiếp tục khi quay lại.
library;

import 'package:bilingual_quiz_app/data/datasources/local_store.dart';
import 'package:bilingual_quiz_app/data/datasources/question_local_datasource.dart';
import 'package:bilingual_quiz_app/data/repositories/history_repository_impl.dart';
import 'package:bilingual_quiz_app/data/repositories/question_repository_impl.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/providers/exam_provider.dart';
import 'package:bilingual_quiz_app/logic/providers/language_provider.dart';
import 'package:bilingual_quiz_app/ui/screens/result_screen.dart';
import 'package:bilingual_quiz_app/ui/widgets/question_card.dart';
import 'package:bilingual_quiz_app/ui/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Màn hình Thi thử có đếm ngược thời gian.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key, this.provider});

  /// Provider được inject (dùng cho test hoặc DI).
  final ExamProvider? provider;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  late final ExamProvider _provider;
  bool _isInternalProvider = false;
  bool _isConfiguring = true;

  // ── Cấu hình ca thi ──────────────────────────────────────────────────────
  int _selectedCount = 20;
  int _selectedMinutes = 15;
  int? _selectedBlock; // null = tất cả khối

  static const _countOptions = [10, 20, 30, 50];
  static const _minuteOptions = [10, 15, 30, 45];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.provider != null) {
      _provider = widget.provider!;
    } else {
      _isInternalProvider = true;
      _provider = ExamProvider(
        questionRepository:
            QuestionRepositoryImpl(const QuestionLocalDatasource()),
        historyRepository: HistoryRepositoryImpl(const LocalStore()),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInternalProvider) {
      _provider.dispose();
    }
    super.dispose();
  }

  /// Tạm dừng timer khi app bị ẩn xuống nền, tiếp tục khi quay lại.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isConfiguring && !_provider.isSubmitted) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        _provider.pause();
      } else if (state == AppLifecycleState.resumed) {
        _provider.resume();
      }
    }
  }

  // ── Khởi động bài thi ────────────────────────────────────────────────────
  Future<void> _startExam() async {
    setState(() => _isConfiguring = false);
    await _provider.startExam(
      count: _selectedCount,
      durationSeconds: _selectedMinutes * 60,
      block: _selectedBlock,
    );
  }

  // ── Nộp bài thủ công (có xác nhận) ──────────────────────────────────────
  Future<void> _confirmSubmit(BuildContext ctx) async {
    final s = AppStringsScope.of(ctx);
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(s.submit),
        content: const Text('Bạn chắc chắn muốn nộp bài? Vẫn còn thời gian!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tiếp tục làm'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.submit),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await _doSubmit(ctx);
    }
  }

  Future<void> _doSubmit(BuildContext ctx) async {
    final result = await _provider.submitExam();
    if (!ctx.mounted) return;
    Navigator.of(ctx).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
          questions: _provider.questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);

    return ListenableBuilder(
      listenable: _provider,
      builder: (ctx, _) {
        // Tự động chuyển sang ResultScreen khi hết giờ và đã nộp
        if (!_isConfiguring && _provider.isSubmitted && _provider.result != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  result: _provider.result!,
                  questions: _provider.questions,
                ),
              ),
            );
          });
        }

        if (_isConfiguring) {
          return _ExamConfigView(
            selectedCount: _selectedCount,
            selectedMinutes: _selectedMinutes,
            selectedBlock: _selectedBlock,
            countOptions: _countOptions,
            minuteOptions: _minuteOptions,
            onCountChanged: (v) => setState(() => _selectedCount = v),
            onMinutesChanged: (v) => setState(() => _selectedMinutes = v),
            onBlockChanged: (v) => setState(() => _selectedBlock = v),
            onStart: _startExam,
          );
        }

        // Trạng thái Loading
        if (_provider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(s.exam)),
            body: const LoadingView(message: 'Đang chuẩn bị đề thi…'),
          );
        }

        // Trạng thái Error
        if (_provider.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(s.exam)),
            body: ErrorView(
              message: _provider.errorMessage ?? s.errorBody,
              retryLabel: s.retry,
              onRetry: _startExam,
            ),
          );
        }

        // Trạng thái Empty
        if (_provider.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(s.exam)),
            body: EmptyView(
              message: 'Không có câu hỏi cho lựa chọn này.',
              actionLabel: s.backToHome,
              onAction: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          );
        }

        // Màn hình làm bài
        return _ExamQuizView(
          provider: _provider,
          onSubmit: () => _confirmSubmit(context),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Màn hình CẤU HÌNH ca thi
// ════════════════════════════════════════════════════════════════════════════

class _ExamConfigView extends StatelessWidget {
  const _ExamConfigView({
    required this.selectedCount,
    required this.selectedMinutes,
    required this.selectedBlock,
    required this.countOptions,
    required this.minuteOptions,
    required this.onCountChanged,
    required this.onMinutesChanged,
    required this.onBlockChanged,
    required this.onStart,
  });

  final int selectedCount;
  final int selectedMinutes;
  final int? selectedBlock;
  final List<int> countOptions;
  final List<int> minuteOptions;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int?> onBlockChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.exam),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ── Số câu ──────────────────────────────────────────────────
              Text('Số câu hỏi', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: countOptions.map((n) {
                  return ChoiceChip(
                    label: Text('$n câu'),
                    selected: selectedCount == n,
                    onSelected: (_) => onCountChanged(n),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Thời gian ───────────────────────────────────────────────
              Text('Thời gian (phút)', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: minuteOptions.map((m) {
                  return ChoiceChip(
                    label: Text('$m phút'),
                    selected: selectedMinutes == m,
                    onSelected: (_) => onMinutesChanged(m),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Khối kiến thức ──────────────────────────────────────────
              Text('Khối kiến thức', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả (300 câu)'),
                    selected: selectedBlock == null,
                    onSelected: (_) => onBlockChanged(null),
                  ),
                  ...List.generate(20, (i) => i + 1).map((b) {
                    return ChoiceChip(
                      label: Text('Khối $b'),
                      selected: selectedBlock == b,
                      onSelected: (_) => onBlockChanged(b),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 32),

              // ── Nút Bắt đầu ─────────────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(s.start,
                      style: const TextStyle(fontSize: 16)),
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
//  Màn hình LÀM BÀI
// ════════════════════════════════════════════════════════════════════════════

class _ExamQuizView extends StatefulWidget {
  const _ExamQuizView({required this.provider, required this.onSubmit});

  final ExamProvider provider;
  final VoidCallback onSubmit;

  @override
  State<_ExamQuizView> createState() => _ExamQuizViewState();
}

class _ExamQuizViewState extends State<_ExamQuizView> {
  bool _showReviewGrid = false;

  ExamProvider get _p => widget.provider;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context);
    final lang = context.watch<LanguageProvider>().language;
    final q = _p.currentQuestion;
    final isWarning = _p.isWarning;

    // Màu đồng hồ: đỏ khi cảnh báo
    final timerColor = isWarning ? Colors.red.shade700 : null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(s.exam),
            const Spacer(),
            // Đồng hồ đếm ngược luôn hiển thị
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: timerColor ??
                    Theme.of(context).appBarTheme.foregroundColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              child: Text(_p.formattedRemainingTime),
            ),
            if (isWarning) ...[
              const SizedBox(width: 6),
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 20),
            ],
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          // Nút xem lưới câu hỏi
          IconButton(
            icon: Icon(
              _showReviewGrid ? Icons.grid_off : Icons.grid_view,
            ),
            tooltip: 'Xem tổng quan',
            onPressed: () =>
                setState(() => _showReviewGrid = !_showReviewGrid),
          ),
          // Nút nộp bài
          TextButton(
            onPressed: widget.onSubmit,
            child: Text(s.submit,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Thanh tiến trình ──────────────────────────────────────────
          LinearProgressIndicator(
            value: _p.totalQuestions == 0
                ? 0
                : (_p.currentIndex + 1) / _p.totalQuestions,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${s.question} ${_p.currentIndex + 1} ${s.of} ${_p.totalQuestions}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  'Đã làm: ${_p.userAnswers.length}/${_p.totalQuestions}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),

          // ── Lưới xem lại hoặc câu hỏi ────────────────────────────────
          Expanded(
            child: _showReviewGrid
                ? _ReviewGrid(provider: _p, onTap: (i) {
                    _p.goToQuestion(i);
                    setState(() => _showReviewGrid = false);
                  })
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: q == null
                          ? const SizedBox.shrink()
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: QuestionCard(
                                question: q,
                                lang: lang,
                                selected: _p.selectedAnswerFor(q.number),
                                revealAnswer: false, // Không lộ đáp án khi thi
                                onSelect: (choice) {
                                  _p.selectAnswer(q.number, choice);
                                },
                                onNext: _p.currentIndex < _p.totalQuestions - 1
                                    ? _p.nextQuestion
                                    : null,
                                nextLabel: _p.currentIndex <
                                        _p.totalQuestions - 1
                                    ? s.next
                                    : null,
                              ),
                            ),
                    ),
                  ),
          ),

          // ── Điều hướng Trước / Sau ────────────────────────────────────
          if (!_showReviewGrid)
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
                        onPressed: _p.currentIndex > 0
                            ? _p.previousQuestion
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Trước'),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed:
                            _p.currentIndex < _p.totalQuestions - 1
                                ? _p.nextQuestion
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
//  Lưới xem tổng quan câu hỏi
// ════════════════════════════════════════════════════════════════════════════

class _ReviewGrid extends StatelessWidget {
  const _ReviewGrid({required this.provider, required this.onTap});

  final ExamProvider provider;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 60,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: provider.totalQuestions,
      itemBuilder: (ctx, i) {
        final q = provider.questions[i];
        final answered = provider.userAnswers.containsKey(q.number);
        final isCurrent = i == provider.currentIndex;

        Color bg;
        Color fg;
        if (isCurrent) {
          bg = colorScheme.primary;
          fg = colorScheme.onPrimary;
        } else if (answered) {
          bg = colorScheme.secondaryContainer;
          fg = colorScheme.onSecondaryContainer;
        } else {
          bg = colorScheme.surfaceContainerHighest;
          fg = colorScheme.onSurfaceVariant;
        }

        return Semantics(
          label: 'Câu ${i + 1}${answered ? ", đã trả lời" : ", chưa trả lời"}',
          button: true,
          child: InkWell(
            onTap: () => onTap(i),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
                border: isCurrent
                    ? Border.all(
                        color: colorScheme.primary, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: fg,
                  fontWeight:
                      isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
