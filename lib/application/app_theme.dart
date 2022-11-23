import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/domain/utils/constants/app_colors.dart';
import '../core/domain/utils/constants/app_text_style.dart';
import '../generated/fonts.gen.dart';

class AppTheme {
  static final ThemeData lighTheme = ThemeData(
    colorScheme: const ColorScheme.light().copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      onBackground: AppColors.onBackground,
      background: AppColors.background,
      error: AppColors.error,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.onSecondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.onSecondary,
        ),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.onSecondary,
        ),
      ),
      isDense: true,
      border: const OutlineInputBorder(),
      hintStyle:
          AppTextStyle.size_16_normal.copyWith(color: AppColors.onSecondary),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: GoogleFonts.sourceSansProTextTheme(),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      elevation: 0.0,
      iconTheme: IconThemeData(
        color: AppColors.gomoRed,
      ),
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.white,
          // fontFamily: Variables.kBaseFontFamily,
          fontFamily: FontFamily.proximaNova,
          fontWeight: FontWeight.normal,
          fontSize: 20.0,
        ),
      ),
    ),
  );
}
