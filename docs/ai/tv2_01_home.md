# BÁO CÁO TIẾP NHẬN CODEBASE VÀ PHÁT TRIỂN TV2 (GIAI ĐOẠN 1)

**Tác giả:** AI Agent (Tiếp nhận codebase cho TV2 — B24DCCC243_NguyenDanhThang)  
**Dự án:** Bilingual Quiz App (Trắc nghiệm Flutter song ngữ)  
**Thời gian hoàn thành:** 21/11/2026  

---

## 1. BƯỚC 1 — QUÉT VÀ ĐỌC CODEBASE

### 1.1. Cây thư mục hiện tại (lib/, test/, assets/)

```text
D:\app_final\
├── assets\
│   └── data\
│       └── flutter_300_questions.json
├── lib\
│   ├── app.dart
│   ├── main.dart
│   ├── core\
│   │   ├── app_error.dart
│   │   └── result.dart
│   ├── data\
│   │   ├── datasources\
│   │   │   ├── local_store.dart
│   │   │   └── question_local_datasource.dart
│   │   ├── models\
│   │   │   ├── question.dart
│   │   │   └── quiz_result.dart
│   │   └── repositories\
│   │       ├── history_repository_impl.dart
│   │       ├── question_repository_impl.dart
│   │       └── settings_repository_impl.dart
│   ├── l10n\
│   │   └── app_strings.dart
│   ├── logic\
│   │   ├── providers\
│   │   │   ├── exam_provider.dart         <-- [Mới TV2]
│   │   │   ├── language_provider.dart
│   │   │   ├── practice_provider.dart     <-- [Mới TV2]
│   │   │   └── wrong_provider.dart        <-- [Mới TV2]
│   │   ├── repositories\
│   │   │   ├── history_repository.dart
│   │   │   ├── question_repository.dart
│   │   │   └── settings_repository.dart
│   │   └── services\
│   │       ├── quiz_service.dart
│   │       └── stats_service.dart
│   └── ui\
│       ├── screens\
│       │   ├── exam_screen.dart
│       │   ├── home_screen.dart
│       │   ├── practice_screen.dart
│       │   ├── result_screen.dart
│       │   ├── settings_screen.dart
│       │   ├── stats_screen.dart
│       │   └── wrong_retry_screen.dart
│       ├── theme\
│       │   └── app_theme.dart
│       └── widgets\
│           ├── option_tile.dart
│           ├── question_card.dart
│           └── state_views.dart
└── test\
    ├── helpers\
    │   └── fakes.dart
    ├── unit\
    │   ├── i18n_test.dart
    │   ├── providers_test.dart            <-- [Mới TV2]
    │   └── quiz_service_test.dart
    └── widget\
        ├── home_screen_states_test.dart   <-- [Mới TV2]
        └── home_screen_test.dart
```

### 1.2. Bảng tóm tắt các file/lớp có sẵn của TV1 và TODO cần làm

