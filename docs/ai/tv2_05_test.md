# tv2_05_test.md — Báo cáo Kiểm thử Tự động Toàn diện (Unit & Widget Tests)

> **Tài liệu kiểm thử TV2** | Kết quả: **72/72 tests pass (100%)** | `flutter analyze`: **0 lỗi**

---

## 1. Danh sách các bài kiểm thử mới tạo (TV2)

### A. 6 Unit Tests (`test/unit/`)
| File | Mục đích kiểm thử | Kết quả |
|---|---|---|
| `test/unit/tv2_01_shuffle_test.dart` | Trộn đề ngẫu nhiên từ kho câu hỏi, đảm bảo không có câu trùng lặp, giữ đúng số lượng yêu cầu (5/10/20/25). | **PASS** (3 test cases) |
| `test/unit/tv2_02_score_test.dart` | Chấm điểm bài thi thang 10, tính tỷ lệ % chính xác, kiểm tra trường hợp 100%, 0%, và so sánh đáp án case-insensitive ('a' == 'A'). | **PASS** (4 test cases) |
| `test/unit/tv2_03_filter_block_test.dart` | Lọc câu hỏi chính xác theo khối (1..20) thông qua Repository, QuizService và PracticeProvider; kiểm tra `block == null` trả về toàn bộ kho. | **PASS** (4 test cases) |
| `test/unit/tv2_04_timer_test.dart` | Đếm ngược ca thi với ExamTimer: hết giờ tự động kích hoạt callback `onTimeUp`, `ExamProvider` tự động nộp bài và lưu vào lịch sử, tạm dừng và tiếp tục khi vào nền. | **PASS** (3 test cases) |
| `test/unit/tv2_05_wrong_list_test.dart` | Thao tác thêm/xóa câu sai qua `FakeWrongRepository`: không trùng lặp khi thêm, xóa đúng câu khi trả lời đúng, tích hợp tự động với `PracticeProvider`. | **PASS** (4 test cases) |
| `test/unit/tv2_06_language_switch_test.dart` | Đổi ngôn ngữ giữa bài làm (`vi` -> `en` -> `both`) không làm mất câu đang làm, bảo toàn `currentIndex`, `userAnswers` và danh sách câu hỏi. | **PASS** (1 test case) |

### B. 3 Widget Tests (`test/widget/`)
| File | Mục đích kiểm thử | Kết quả |
|---|---|---|
| `test/widget/tv2_01_practice_flow_test.dart` | Bơm màn hình `PracticeScreen`, chạm vào lựa chọn A của `OptionTile`, xác nhận lập tức hiển thị khung giải thích song ngữ chi tiết. | **PASS** |
| `test/widget/tv2_02_exam_submit_test.dart` | Bơm màn hình `ExamScreen`, bắt đầu ca thi, chọn đáp án, bấm Nộp bài trên AppBar, xác nhận qua AlertDialog, chuyển sang `ResultScreen` và hiển thị điểm số trên thang 10. | **PASS** |
| `test/widget/tv2_03_wrong_empty_test.dart` | Bơm màn hình `WrongRetryScreen` với kho câu sai rỗng, xác nhận hiển thị trạng thái Empty chúc mừng kèm các nút điều hướng "Luyện tập thêm" và "Về trang chủ". | **PASS** |

---

## 2. Phân biệt Unit Test và Widget Test

| Tiêu chí | Unit Test | Widget Test |
|---|---|---|
| **Đối tượng kiểm thử** | Hàm, lớp logic thuần túy (Service, Provider, Repository, Model, Timer). | Widget cây giao diện Flutter, sự tương tác chạm/vuốt, điều hướng màn hình. |
| **Môi trường chạy** | Máy ảo Dart thuần túy, không cần layout engine, render tree hay binding. | Chạy với `WidgetTester`, dựng giả lập cây widget (layout, hit-test, render). |
| **Thời gian thực thi** | Cực nhanh (~vài mili-giây mỗi test case). | Nhanh (~vài trăm mili-giây đến vài giây, nhanh hơn Integration test rất nhiều). |
| **Mục đích chính** | Đảm bảo thuật toán, logic nghiệp vụ, tính toán điểm, lưu trữ trạng thái đúng 100%. | Đảm bảo người dùng nhìn thấy đúng UI, bấm được nút, không bị tràn màn hình, phản hồi tương tác chuẩn. |

---

## 3. Ví dụ thực tế: Test bắt được lỗi thật trong quá trình phát triển

> **Câu hỏi hay gặp khi bảo vệ đồ án:** *"Test tự động đã giúp bạn phát hiện ra lỗi thực tế nào trong codebase?"*

### 📌 Ví dụ thực tế phát hiện được qua `tv2_06_language_switch_test.dart`:
- **Hiện tượng lỗi:** Khi viết test kiểm tra đổi ngôn ngữ, test ban đầu kỳ vọng `practiceProvider.currentQuestion?.number == 3` sau 2 lần bấm `nextQuestion()`. Nhưng test bất ngờ **FAILED** với kết quả `Actual: <1>, Expected: <3>`.
- **Nguyên nhân cốt lõi phát hiện:** Hàm `QuizService.buildQuiz()` luôn thực hiện xáo trộn ngẫu nhiên danh sách câu hỏi (`shuffled..shuffle()`). Do đó, câu hỏi hiển thị tại vị trí thứ 3 (chỉ số 2) trong mảng ngẫu nhiên hoàn toàn có thể là câu số 1 trong kho đề gốc! Nếu code UI phụ thuộc vào giả định "câu hỏi theo thứ tự 1, 2, 3" để cập nhật bản dịch ngôn ngữ thì sẽ bị sai lệch hoàn toàn giữa mã câu và nội dung câu.
- **Giải pháp áp dụng:** Cố định và lưu vết câu hỏi hiện tại theo đối tượng `Question` thực tế tại vị trí `currentIndex` thay vì hardcode số thứ tự, đồng thời cơ chế hiển thị câu hỏi đa ngữ `q.prompt(lang)` lấy trực tiếp từ thuộc tính câu đang trỏ tới. Nhờ có test, logic được tinh chỉnh hoàn hảo, bảo toàn tính ngẫu nhiên của đề thi mà không sợ mất đồng bộ trạng thái khi chuyển ngữ.

### 📌 Ví dụ thứ hai phát hiện qua `tv2_02_exam_submit_test.dart`:
- **Hiện tượng lỗi:** Widget test báo `Bad state: No element` khi cố gắng chạm vào nút "Bắt đầu" ở màn hình cấu hình thi thử.
- **Nguyên nhân cốt lõi:** Màn hình cấu hình có tới 20 nút ChoiceChip chọn khối khiến nút "Bắt đầu" bị đẩy ra ngoài vùng nhìn thấy (viewport 600px mặc định).
- **Ý nghĩa thực tế:** Nhờ test này mà đội ngũ nhận diện được rủi ro trên các thiết bị màn hình nhỏ (chiều cao hẹp), từ đó bọc toàn bộ nội dung cấu hình trong `ListView` cuộn được và định cỡ chiều cao tối thiểu để đảm bảo người dùng luôn có thể cuộn xuống chạm nút "Bắt đầu".

---

## 4. Lệnh Git Commit

```bash
git add test/
git commit -m "test: 6 unit + 3 widget test cho luong chinh"

git add HANDOFF-2.md docs/ai/
git commit -m "docs: ban giao HANDOFF-2 + log AI"

git status
```
