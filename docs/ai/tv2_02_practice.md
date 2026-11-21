# BÁO CÁO PHÁT TRIỂN TÍNH NĂNG LUYỆN TẬP (TV2 — PROMPT 2)

**Tác giả:** AI Agent (Tiếp nhận codebase cho TV2 — B24DCCC243_NguyenDanhThang)  
**Tính năng:** Màn hình Thiết lập Luyện tập + Làm bài từng câu + Thẻ câu hỏi & Đáp án chuẩn tiếp cận + Quản lý câu sai  
**Thời gian hoàn thành:** 21/11/2026  

---

## 1. TỔNG QUAN CÔNG VIỆC THỰC HIỆN

Nối tiếp kiến trúc 3 tầng và các hợp đồng API có sẵn, giai đoạn TV2 Prompt 2 đã hoàn thiện trọn vẹn luồng **Luyện tập câu hỏi trắc nghiệm song ngữ**:

1. **Màn hình Thiết lập Luyện tập (`PracticeSetupScreen`)**:
   - Cho phép người dùng chọn khối kiến thức trong **20 khối chuẩn** trích xuất từ `flutter_300_questions.json` (hoặc chọn làm toàn bộ 300 câu).
   - Cho phép chọn số lượng câu hỏi linh hoạt: **10, 20, 30, hoặc 50 câu**.
   - Giao diện đáp ứng (responsive), co giãn tốt trên màn hình nhỏ (320dp) và tablet.
   - Nút **"Bắt đầu luyện tập"** cao >= 48dp dẫn trực tiếp sang `PracticeScreen`.

2. **Màn hình Luyện tập (`PracticeScreen`)**:
   - Thực hiện làm **từng câu hỏi một**, có thanh tiến độ `LinearProgressIndicator` và chỉ số `Câu hiện tại / Tổng số câu`.
   - Kết nối với `PracticeProvider`, quản lý toàn bộ vòng đời và trạng thái bài luyện tập.
   - Hỗ trợ **3 trạng thái nạp dữ liệu** có lối ra rõ ràng:
     - **Loading**: Vòng xoay tiến trình + Nút "Về trang chủ".
     - **Error**: Báo lỗi thân thiện khi không đọc được JSON + Nút "Thử lại" và "Về trang chủ".
     - **Empty**: Thông báo rỗng khi khối chọn không có câu + Nút "Chọn khối khác" và "Về trang chủ".
   - Nút **"Làm lại từ đầu"** và **"Thoát"**: Hiển thị `AlertDialog` cảnh báo nếu người dùng đang làm dở bài để tránh mất tiến độ ngoài ý muốn; tích hợp `PopScope` chặn thao tác vuốt / back vật lý.

3. **Thẻ câu hỏi (`QuestionCard`)**:
   - Hiển thị đầy đủ **Mã câu** (`K01-001`), số thứ tự câu và huy hiệu **Mức độ** (`Nhớ`, `Hiểu`, `Vận dụng`) có màu sắc phân biệt.
   - Hiển thị đề bài linh hoạt theo ngôn ngữ: Tiếng Việt, Tiếng Anh, hoặc **Song ngữ** (hiển thị tiếng Việt trên và tiếng Anh in nghiêng bên dưới).
   - **Khối code minh họa monospace**: Sử dụng widget `Text` với `softWrap` bọc trong khung màu tối (`#1E1E1E`), hỗ trợ cuộn ngang để **giữ nguyên thụt lề (indentation)** của code Dart/Flutter.
   - **Khối giải thích tức thì (Instant Explanation)**: Mở khóa ngay sau khi chọn đáp án, hiển thị giải thích tiếng Việt, giải thích tiếng Anh và link nguồn tham khảo (`source`).
   - Nút **"Câu tiếp theo"** (hoặc "Xem kết quả" ở câu cuối) có chiều cao >= 48dp.

4. **Ô chọn đáp án (`OptionTile`)**:
   - Chiều cao tối thiểu luôn đạt **>= 48dp** (`BoxConstraints(minHeight: 48)`), đảm bảo vùng chạm an toàn theo chuẩn Material Design & WCAG.
   - Tích hợp thuộc tính **`Semantics`** đầy đủ cho các công cụ hỗ trợ người khiếm thị (TalkBack / VoiceOver).
   - Phản hồi thị giác tức thì sau khi chọn:
     - **Đáp án đúng**: Viền và nền xanh lá cây (`Color(0xFF2E7D32)` / `Color(0xFFE8F5E9)`) kèm icon check tròn.
     - **Đáp án sai**: Viền và nền đỏ (`Color(0xFFC62828)` / `Color(0xFFFFEBEE)`) kèm icon cancel tròn.
     - **Chế độ song ngữ**: Hiển thị phụ đề bản dịch tiếng Anh của từng đáp án.

