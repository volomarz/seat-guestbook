import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF0B4F2C);
  static const greenDark = Color(0xFF08361E);
  static const cream = Color(0xFFFAF6EC);
  static const dirt = Color(0xFFB5651D);
  static const red = Color(0xFFB22222);
  static const ink = Color(0xFF1C1C1C);
  static const muted = Color(0xFF6B6B6B);
  static const line = Color(0xFFE2DED0);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
}