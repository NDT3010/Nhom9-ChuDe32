/// Unit-test TV2: Timer hết giờ thì trạng thái là hết giờ và hàm nộp bài được gọi.
library;

import 'package:bilingual_quiz_app/logic/providers/exam_provider.dart';
import 'package:bilingual_quiz_app/logic/services/exam_timer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('TV2 04: Timer Test', () {
    test('ExamTimer khi hết giờ: isTimeUp = true, remainingSeconds = 0, onTimeUp được gọi', () async {
      final timer = ExamTimer();
      bool timeUpTriggered = false;

      timer.start(1, onTimeUp: () {
        timeUpTriggered = true;
      });

      expect(timer.isRunning, isTrue);
      expect(timer.remainingSeconds, 1);

      // Chờ qua 1 giây để timer kích hoạt tick cuối
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      expect(timeUpTriggered, isTrue);
      expect(timer.isTimeUp, isTrue);
      expect(timer.remainingSeconds, 0);
      expect(timer.isRunning, isFalse);

      timer.dispose();
    });

    test('ExamProvider khi hết giờ tự động nộp bài và gán isTimeUp = true', () async {
      final questions = [
        fakeQuestion(number: 1, answer: 'A'),
        fakeQuestion(number: 2, answer: 'B'),
      ];
      final qRepo = FakeQuestionRepository(questions);
      final hRepo = FakeHistoryRepo();
      final provider = ExamProvider(
        questionRepository: qRepo,
        historyRepository: hRepo,
      );

      // Khởi động bài thi với thời gian cực ngắn (1 giây)
      await provider.startExam(count: 2, durationSeconds: 1);
      provider.selectAnswer(1, 'A');

      expect(provider.isSubmitted, isFalse);
      expect(provider.isTimeUp, isFalse);

      // Chờ hết 1 giây để provider tự nộp bài
      await Future<void>.delayed(const Duration(milliseconds: 1300));

      expect(provider.isTimeUp, isTrue);
      expect(provider.isSubmitted, isTrue);
      expect(provider.result, isNotNull);
      expect(provider.result?.total, 2);
      expect(provider.result?.correct, 1);
      expect(hRepo.results.length, 1);

      provider.dispose();
    });

    test('Tạm dừng và tiếp tục timer hoạt động chính xác', () {
      final timer = ExamTimer();
      timer.start(60);
      expect(timer.isRunning, isTrue);

      timer.pause();
      expect(timer.isRunning, isFalse);

      timer.resume();
      expect(timer.isRunning, isTrue);

      timer.dispose();
    });
  });
}
