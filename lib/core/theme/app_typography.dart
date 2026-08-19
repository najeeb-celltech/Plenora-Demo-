import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Display & Main Headings
  static TextStyle headlineLarge = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle headlineMedium = GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headlineOnboarding = GoogleFonts.nunito(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
    height: 1.25,
  );

  static TextStyle titleLarge = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle titleSmall = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Styles
  static TextStyle bodyLarge = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle bodyMedium = GoogleFonts.nunito(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Buttons & Labels
  static TextStyle buttonText = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  static TextStyle chipText = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static TextStyle ratingText = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
}
