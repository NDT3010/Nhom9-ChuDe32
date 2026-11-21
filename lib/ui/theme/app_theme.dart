/// Theme dùng chung toàn app (Material 3, seedColor xanh Phenikaa).
library;

import 'package:material_ui/material_ui.dart';

/// Gom cấu hình ThemeData một chỗ để mọi màn hình nhất quán.
abstract class AppTheme {
  /// Theme sáng duy nhất ở TV1.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        appBarTheme: const AppBarTheme(centerTitle: true),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
        ),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 1,
        ),
      );
}
