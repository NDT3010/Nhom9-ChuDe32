# tv2_03_exam.md — Màn hình Thi thử + Kết quả

> Tài liệu AI handoff do TV2 tạo. Mô tả các file được tạo/sửa trong Prompt 3.

---

## 1. Danh sách file đã tạo / sửa

| File | Vai trò | Ghi chú |
|---|---|---|
| `lib/logic/services/exam_timer.dart` | Bọc `Timer` Dart vào `ChangeNotifier`; hỗ trợ `start()`, `pause()`, `resume()`, `stop()`, `dispose()` | Hủy timer bắt buộc trong `dispose()` |
| `lib/logic/providers/exam_provider.dart` | Quản lý toàn bộ luồng thi thử: nạp đề, đếm giờ, chọn đáp án, nộp bài, lưu lịch sử | Cập nhật: thêm `isWarning`, `pause()`, `resume()`, tham số `block` |
| `lib/ui/screens/exam_screen.dart` | Màn hình thi thử 2 pha: **Cấu hình** → **Làm bài** | Có lưới xem tổng quan, AppBar đồng hồ đếm ngược, cảnh báo đỏ ≤ 60s, `WidgetsBindingObserver` |
| `lib/ui/screens/result_screen.dart` | Hiển thị điểm/10, % đúng, danh sách câu sai có giải thích, nút Làm lại / Về nhà | Nhận `QuizResult` và `List<Question>` từ màn hình thi |
| `test/unit/exam_timer_test.dart` | Unit test ExamTimer: khởi động, pause, resume, hết giờ, onTick, dispose | 9 test cases |

---

## 2. Luồng Thi thử

```
ExamScreen (cấu hình)
  │  Chọn: số câu (10/20/30/50), phút (10/15/30/45), khối (1-20 hoặc tất cả)
  │  [Bắt đầu]
  ▼
ExamScreen (làm bài)
  │  AppBar: đồng hồ mm:ss, cảnh báo đỏ khi ≤ 60s
  │  LinearProgressIndicator: câu x / tổng
  │  QuestionCard (revealAnswer: false — không lộ đáp án)
  │  Lưới xem tổng quan (đã làm / chưa làm)
  │  Nút: Trước / Tiếp theo / Nộp bài
  │  [Hết giờ] → submitExam() tự động
  ▼
ResultScreen
  │  Điểm / 10, % chính xác, số đúng/sai, thời gian
  │  Danh sách câu sai (đáp án đúng + giải thích vi/en + nguồn)
  │  [Làm lại câu sai] → WrongRetryScreen
  │  [Về trang chủ] → popUntil isFirst
```

---

## 3. Giải thích kỹ thuật

### Timer của Dart là gì?

`Timer` trong `dart:async` là cơ chế lên lịch thi hành code sau một khoảng thời gian hoặc định kỳ.  
- `Timer.periodic(duration, callback)` gọi `callback` sau mỗi `duration`.  
- Timer chạy trên **event loop** của Dart — không tạo thread mới.

### Vì sao phải hủy timer trong `dispose()`?

Nếu không hủy:
1. Widget/Provider bị xóa nhưng Timer vẫn còn trong event loop.
2. Timer tiếp tục gọi `notifyListeners()` trên object đã bị dispose → crash `FlutterError: A ChangeNotifier was used after being disposed`.
3. Rò rỉ bộ nhớ (memory leak): object không được GC vì Timer giữ tham chiếu.

**Quy tắc:** mọi `Timer` phải có `_timer?.cancel()` trong `dispose()`.

### Luồng hết giờ tự nộp bài

```
ExamTimer._handleTick()
  → remainingSeconds == 0
  → _isRunning = false, _isTimeUp = true
  → notifyListeners()
  → onTimeUp?.call()
      → ExamProvider._startTimer() đã đăng ký onTimeUp = submitExam
          → submitExam() chấm điểm, lưu lịch sử
          → notifyListeners()
              → ExamScreen.build() nhận isSubmitted == true
              → WidgetsBinding.addPostFrameCallback → Navigator.pushReplacement(ResultScreen)
```

### WidgetsBindingObserver

`ExamScreen` implements `WidgetsBindingObserver` để nhận sự kiện vòng đời app:
- `AppLifecycleState.paused / inactive` → `_provider.pause()` → timer dừng.
- `AppLifecycleState.resumed` → `_provider.resume()` → timer tiếp tục.

Điều này đảm bảo người dùng **không mất thời gian** khi nhận cuộc gọi hoặc chuyển ứng dụng.

---

## 4. Tiêu chuẩn UI

| Tiêu chí | Giá trị |
|---|---|
| Touch target tối thiểu | 48 dp (Material guideline) |
| Màn hình nhỏ nhất hỗ trợ | 320 dp width |
| `ConstrainedBox maxWidth` | 640 dp (đọc được trên tablet) |
| Trạng thái đồng hồ bình thường | Text màu AppBar mặc định |
| Trạng thái cảnh báo (≤ 60s) | Text đỏ + Icon `warning_amber_rounded` |

---

## 5. Commit commands

```bash
git add lib/logic/services/exam_timer.dart \
        lib/logic/providers/exam_provider.dart \
        lib/ui/screens/exam_screen.dart \
        test/unit/exam_timer_test.dart
git commit -m "feat(exam): man hinh thi thu + dong ho dem nguoc"

git add lib/ui/screens/result_screen.dart \
        docs/ai/tv2_03_exam.md
git commit -m "feat(result): man hinh ket qua + luu lich su"
```
