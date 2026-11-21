# HANDOFF-2.md — Bàn giao kỹ thuật từ Thành viên 2 sang Thành viên 3

> **Phiên bản:** Handoff TV2 → TV3 | **Trạng thái:** Toàn bộ 4 luồng chính đã hoàn thiện, 72/72 tests xanh (100%), 0 lỗi analyzer.

---

### 1. TỔNG QUAN & TÌNH TRẠNG CODEBASE
- Đã hoàn thành toàn bộ 4 luồng người dùng: **Trang chủ** (`HomeScreen`), **Luyện tập** (`PracticeScreen` + `PracticeSetupScreen`), **Thi thử** (`ExamScreen` + `ExamTimer`), **Làm lại câu sai** (`WrongRetryScreen`), và **Kết quả** (`ResultScreen`).
- Toàn bộ trạng thái quản trị bằng `ChangeNotifier` (`PracticeProvider`, `ExamProvider`, `WrongProvider`, `LanguageProvider`), tuân thủ triệt để: **KHÔNG** đọc file/chạy timer trong `build()`, có `dispose()` dọn dẹp tài nguyên.
- Đạt chuẩn UX/A11y Material: touch target mọi nút tương tác $\ge 48\,\text{dp}$, bố cục co giãn responsive từ 320dp đến tablet, 3 trạng thái `LoadingView`/`ErrorView`/`EmptyView` luôn có lối ra.

---

### 2. CÁC THÀNH PHẦN ĐÃ HOÀN THIỆN
- **State Management & Logic:**
  - `lib/logic/services/exam_timer.dart`: Quản lý đếm ngược mm:ss, cảnh báo $\le 60\,\text{s}$, tạm dừng khi app vào nền (`WidgetsBindingObserver`), tự nộp khi hết giờ.
  - `lib/logic/providers/`: `practice_provider.dart`, `exam_provider.dart`, `wrong_provider.dart`.
  - `lib/logic/repositories/`: `wrong_repository.dart` và triển khai `wrong_repository_impl.dart`.
- **Giao diện & Widgets:**
  - `lib/ui/widgets/question_card.dart`: Monospace code block giữ nguyên thụt lề, song ngữ, badge cấp độ, giải thích tức thì.
  - `lib/ui/widgets/option_tile.dart`: 4 lựa chọn A/B/C/D $\ge 48\,\text{dp}$, phản hồi đúng (xanh)/sai (đỏ).
  - `lib/ui/screens/`: `home_screen.dart`, `practice_setup_screen.dart`, `practice_screen.dart`, `exam_screen.dart`, `result_screen.dart`, `wrong_retry_screen.dart`.

---

### 3. CẤU HÌNH THI THỬ MẶC ĐỊNH & QUY ƯỚC KIẾN TRÚC
- **Cấu hình Thi thử mặc định:**
  - Số câu hỏi: **20 câu** (tùy chọn: 10, 20, 30, 50).
  - Thời gian làm bài: **15 phút** = 900 giây (tùy chọn: 10, 15, 30, 45 phút).
  - Phạm vi kiến thức: **Tất cả các khối** (ngẫu nhiên từ ngân hàng 300 câu, hoặc chọn khối 1..20).
  - Cảnh báo sắp hết giờ: Kích hoạt khi thời gian còn lại $\le 60\,\text{giây}$ (đồng hồ chuyển đỏ kèm icon cảnh báo).
- **Quy ước kiến trúc 3 tầng:**
  - Tầng UI chỉ lắng nghe qua Provider / Repository interface; không gọi trực tiếp SharedPreferences.
  - String hiển thị 100% qua `AppStringsScope.of(context)` / `AppStrings`, không hardcode chuỗi.
  - UI import Material thông qua `package:material_ui/material_ui.dart`.

---

### 4. PHẠM VI CÔNG VIỆC CỦA THÀNH VIÊN 3
- **File TV3 ĐƯỢC PHÉP THÊM / HOÀN THIỆN:**
  - `lib/ui/screens/stats_screen.dart`: Hoàn thiện màn hình Thống kê (biểu đồ tiến độ, điểm trung bình, lịch sử bài thi theo `StatsService`).
  - `lib/ui/screens/settings_screen.dart`: Bổ sung tính năng cài đặt nâng cao nếu cần (reset dữ liệu, dark mode).
  - `test/unit/tv3_*.dart` và `test/widget/tv3_*.dart`: Bổ sung test cho module thống kê.
  - `docs/ai/tv3_*.md` và `HANDOFF-3.md`: Tài liệu bàn giao cuối cùng.
- **File TV3 TUYỆT ĐỐI KHÔNG ĐƯỢC SỬA / ĐỔI TÊN:**
  - `lib/core/` (`result.dart`, `app_error.dart`): Interface cốt lõi.
  - `lib/data/models/` (`question.dart`, `quiz_result.dart`).
  - `lib/logic/services/exam_timer.dart` và `quiz_service.dart`.
  - `lib/logic/providers/` (`practice_provider.dart`, `exam_provider.dart`, `wrong_provider.dart`).
  - Toàn bộ các test suite hiện có của TV1 và TV2 trong `test/`.

---

### 5. LỆNH CHẠY & KIỂM THỬ CHẤT LƯỢNG
```bash
# Phân tích tĩnh code (yêu cầu 0 cảnh báo, 0 lỗi)
flutter analyze

# Chạy toàn bộ 72 test cases
flutter test
```
