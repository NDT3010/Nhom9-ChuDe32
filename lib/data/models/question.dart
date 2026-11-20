/// Model câu hỏi trắc nghiệm — ánh xạ 1:1 với `flutter_300_questions.json`.
library;

/// Một câu hỏi trong ngân hàng đề.
class Question {
  const Question({
    required this.number,
    required this.codeId,
    required this.block,
    required this.level,
    required this.levelVi,
    required this.topicVi,
    required this.topicEn,
    required this.viQuestion,
    required this.enQuestion,
    required this.options,
    required this.answer,
    this.code,
    this.tier = '',
    this.importance = '',
    this.answerTextVi = '',
    this.explanationVi = '',
    this.explanationEn = '',
    this.source = '',
  });

  /// Số thứ tự câu (1..300).
  final int number;

  /// Mã câu như `K01-001`.
  final String codeId;

  /// Khối kiến thức (1..20).
  final int block;

  /// Mức độ: remember | understand | apply.
  final String level;
  final String levelVi;
  final String topicVi;
  final String topicEn;
  final String viQuestion;
  final String enQuestion;

  /// 4 đáp án keyed A/B/C/D.
  final Map<String, String> options;

  /// Đáp án đúng ('A'..'D').
  final String answer;

  /// Đoạn code minh họa (có thể null trong JSON).
  final String? code;
  final String tier;
  final String importance;
  final String answerTextVi;
  final String explanationVi;
  final String explanationEn;
  final String source;

  /// true nếu [choice] trùng đáp án (so sánh hoa/thường, trim).
  bool isCorrect(String choice) => choice.trim().toUpperCase() == answer.trim().toUpperCase();

  /// Câu hỏi hiển thị theo ngôn ngữ: 'vi' hoặc 'en'.
  String prompt(String lang) => lang == 'en' ? enQuestion : viQuestion;

  /// Giải thích hiển thị theo ngôn ngữ.
  String explanation(String lang) => lang == 'en' ? explanationEn : explanationVi;

  factory Question.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final Map<String, String> opts = {};
    if (rawOptions is Map) {
      for (final e in rawOptions.entries) {
        opts[e.key.toString()] = e.value?.toString() ?? '';
      }
    }
    int asInt(dynamic v, [int fb = 0]) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? fb;
    }

    return Question(
      number: asInt(json['number']),
      codeId: json['code_id']?.toString() ?? '',
      block: asInt(json['block']),
      level: json['level']?.toString() ?? 'remember',
      levelVi: json['level_vi']?.toString() ?? '',
      topicVi: json['topic_vi']?.toString() ?? '',
      topicEn: json['topic_en']?.toString() ?? '',
      viQuestion: json['vi_question']?.toString() ?? '',
      enQuestion: json['en_question']?.toString() ?? '',
      options: opts,
      answer: (json['answer']?.toString() ?? '').toUpperCase(),
      code: json['code']?.toString(),
      tier: json['tier']?.toString() ?? '',
      importance: json['importance']?.toString() ?? '',
      answerTextVi: json['answer_text_vi']?.toString() ?? '',
      explanationVi: json['explanation_vi']?.toString() ?? '',
      explanationEn: json['explanation_en']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'code_id': codeId,
        'block': block,
        'level': level,
        'level_vi': levelVi,
        'topic_vi': topicVi,
        'topic_en': topicEn,
        'vi_question': viQuestion,
        'en_question': enQuestion,
        'options': options,
        'answer': answer,
        'code': code,
        'tier': tier,
        'importance': importance,
        'answer_text_vi': answerTextVi,
        'explanation_vi': explanationVi,
        'explanation_en': explanationEn,
        'source': source,
      };
}