| Tên File | Lớp / Interface | Vai trò kiến trúc | Phần còn là TODO của TV1 |
|---|---|---|---|
| `lib/core/app_error.dart` | `AppError`, `AppErrorCode` | Định nghĩa mã lỗi và ngoại lệ dùng chung toàn app | Đã hoàn thiện ở TV1 |
| `lib/core/result.dart` | `Result<T>`, `Ok<T>`, `Err<T>` | Sealed class bao bọc kết quả thành công/thất bại | Đã hoàn thiện ở TV1 |
| `lib/data/datasources/local_store.dart` | `LocalStore`, `LocalStoreKeys` | Đọc/ghi `SharedPreferences` cho lịch sử & ngôn ngữ | Đã hoàn thiện ở TV1 |
| `lib/data/datasources/question_local_datasource.dart` | `QuestionLocalDatasource` | Đọc file JSON 300 câu hỏi từ asset | Đã hoàn thiện ở TV1 |
| `lib/data/models/question.dart` | `Question` | Model câu hỏi trắc nghiệm song ngữ | Đã hoàn thiện ở TV1 |
| `lib/data/models/quiz_result.dart` | `QuizResult` | Model kết quả ca làm bài (lưu điểm, câu sai) | `wrongNumbers` chuẩn bị cho TV2 làm lại câu sai |
| `lib/logic/repositories/question_repository.dart` | `QuestionRepository` | Hợp đồng lấy dữ liệu câu hỏi (getAll, getByBlock, getByLevel) | Tầng UI/Provider phụ thuộc interface này |
| `lib/data/repositories/question_repository_impl.dart` | `QuestionRepositoryImpl` | Hiện thực hóa QuestionRepository từ datasource JSON | TODO(tv2): Thêm bộ nhớ đệm (cache RAM) và tìm kiếm |
| `lib/logic/repositories/history_repository.dart` | `HistoryRepository` | Hợp đồng lưu/đọc/xóa lịch sử làm bài | Tầng UI/Provider phụ thuộc interface này |
| `lib/data/repositories/history_repository_impl.dart` | `HistoryRepositoryImpl` | Hiện thực hóa HistoryRepository lưu vào LocalStore | Đã hoàn thiện ở TV1 |
| `lib/logic/repositories/settings_repository.dart` | `SettingsRepository` | Hợp đồng đọc/ghi ngôn ngữ (vi, en, both) | Đã hoàn thiện ở TV1 |
| `lib/data/repositories/settings_repository_impl.dart` | `SettingsRepositoryImpl` | Hiện thực hóa SettingsRepository | Đã hoàn thiện ở TV1 |
| `lib/logic/services/quiz_service.dart` | `QuizService` | Logic trộn đề ngẫu nhiên (`buildQuiz`) và chấm điểm (`grade`) | Đã hoàn thiện ở TV1, sẵn sàng cho Provider gọi |
| `lib/logic/services/stats_service.dart` | `StatsService`, `StatsSummary` | Tính toán số lượt làm, điểm cao nhất, điểm trung bình | TODO(tv2): Thống kê theo block/level + biểu đồ tiến bộ |
| `lib/logic/providers/language_provider.dart` | `LanguageProvider` | ChangeNotifier quản lý ngôn ngữ hiển thị | Đã hoàn thiện ở TV1 |
| `lib/l10n/app_strings.dart` | `AppStrings`, `AppStringsScope`, `AppLang` | Bảng chuỗi song ngữ vi/en/both và InheritedWidget | Đã hoàn thiện đủ key |
| `lib/ui/widgets/state_views.dart` | `LoadingView`, `ErrorView`, `EmptyView` | 3 widget hiển thị trạng thái chuẩn | Đã hoàn thiện nút bấm >= 48dp |
| `lib/ui/widgets/option_tile.dart` | `OptionTile` | Widget dòng đáp án trắc nghiệm | TODO(tv2): Thêm màu đúng/sai sau khi nộp bài |
| `lib/ui/widgets/question_card.dart` | `QuestionCard` | Card hiển thị câu hỏi và 4 đáp án A/B/C/D | TODO(tv2): Hoàn thiện chấm màu và hiển thị giải thích |
| `lib/ui/screens/home_screen.dart` | `HomeScreen` | Màn hình chính điều hướng | Đã nâng cấp ở TV2: 3 trạng thái Loading/Error/Empty có lối ra |
| `lib/ui/screens/practice_screen.dart` | `PracticeScreen` | Màn hình Luyện tập | Khung Scaffold chuẩn, sẵn sàng kết nối PracticeProvider (prompt 2.2) |
| `lib/ui/screens/exam_screen.dart` | `ExamScreen` | Màn hình Thi thử | Khung Scaffold chuẩn, sẵn sàng kết nối ExamProvider (prompt 2.3) |
| `lib/ui/screens/result_screen.dart` | `ResultScreen` | Màn hình Kết quả | Khung Scaffold chuẩn, nhận `QuizResult?`, nút về trang chủ (prompt 2.4) |
| `lib/ui/screens/wrong_retry_screen.dart` | `WrongRetryScreen` | Màn hình Làm lại câu sai | Khung Scaffold chuẩn, sẵn sàng kết nối WrongProvider (prompt 2.4) |
| `lib/ui/screens/stats_screen.dart` | `StatsScreen` | Màn hình Thống kê | Khung Scaffold chuẩn, sẵn sàng tích hợp StatsService (prompt 3.1) |
| `lib/ui/screens/settings_screen.dart` | `SettingsScreen` | Màn hình Cài đặt | Đã hoạt động với `LanguageProvider` chọn ngôn ngữ |