5. **Lưu trữ câu sai tự động (`WrongRepository`)**:
   - Tạo hợp đồng `WrongRepository` và cài đặt `WrongRepositoryImpl` lưu trữ vào `LocalStore` (SharedPreferences).
   - Trong `PracticeProvider`: Khi người dùng chọn đáp án:
     - Nếu **trả lời sai**: Tự động gọi `wrongRepository.addWrongQuestion` lưu mã câu vào máy.
     - Nếu **trả lời đúng**: Tự động gọi `wrongRepository.removeWrongQuestion` xóa mã câu khỏi danh sách sai để đồng bộ tiến độ học tập.

---

## 2. KẾT QUẢ PHÂN TÍCH VÀ KIỂM THỬ

- `flutter analyze`: **0 issues found** (Không còn bất kỳ lỗi hay cảnh báo nào).
- `flutter test`: **35/35 tests passed xanh toàn bộ**:
  - `i18n_test.dart`: Đọc chuỗi đa ngôn ngữ (7 tests).
  - `providers_test.dart`: Kiểm tra `PracticeProvider`, `ExamProvider`, `WrongProvider` (9 tests).
  - `quiz_service_test.dart`: Chấm điểm và tính thống kê (3 tests).
  - `wrong_repository_test.dart`: Kiểm tra lưu / xóa câu sai tự động (2 tests).
  - `home_screen_test.dart` & `home_screen_states_test.dart`: Giao diện và 3 trạng thái của HomeScreen (6 tests).
  - `practice_widgets_test.dart`: Kích thước >= 48dp, semantics, màu xanh/đỏ, monospace code (3 tests).
  - `practice_screen_test.dart`: Luồng làm từng câu, AlertDialog xác nhận thoát/làm lại, 3 trạng thái nạp dữ liệu (5 tests).

---

## 3. GIẢI THÍCH KIẾN THỨC NỀN TẢNG

### 3.1. Vì sao phải lưu câu sai vào máy (`WrongRepository` qua SharedPreferences)?
1. **Duy trì tiến độ học tập của người dùng (Data Persistence)**: Luyện tập trắc nghiệm là một quá trình liên tục. Nếu người dùng tắt ứng dụng hoặc hết pin, danh sách các câu làm sai không bị mất đi.
2. **Hỗ trợ tính năng "Làm lại câu sai" (Spaced Repetition)**: Tính năng ôn tập câu sai yêu cầu hệ thống phải trích xuất được chính xác những câu người dùng từng trả lời sai để họ luyện tập lại cho đến khi trả lời đúng.
3. **Cơ chế tự xóa câu sai khi làm đúng**: Khi câu sai được làm lại và chọn đúng đáp án, việc xóa ngay khỏi máy giúp danh sách ôn tập luôn cập nhật, mang lại cảm giác tiến bộ rõ rệt cho người học.

### 3.2. Vì sao ô chọn đáp án (`OptionTile`) phải có chiều cao >= 48dp?
1. **Tiêu chuẩn Material Design & Touch Target Accessibility**: Theo hướng dẫn của Google Material Design và tiêu chuẩn quốc tế WCAG (Web Content Accessibility Guidelines) mức AA, mọi phần tử tương tác trên màn hình cảm ứng phải có kích thước tối thiểu là **48x48dp**.
2. **Hạn chế bấm nhầm (Fat Finger Problem)**: Trên thiết bị di động, đầu ngón tay của người dùng có diện tích tiếp xúc trung bình từ 7–10mm (tương đương 44–48dp). Nếu ô đáp án nhỏ hơn 48dp, người dùng rất dễ bấm trượt hoặc bấm nhầm sang đáp án lân cận, gây ức chế khi làm bài trắc nghiệm.
3. **Thân thiện với người dùng đặc biệt**: Hỗ trợ tối đa cho người lớn tuổi, người có thị lực kém hoặc người gặp khó khăn trong điều khiển vận động tinh (motor impairments).

