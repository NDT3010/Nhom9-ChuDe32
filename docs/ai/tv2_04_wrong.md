# tv2_04_wrong.md — Màn hình Làm lại câu sai

> Tài liệu AI handoff do TV2 tạo. Mô tả file tạo/sửa trong Prompt 4.

---

## 1. Danh sách file đã tạo / sửa

| File | Vai trò | Ghi chú |
|---|---|---|
| `lib/ui/screens/wrong_retry_screen.dart` | Màn hình ôn tập câu sai: đọc `WrongRepository` + `QuestionRepository`, hiển thị theo kiểu Luyện tập | Có 3 trạng thái Loading/Error/Empty, xóa câu đúng ngay tức thì |
| `test/widget/wrong_retry_screen_test.dart` | 4 widget tests: Loading, Congratulations (empty), câu hỏi hiển thị, Error state | Dùng Fake repository để kiểm thử độc lập |

---

## 2. Luồng Làm lại câu sai

```
WrongRetryScreen.initState()
  → addPostFrameCallback → _provider.loadWrongQuestions()
      ├─ isLoading = true  → LoadingView
      ├─ hasError          → ErrorView (nút Thử lại)
      ├─ isEmpty           → _EmptyCongratulationsScreen 🎉
      └─ có câu sai        → _WrongQuizView
                               │
                               ▼ _WrongQuestionWrapper
                               │  onSelect(choice)
                               │   ├─ isCorrect → removeWrongQuestion() + nextQuestion/reload
                               │   └─ sai      → addWrongQuestion() + hiện giải thích
                               │
                               └─ Nút "Xóa toàn bộ" → AlertDialog → clear() → reset()
```

---

## 3. Giải thích kỹ thuật: Lưu mã câu thay vì lưu cả nội dung

### Vì sao lưu **số thứ tự câu** (mã câu, kiểu `int`) thay vì lưu toàn bộ nội dung?

| Tiêu chí | Lưu mã câu (int) | Lưu toàn bộ nội dung |
|---|---|---|
| **Kích thước lưu trữ** | ~3–5 byte/câu → 300 câu ≈ 1 KB | ~2–5 KB/câu → 300 câu ≈ 1,5 MB |
| **Tốc độ đọc/ghi** | Rất nhanh (SharedPreferences `StringList`) | Chậm (parse JSON lớn) |
| **Nhất quán dữ liệu** | Luôn tra cứu từ nguồn gốc (JSON asset) | Có thể lỗi thời nếu JSON được cập nhật |
| **Tính an toàn** | Không lưu dữ liệu nhạy cảm | Lưu dư thừa, rủi ro khi schema đổi |
| **Độ phức tạp đồng bộ** | Chỉ cần 1 key `List<String>` trong SharedPreferences | Cần serialize/deserialize đầy đủ Question model |

> **Kết luận:** Lưu mã câu giúp app nhẹ, nhanh và luôn tra cứu nội dung câu hỏi mới nhất từ asset JSON — không bao giờ bị "cũ".

---

## 4. Hành vi theo câu trả lời

| Người dùng chọn | Hành động |
|---|---|
| **Đúng** | `WrongRepository.removeWrongQuestion()` → xóa khỏi máy → `nextQuestion()` hoặc `loadWrongQuestions()` |
| **Sai** | `WrongRepository.addWrongQuestion()` → đảm bảo còn trong danh sách → hiện giải thích vi/en + nguồn |

---

## 5. Tiêu chuẩn UI

- Touch target tối thiểu: **48 dp** (nút Trước/Tiếp theo, Xóa toàn bộ)
- `ConstrainedBox maxWidth: 640 dp` → đọc được trên tablet
- `LinearProgressIndicator` hiển thị tiến trình câu hiện tại / tổng
- Nút "Xóa toàn bộ câu sai" có `AlertDialog` xác nhận, nút Xóa màu đỏ

---

## 6. Commit command

```bash
git add lib/ui/screens/wrong_retry_screen.dart \
        test/widget/wrong_retry_screen_test.dart \
        docs/ai/tv2_04_wrong.md
git commit -m "feat(wrong): man hinh lam lai cau sai"
```
