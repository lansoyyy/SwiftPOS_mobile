import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// App text styles for SwiftPOS using Urbanist font family
class AppTextStyles {
  AppTextStyles._();

  // Font Family
  static const String fontFamily = 'Urbanist';

  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Button Styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.25,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.29,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  // Caption Styles
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.60,
  );

  // Custom Styles with Colors
  // Primary Text
  static TextStyle get h1 =>
      displayLarge.copyWith(color: AppColors.textPrimary);
  static TextStyle get h2 =>
      displayMedium.copyWith(color: AppColors.textPrimary);
  static TextStyle get h3 =>
      displaySmall.copyWith(color: AppColors.textPrimary);
  static TextStyle get h4 =>
      headlineLarge.copyWith(color: AppColors.textPrimary);
  static TextStyle get h5 =>
      headlineMedium.copyWith(color: AppColors.textPrimary);
  static TextStyle get h6 =>
      headlineSmall.copyWith(color: AppColors.textPrimary);

  // Body Text
  static TextStyle get body => bodyLarge.copyWith(color: AppColors.textPrimary);
  static TextStyle get bodySecondary =>
      bodyMedium.copyWith(color: AppColors.textSecondary);
  static TextStyle get bodyTertiary =>
      bodySmall.copyWith(color: AppColors.textTertiary);

  // Title Text
  static TextStyle get title =>
      titleLarge.copyWith(color: AppColors.textPrimary);
  static TextStyle get titleSecondary =>
      titleMedium.copyWith(color: AppColors.textPrimary);
  static TextStyle get titleTertiary =>
      titleSmall.copyWith(color: AppColors.textPrimary);

  // Label Text
  static TextStyle get label =>
      labelLarge.copyWith(color: AppColors.textPrimary);
  static TextStyle get labelSecondary =>
      labelMedium.copyWith(color: AppColors.textSecondary);

  // Button Text
  static TextStyle get buttonText =>
      buttonLarge.copyWith(color: AppColors.textOnPrimary);
  static TextStyle get buttonTextSecondary =>
      buttonMedium.copyWith(color: AppColors.textOnPrimary);

  // Caption Text
  static TextStyle get captionText =>
      caption.copyWith(color: AppColors.textTertiary);
  static TextStyle get overlineText =>
      overline.copyWith(color: AppColors.textTertiary);

  // Colored Text Styles
  static TextStyle primaryText(TextStyle style) =>
      style.copyWith(color: AppColors.primary);
  static TextStyle secondaryText(TextStyle style) =>
      style.copyWith(color: AppColors.secondary);
  static TextStyle accentText(TextStyle style) =>
      style.copyWith(color: AppColors.accent);
  static TextStyle successText(TextStyle style) =>
      style.copyWith(color: AppColors.success);
  static TextStyle errorText(TextStyle style) =>
      style.copyWith(color: AppColors.error);
  static TextStyle warningText(TextStyle style) =>
      style.copyWith(color: AppColors.warning);
  static TextStyle infoText(TextStyle style) =>
      style.copyWith(color: AppColors.info);
}
