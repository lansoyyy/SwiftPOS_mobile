import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_sizes.dart';
import '../../core/utils/app_spacing.dart';
import '../text/app_text.dart';

/// App Button widget for SwiftPOS
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isOutlined;
  final bool isTextButton;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? iconSpacing;
  final EdgeInsets? padding;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isOutlined = false,
    this.isTextButton = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSpacing,
    this.padding,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDisabled = isDisabled || isLoading;
    final effectiveOnPressed = effectiveDisabled ? null : onPressed;

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppColors.textOnPrimary,
              ),
            ),
          )
        : _buildButtonContent();

    if (isTextButton) {
      return TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.gray400,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.buttonMedium,
        ),
        child: buttonChild,
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.gray400,
          side: BorderSide(color: borderColor ?? AppColors.border, width: 1.5),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSpacing.radiusMd,
            ),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
        child: buttonChild,
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height ?? AppSizes.buttonLg,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.gray300,
          foregroundColor: textColor ?? AppColors.textOnPrimary,
          elevation: 0,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSpacing.radiusMd,
            ),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
        child: buttonChild,
      ),
    );
  }

  Widget _buildButtonContent() {
    final spacing = iconSpacing ?? AppSpacing.sm2;

    if (prefixIcon != null && suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefixIcon!,
          SizedBox(width: spacing),
          Flexible(child: AppButtonLabel(text)),
          SizedBox(width: spacing),
          suffixIcon!,
        ],
      );
    } else if (prefixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefixIcon!,
          SizedBox(width: spacing),
          Flexible(child: AppButtonLabel(text)),
        ],
      );
    } else if (suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: AppButtonLabel(text)),
          SizedBox(width: spacing),
          suffixIcon!,
        ],
      );
    }

    return AppButtonLabel(text);
  }
}

class AppButtonLabel extends StatelessWidget {
  final String text;

  const AppButtonLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyles.buttonLarge,
      textAlign: TextAlign.center,
    );
  }
}

/// Primary Button
class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool fullWidth;
  final double? width;
  final double? height;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.fullWidth = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      fullWidth: fullWidth,
      width: width,
      height: height,
    );
  }
}

/// Secondary Button
class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool fullWidth;
  final double? width;
  final double? height;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.fullWidth = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      fullWidth: fullWidth,
      width: width,
      height: height,
      isOutlined: true,
    );
  }
}

/// Text Button
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final Color? textColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.textColor,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isDisabled: isDisabled,
      textColor: textColor,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isTextButton: true,
    );
  }
}
