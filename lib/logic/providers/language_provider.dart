/// Provider quản lý ngôn ngữ hiển thị (tầng Logic).
///
/// Nhớ ngôn ngữ đang chọn trong RAM và tự lưu/đọc xuống máy qua
/// [SettingsRepository] (SharedPreferences) để app mở lại vẫn giữ ngôn ngữ.
library;

import 'package:bilingual_quiz_app/core/result.dart';
import 'package:bilingual_quiz_app/l10n/app_strings.dart';
import 'package:bilingual_quiz_app/logic/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';

/// Quản lý ngôn ngữ hiện tại và thông báo cho UI khi ngôn ngữ đổi.
class LanguageProvider extends ChangeNotifier {
  /// Tạo provider với repository cấu hình (có thể truyền fake khi test).
  LanguageProvider({this.settingsRepository, AppLang initial = AppLang.vi})
      : _lang = initial;

  /// Repository dùng để đọc/ghi ngôn ngữ xuống máy.
  SettingsRepository? settingsRepository;
  AppLang _lang;
  bool _loaded = false;

  /// Ngôn ngữ hiện tại.
  AppLang get language => _lang;

  /// Bảng chuỗi tương ứng ngôn ngữ hiện tại.
  AppStrings get strings => AppStrings.of(_lang);

  /// true nếu đã đọc xong ngôn ngữ lưu trên máy.
  bool get isLoaded => _loaded;

  /// Đọc ngôn ngữ đã lưu từ máy. Gọi 1 lần lúc app khởi động.
  ///
  /// Nếu đọc lỗi hoặc không có dữ liệu, giữ nguyên ngôn ngữ mặc định.
  Future<void> load() async {
    final repo = settingsRepository;
    if (repo == null) {
      _loaded = true;
      return;
    }
    final result = await repo.getLang();
    if (result is Ok<String>) {
      _lang = AppLang.fromCode(result.value);
    }
    _loaded = true;
    notifyListeners();
  }

  /// Đổi ngôn ngữ: cập nhật trong RAM, thông báo UI, rồi lưu xuống máy.
  Future<void> setLanguage(AppLang lang) async {
    if (lang == _lang) return;
    _lang = lang;
    notifyListeners();
    final repo = settingsRepository;
    if (repo == null) return;
    await repo.setLang(lang.code);
  }

  /// Đặt repository (dùng khi khởi tạo muộn trong main.dart).
  void attachRepository(SettingsRepository repository) => settingsRepository = repository;

  @override
  void dispose() {
    // Giải phóng tham chiếu tới repository để tránh giữ ngoài vòng đời widget.
    settingsRepository = null;
    super.dispose();
  }
}