### 1.3. Tuân thủ quy định Handoff
- Tuyệt đối giữ nguyên toàn bộ các file đã có của TV1, không đổi tên file, không đổi tên lớp, không đổi tên hàm, không đổi key chuỗi trong `AppStrings`.
- Chỉ bổ sung hoặc tinh chỉnh tối thiểu để tương thích kiến trúc và đáp ứng đầy đủ yêu cầu nghiệp vụ của TV2.

---

## 2. BƯỚC 2 — CÔNG VIỆC ĐÃ HOÀN THÀNH

### 2.1. Tạo 3 Provider (`ChangeNotifier`)
1. **`lib/logic/providers/practice_provider.dart` (`PracticeProvider`)**:
   - Nhận `QuestionRepository` và tùy chọn `HistoryRepository`.
   - Quản lý trạng thái: `isLoading`, `errorMessage`, `questions`, `currentIndex`, `userAnswers`, `isSubmitted`, `result`.
   - Các phương thức: `loadQuestions()`, `selectAnswer()`, `nextQuestion()`, `previousQuestion()`, `goToQuestion()`, `submitQuiz()`, `reset()`.
   - Tuân thủ quy tắc: KHÔNG đọc file/gọi logic trong `build()`, có `dispose()` để dọn dẹp bộ nhớ.

2. **`lib/logic/providers/exam_provider.dart` (`ExamProvider`)**:
   - Quản lý ca thi đếm ngược thời gian với `Timer.periodic`.
   - Thời gian đếm ngược: `remainingSeconds`, định dạng hiển thị `formattedRemainingTime` (mm:ss).
   - Tự động nộp bài và gán `isTimeUp = true` khi hết giờ.
   - Tuân thủ quy tắc: KHÔNG chạy timer trong `build()`; timer chỉ khởi chạy khi gọi `startExam()`. Phương thức `dispose()` hủy timer ngay lập tức (`_timer?.cancel()`), tránh rò rỉ bộ nhớ.

3. **`lib/logic/providers/wrong_provider.dart` (`WrongProvider`)**:
   - Đọc lịch sử từ `HistoryRepository`, trích xuất toàn bộ các số câu làm sai (`wrongNumbers`) loại bỏ trùng lặp.
   - Tra cứu chi tiết từng câu sai từ `QuestionRepository.getAll()`.
   - Cho phép người dùng làm lại bài, chấm điểm và lưu kết quả với mode `retry`.
   - Tuân thủ quy tắc: KHÔNG đọc file trong `build()`, có `dispose()` dọn dẹp tài nguyên.

### 2.2. Hoàn thiện `lib/ui/screens/home_screen.dart`
- Thiết kế 4 nút lớn có chiều cao 56dp (đạt yêu cầu >= 48dp):
  1. **Luyện tập** (`s.practice`, icon `Icons.sports_esports`) -> Chuyển sang `PracticeScreen`.
  2. **Thi thử** (`s.exam`, icon `Icons.timer`) -> Chuyển sang `ExamScreen`.
  3. **Làm lại câu sai** (`s.wrongRetry`, icon `Icons.replay`) -> Chuyển sang `WrongRetryScreen`.
  4. **Thống kê** (`s.stats`, icon `Icons.bar_chart`) -> Chuyển sang `StatsScreen`.
- Nút **Cài đặt** (`s.settings`, icon `Icons.settings`) -> Chuyển sang `SettingsScreen`.
- Toàn bộ chuỗi hiển thị đều trích xuất từ `AppStringsScope.of(context)`.
- Bố cục dùng `ListView` bọc trong `ConstrainedBox(maxWidth: 720)` giúp giao diện không bị tràn chữ (`RenderFlex overflow`) trên màn hình nhỏ (320dp) và hiển thị cân đối trên tablet/màn hình lớn.
- Hỗ trợ đầy đủ 3 trạng thái khi nạp dữ liệu:
  - **Loading**: Hiển thị `LoadingView` + nút "Về trang chủ".
  - **Error**: Hiển thị `ErrorView` với thông điệp lỗi + 2 nút lối ra: "Thử lại" và "Về trang chủ".
  - **Empty**: Hiển thị `EmptyView` khi chưa có dữ liệu + 2 nút lối ra: "Thử lại" và "Về trang chủ".

