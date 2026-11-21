/// Unit tests cho ExamTimer: start, tick, pause, resume, hết giờ, dispose.
library;

import 'dart:async';

import 'package:bilingual_quiz_app/logic/services/exam_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExamTimer', () {
    late ExamTimer timer;

    setUp(() => timer = ExamTimer());
    tearDown(() => timer.dispose());

    test('start() khởi tạo remainingSeconds và isRunning = true', () {
      timer.start(60);
      expect(timer.remainingSeconds, 60);
      expect(timer.totalSeconds, 60);
      expect(timer.isRunning, isTrue);
      expect(timer.isTimeUp, isFalse);
    });

    test('formattedTime trả về mm:ss đúng định dạng', () {
      timer.start(90); // 1 phút 30 giây
      expect(timer.formattedTime, '01:30');
    });

    test('isWarning = true khi remainingSeconds <= 60', () {
      timer.start(60);
      expect(timer.isWarning, isTrue);
    });

    test('isWarning = false khi remainingSeconds > 60', () {
      timer.start(90);
      expect(timer.isWarning, isFalse);
    });

    test('pause() dừng đếm giờ, isRunning = false', () {
      timer.start(60);
      timer.pause();
      expect(timer.isRunning, isFalse);
    });

    test('resume() tiếp tục đếm giờ sau pause', () {
      timer.start(60);
      timer.pause();
      timer.resume();
      expect(timer.isRunning, isTrue);
    });

    test('stop() đặt isRunning = false', () {
      timer.start(60);
      timer.stop();
      expect(timer.isRunning, isFalse);
    });

    test('onTimeUp gọi khi thời gian về 0', () async {
      bool called = false;
      timer.start(1, onTimeUp: () => called = true);

      // Chờ Timer tích thực sự (> 1 giây)
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(called, isTrue);
      expect(timer.isTimeUp, isTrue);
      expect(timer.isRunning, isFalse);
    });

    test('onTick gọi sau mỗi giây', () async {
      final ticks = <int>[];
      timer.start(3, onTick: ticks.add);
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      // Phải có ít nhất 2 tick
      expect(ticks.length, greaterThanOrEqualTo(2));
    });

    test('dispose() hủy timer và không gây lỗi', () {
      final t2 = ExamTimer(); // dùng instance riêng để tránh gọi dispose 2 lần
      t2.start(60);
      expect(() => t2.dispose(), returnsNormally);
    });

    test('elapsedSeconds = totalSeconds - remainingSeconds', () {
      timer.start(120);
      // Chưa tick, elapsed = 0
      expect(timer.elapsedSeconds, 0);
    });
  });
}