---

## 4. BẢNG TỔNG HỢP CÁC FILE ĐÃ TẠO / SỬA

| File | Hành động | Giải thích chi tiết (3–5 dòng) |
|---|---|---|
| `lib/ui/screens/practice_setup_screen.dart` | Tạo mới | Màn hình thiết lập cấu hình luyện tập cho phép người dùng chọn trong 20 khối kiến thức (hoặc tất cả 300 câu) và chọn số lượng câu (10/20/30/50). Bố cục chuẩn Material 3, nút bấm bắt đầu >= 48dp điều hướng sang màn hình luyện tập. |
| `lib/ui/screens/practice_screen.dart` | Hoàn thiện | Màn hình luyện tập làm từng câu một với thanh tiến độ, tích hợp QuestionCard, hỗ trợ 3 trạng thái Loading/Error/Empty kèm lối ra. Có nút "Làm lại từ đầu" và "Thoát" với AlertDialog xác nhận tránh mất tiến độ. |
| `lib/ui/widgets/question_card.dart` | Hoàn thiện | Card câu hỏi hiển thị mã câu, mức độ, đề bài song ngữ, khối code monospace giữ nguyên thụt lề bằng Text softWrap. Tự động hiển thị khối giải thích song ngữ (vi/en) kèm nguồn tài liệu và nút chuyển câu ngay khi chọn đáp án. |
| `lib/ui/widgets/option_tile.dart` | Hoàn thiện | Widget dòng đáp án trắc nghiệm A/B/C/D có chiều cao tối thiểu >= 48dp và nhãn Semantics. Tự động đổi màu xanh (đáp án đúng) hoặc đỏ (đáp án sai) sau khi trả lời, kèm phụ đề tiếng Anh ở chế độ song ngữ. |
| `lib/logic/repositories/wrong_repository.dart` | Tạo mới | Interface tầng Logic định nghĩa các thao tác lưu trữ câu hỏi làm sai: lấy danh sách câu sai, thêm câu sai khi trả lời trật và xóa câu sai khi trả lời đúng. |
| `lib/data/repositories/wrong_repository_impl.dart` | Tạo mới | Triển khai WrongRepository ở tầng Data, đọc và ghi danh sách số thứ tự câu sai xuống SharedPreferences thông qua LocalStore. |
| `lib/data/datasources/local_store.dart` | Cập nhật | Bổ sung key `wrong_questions_v1` cùng 2 phương thức `loadWrongQuestionNumbers()` và `saveWrongQuestionNumbers()` để lưu trữ dữ liệu câu sai bền vững. |
| `lib/data/models/question.dart` | Cập nhật | Bổ sung trường `optionsEn` và phương thức `optionText(key, lang)` giúp phân tách và đọc chính xác đáp án tiếng Việt và tiếng Anh từ cấu trúc JSON. |
| `lib/logic/providers/practice_provider.dart` | Cập nhật | Tích hợp WrongRepository vào PracticeProvider: tự động lưu câu vào danh sách sai khi chọn sai và tự động xóa khỏi danh sách sai khi người dùng chọn đúng. |
| `lib/ui/screens/home_screen.dart` | Cập nhật | Cập nhật điều hướng nút "Luyện tập" sang màn hình thiết lập `PracticeSetupScreen` để người dùng chọn khối và số câu trước khi bắt đầu. |
| `test/unit/wrong_repository_test.dart` | Tạo mới | Unit test kiểm tra tính năng tự động lưu và xóa câu sai trong PracticeProvider và phương thức clear của FakeWrongRepository. |
| `test/widget/practice_widgets_test.dart` | Tạo mới | Widget test kiểm tra OptionTile đạt chiều cao >= 48dp, có semantics, đổi màu đúng/sai và QuestionCard hiển thị đầy đủ code monospace, giải thích song ngữ. |
| `test/widget/practice_screen_test.dart` | Tạo mới | Widget test kiểm tra PracticeSetupScreen và PracticeScreen: làm bài từng câu, hiện AlertDialog khi bấm Thoát và hiển thị LoadingView khi đang tải. |

---

## 5. LỆNH GIT COMMIT IN SẴN

```bash
git add . ; git commit -m "feat(practice): man hinh luyen tap + the giai thich song ngu"
git add . ; git commit -m "feat(widgets): the cau hoi + o chon 48dp"
```