### 2.3. Tạo & chuẩn hóa 6 Màn hình Scaffold
- `lib/ui/screens/practice_screen.dart`
- `lib/ui/screens/exam_screen.dart`
- `lib/ui/screens/result_screen.dart`
- `lib/ui/screens/wrong_retry_screen.dart`
- `lib/ui/screens/stats_screen.dart`
- `lib/ui/screens/settings_screen.dart`
Tất cả các màn hình đều là `Scaffold` chuẩn, có thanh tiêu đề `AppBar` với nút quay lại (`leading: BackButton`), sử dụng các view trạng thái từ `state_views.dart`, biên dịch sạch 0 lỗi.

### 2.4. Kết quả Phân tích và Kiểm thử
- `flutter analyze`: **0 lỗi, 0 cảnh báo** (No issues found).
- `flutter test`: **26/26 tests passed** (Bao gồm unit-test cho cả 3 Provider và widget-test cho các trạng thái của HomeScreen).

---

## 3. GIẢI THÍCH KIẾN THỨC NỀN TẢNG (FLUTTER STATE MANAGEMENT)

### 3.1. `ChangeNotifier` là gì?
`ChangeNotifier` là một lớp tiện ích có sẵn trong Flutter SDK (`foundation.dart`) đóng vai trò là một Observable trong mẫu thiết kế Observer. Nó cung cấp cơ chế đăng ký và thông báo sự kiện cho các đối tượng lắng nghe (listeners). Trong kiến trúc Provider, các lớp logic kế thừa `ChangeNotifier` để lưu trữ dữ liệu (state) của ứng dụng độc lập với cây widget.

### 3.2. `notifyListeners()` để làm gì?
Khi dữ liệu trong `ChangeNotifier` thay đổi (ví dụ: đã tải xong câu hỏi, người dùng chọn đáp án mới, hoặc đồng hồ đếm ngược nhảy 1 giây), phương thức `notifyListeners()` sẽ được gọi để phát tín hiệu thông báo đến tất cả các widget đang lắng nghe (`context.watch`, `Consumer`). Nhờ đó, Flutter biết cần kích hoạt hàm `build()` vẽ lại đúng các widget liên quan nhằm cập nhật giao diện mà không cần reload toàn bộ màn hình.

### 3.3. Vì sao KHÔNG viết logic nặng trong `build()`?
1. **Hiệu năng & Tần số gọi**: Hàm `build()` của widget được Flutter gọi liên tục bất cứ khi nào cha của nó rebuild, khi kích thước màn hình thay đổi, khi bàn phím xuất hiện, hoặc khi animation chạy (lên đến 60–120 lần mỗi giây).
2. **Hiện tượng giật lag / đơ ứng dụng (Jank)**: Nếu đưa logic nặng (đọc file ổ đĩa, giải mã JSON 300 câu, gọi mạng HTTP) vào trong `build()`, luồng UI chính (Main UI Thread) sẽ bị nghẽn, dẫn đến tụt khung hình nghiêm trọng.
3. **Hiện tượng lặp vô tận (Infinite Loop)**: Nếu trong `build()` khởi chạy logic làm thay đổi state và gọi `notifyListeners()` hoặc `setState()`, nó sẽ kích hoạt `build()` chạy lại ngay lập tức, tạo thành vòng lặp vô hạn gây sập app. Do đó, logic nặng chỉ được kích hoạt trong `initState()`, qua sự kiện người dùng (tap, press), hoặc trong phương thức của Provider.

### 3.4. `dispose()` cần thiết khi nào?
Phương thức `dispose()` là vòng đời cuối cùng của một State/ChangeNotifier khi widget hoặc đối tượng bị xóa vĩnh viễn khỏi cây widget. `dispose()` bắt buộc phải có khi đối tượng sở hữu các tài nguyên không tự giải phóng:
- **`Timer`**: Nếu không gọi `timer.cancel()`, timer sẽ tiếp tục chạy ngầm vô thời hạn trong Dart VM, cố gọi `notifyListeners()` trên một đối tượng đã hủy, gây ngoại lệ `FlutterError` và rò rỉ bộ nhớ (Memory Leak).
- **`AnimationController`**, **`TextEditingController`**, **`ScrollController`**: Chiếm dụng listener của hệ điều hành và ticker provider.
- **`StreamSubscription`**: Tiếp tục nhận dữ liệu từ Stream nếu không `cancel()`.

