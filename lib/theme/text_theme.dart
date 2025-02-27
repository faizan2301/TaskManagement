import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class TTextTheme {
  TTextTheme._(); // To avoid creating instances

  static TextStyle _baseTextStyle(
      Color color, double fontSize, FontWeight fontWeight) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /* -- Light Text Theme -- */
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: _baseTextStyle(AppColors.text, 32.0, FontWeight.bold),
    displayMedium: _baseTextStyle(AppColors.text, 28.0, FontWeight.w700),
    displaySmall: _baseTextStyle(AppColors.text, 24.0, FontWeight.normal),
    headlineLarge: _baseTextStyle(AppColors.text, 22.0, FontWeight.w600),
    headlineMedium: _baseTextStyle(AppColors.text, 20.0, FontWeight.w600),
    headlineSmall: _baseTextStyle(AppColors.text, 18.0, FontWeight.normal),
    titleLarge: _baseTextStyle(AppColors.text, 16.0, FontWeight.w600),
    titleMedium: _baseTextStyle(AppColors.text, 14.0, FontWeight.w600),
    titleSmall: _baseTextStyle(AppColors.text, 12.0, FontWeight.w600),
    bodyLarge: _baseTextStyle(AppColors.text, 16.0, FontWeight.normal),
    bodyMedium: _baseTextStyle(
        AppColors.text.withValues(alpha: 0.8), 14.0, FontWeight.normal),
    bodySmall: _baseTextStyle(AppColors.text, 12.0, FontWeight.normal),
    labelLarge: _baseTextStyle(AppColors.text, 14.0, FontWeight.w500),
    labelMedium: _baseTextStyle(AppColors.text, 12.0, FontWeight.w500),
    labelSmall: _baseTextStyle(AppColors.text, 10.0, FontWeight.w500),
  );

  /* -- Dark Text Theme -- */
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: _baseTextStyle(AppColors.textDark, 32.0, FontWeight.bold),
    displayMedium: _baseTextStyle(AppColors.textDark, 28.0, FontWeight.w700),
    displaySmall: _baseTextStyle(AppColors.textDark, 24.0, FontWeight.normal),
    headlineLarge: _baseTextStyle(AppColors.textDark, 22.0, FontWeight.w600),
    headlineMedium: _baseTextStyle(AppColors.textDark, 20.0, FontWeight.w600),
    headlineSmall: _baseTextStyle(AppColors.textDark, 18.0, FontWeight.normal),
    titleLarge: _baseTextStyle(AppColors.textDark, 16.0, FontWeight.w600),
    titleMedium: _baseTextStyle(AppColors.textDark, 14.0, FontWeight.w600),
    titleSmall: _baseTextStyle(AppColors.textDark, 12.0, FontWeight.w600),
    bodyLarge: _baseTextStyle(AppColors.textDark, 16.0, FontWeight.normal),
    bodyMedium: _baseTextStyle(
        AppColors.textDark.withValues(alpha: 0.8), 14.0, FontWeight.normal),
    bodySmall: _baseTextStyle(AppColors.textDark, 12.0, FontWeight.normal),
    labelLarge: _baseTextStyle(AppColors.textDark, 14.0, FontWeight.w500),
    labelMedium: _baseTextStyle(AppColors.textDark, 12.0, FontWeight.w500),
    labelSmall: _baseTextStyle(AppColors.textDark, 10.0, FontWeight.w500),
  );
}
