import 'package:flutter/material.dart';
import 'colors.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static OutlinedButtonThemeData lightOutlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.primary),
      foregroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.primary)),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  );

  static OutlinedButtonThemeData darkOutlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.primaryDark),
      foregroundColor: AppColors.textDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.textDark)),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  );
}