---

## 4. BẢNG TỔNG HỢP CÁC FILE ĐÃ TẠO VÀ CHỈNH SỬA

| File | Hành động | Giải thích chi tiết (3-5 dòng) |
|---|---|---|
| `lib/logic/providers/practice_provider.dart` | Tạo mới | Provider quản lý luồng Luyện tập (tải câu hỏi, lọc block/level, chuyển câu hỏi, lưu đáp án tạm và nộp bài chấm điểm). Không chạy logic bất đồng bộ trong hàm build; giải phóng Map đáp án trong `dispose()`. |
| `lib/logic/providers/exam_provider.dart` | Tạo mới | Provider quản lý phòng Thi thử có tính năng đếm ngược thời gian qua `Timer.periodic`. Tự động nộp bài và hủy timer khi hết giờ; bắt buộc cancel timer trong `dispose()` để triệt tiêu memory leak. |
| `lib/logic/providers/wrong_provider.dart` | Tạo mới | Provider quản lý màn Làm lại câu sai: đọc các `wrongNumbers` từ `HistoryRepository`, truy vấn dữ liệu câu hỏi từ `QuestionRepository` và chấm điểm lượt ôn tập lại. |
| `lib/ui/screens/home_screen.dart` | Hoàn thiện | Màn hình chính chứa 4 nút bấm điều hướng chính (Luyện tập, Thi thử, Câu sai, Thống kê) và nút Cài đặt với chiều cao >= 48dp. Bố cục `ListView` co giãn chống tràn; hỗ trợ 3 trạng thái Loading/Error/Empty đầy đủ lối ra. |
| `lib/ui/screens/practice_screen.dart` | Cập nhật | Dựng cấu trúc Scaffold chuẩn cho màn Luyện tập, có AppBar, nút quay lại BackButton và widget `EmptyView` sẵn có, sẵn sàng cho prompt 2.2. |
| `lib/ui/screens/exam_screen.dart` | Cập nhật | Dựng cấu trúc Scaffold chuẩn cho màn Thi thử, có AppBar, nút quay lại BackButton và view trạng thái chuẩn, sẵn sàng kết nối ExamProvider ở prompt 2.3. |
| `lib/ui/screens/result_screen.dart` | Cập nhật | Dựng Scaffold hiển thị kết quả làm bài, hiển thị card điểm số và số câu đúng/tổng số câu khi có `QuizResult`, có nút "Về trang chủ". |
| `lib/ui/screens/wrong_retry_screen.dart` | Cập nhật | Dựng cấu trúc Scaffold chuẩn cho màn Làm lại câu sai, hiển thị trạng thái khi chưa có lịch sử và nút quay lại, sẵn sàng cho prompt 2.4. |
| `lib/ui/screens/stats_screen.dart` | Cập nhật | Dựng cấu trúc Scaffold chuẩn cho màn Thống kê, hiển thị `EmptyView` khi lịch sử trống và nút quay lại, sẵn sàng cho prompt 3.1. |
| `lib/ui/screens/settings_screen.dart` | Cập nhật | Chuẩn hóa Scaffold màn Cài đặt với BackButton, tích hợp `LanguageProvider` cho phép chuyển đổi tức thời giữa Tiếng Việt, English và Song ngữ. |
| `test/unit/providers_test.dart` | Tạo mới | Bộ unit test toàn diện cho cả 3 Provider (PracticeProvider, ExamProvider, WrongProvider) kiểm tra đầy đủ các luồng: nạp dữ liệu, chọn đáp án, tính điểm, xử lý câu sai và xử lý lỗi. |
| `test/widget/home_screen_states_test.dart` | Tạo mới | Bộ widget test kiểm tra độc lập 3 trạng thái Loading, Error, Empty của HomeScreen cùng các sự kiện bấm nút Thử lại và Về trang chủ. |

---

## 5. LỆNH GIT COMMIT IN SẴN

```bash
git add . ; git commit -m "feat(state): provider luyen tap, thi thu, cau sai"
git add . ; git commit -m "feat(ui): man hinh Home + dieu huong 4 luong"
```
