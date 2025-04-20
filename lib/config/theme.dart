import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF4882C4);
  static const Color accentColor = Color(0xFF5AC8FA);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);

  // ألوان الوضع الليلي
  static const Color darkPrimaryColor = Color(0xFF1F2937);
  static const Color darkAccentColor = Color(0xFF3D85C6);
  static const Color darkBackgroundColor = Color(0xFF111827);
  static const Color darkCardColor = Color(0xFF1F2937);

  // الخط والأيقونات
  static const Color textColorLight = Color(0xFF212121);
  static const Color textColorDark = Color(0xFFECEFF1);
  static const Color secondaryTextColorLight = Color(0xFF757575);
  static const Color secondaryTextColorDark = Color(0xFFB0BEC5);

  // تهيئة الثيم الفاتح
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: const CardTheme(color: cardColor, elevation: 2),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: textColorLight,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(color: textColorLight, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textColorLight),
      bodyMedium: TextStyle(color: secondaryTextColorLight),
    ),
  );

  // تهيئة الثيم الداكن
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: darkPrimaryColor,
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkAccentColor,
      surface: darkBackgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    cardTheme: CardTheme(color: darkCardColor, elevation: 2),
    appBarTheme: AppBarTheme(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkAccentColor,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: textColorDark,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(color: textColorDark, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textColorDark),
      bodyMedium: TextStyle(color: secondaryTextColorDark),
    ),
  );
}
