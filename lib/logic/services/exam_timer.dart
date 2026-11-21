/// Service đồng hồ đếm ngược phòng thi (tầng Logic).
///
/// Bọc Dart Timer trong ChangeNotifier: hỗ trợ start(), pause(), resume(),
/// kiểm tra remainingSeconds, isRunning và bắt buộc hủy Timer trong dispose().
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Quản lý đồng hồ đếm ngược của phòng thi thi thử.
class ExamTimer extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;

  /// Callback khi thời gian đếm ngược kết thúc (0 giây).
  VoidCallback? onTimeUp;

  /// Callback sau mỗi giây đếm ngược.
  ValueChanged<int>? onTick;

  /// Số giây còn lại của bài thi.
  int get remainingSeconds => _remainingSeconds;

  /// Tổng số giây quy định ban đầu của ca thi.
  int get totalSeconds => _totalSeconds;

  /// Số giây đã trôi qua kể từ khi bắt đầu làm bài.
  int get elapsedSeconds => _totalSeconds - _remainingSeconds;

  /// true nếu đồng hồ đang chạy.
  bool get isRunning => _isRunning;

  /// true nếu ca thi đã hết thời gian (0 giây).
  bool get isTimeUp => _totalSeconds > 0 && _remainingSeconds <= 0;

  /// true nếu thời gian còn lại <= 60 giây (báo sắp hết giờ).
  bool get isWarning => _remainingSeconds > 0 && _remainingSeconds <= 60;

  /// Định dạng chuỗi mm:ss hiển thị trên giao diện AppBar.
  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Bắt đầu đếm ngược thời gian từ [durationSeconds] giây.
  void start(int durationSeconds, {VoidCallback? onTimeUp, ValueChanged<int>? onTick}) {
    _timer?.cancel();
    _totalSeconds = durationSeconds;
    _remainingSeconds = durationSeconds;
    _isRunning = true;
    this.onTimeUp = onTimeUp;
    this.onTick = onTick;
    _timer = Timer.periodic(const Duration(seconds: 1), _handleTick);
    notifyListeners();
  }

  /// Tạm dừng đếm thời gian (ví dụ khi app bị ẩn xuống nền).
  void pause() {
    if (!_isRunning) return;
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  /// Tiếp tục đếm ngược thời gian (ví dụ khi app quay lại màn hình chính).
  void resume() {
    if (_isRunning || _remainingSeconds <= 0) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), _handleTick);
    notifyListeners();
  }

  /// Dừng hẳn đồng hồ đếm thời gian.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void _handleTick(Timer timer) {
    if (_remainingSeconds > 1) {
      _remainingSeconds--;
      onTick?.call(_remainingSeconds);
      notifyListeners();
    } else {
      _remainingSeconds = 0;
      _isRunning = false;
      _timer?.cancel();
      _timer = null;
      notifyListeners();
      onTimeUp?.call();
    }
  }

  /// Hủy vĩnh viễn Timer để tránh rò rỉ bộ nhớ (bắt buộc).
  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    super.dispose();
  }
}
