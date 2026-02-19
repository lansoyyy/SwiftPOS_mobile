import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_sizes.dart';
import '../../core/utils/app_spacing.dart';
import '../text/app_text.dart';

/// App Input Field widget for SwiftPOS
class AppInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final String? errorText;
  final String? helperText;
  final String? counterText;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final bool showCounter;

  const AppInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.errorText,
    this.helperText,
    this.counterText,
    this.isDense = false,
    this.contentPadding,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          AppLabelMedium(
            label!,
            color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
          ),
          AppSpacing.hXs,
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyMedium.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            helperText: helperText,
            counterText: showCounter ? null : '',
            isDense: isDense,
            filled: true,
            fillColor:
                fillColor ?? (enabled ? AppColors.gray50 : AppColors.gray100),
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixText: prefixText,
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppSpacing.radiusMd,
              ),
              borderSide: BorderSide(color: borderColor ?? AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppSpacing.radiusMd,
              ),
              borderSide: BorderSide(color: borderColor ?? AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppSpacing.radiusMd,
              ),
              borderSide: BorderSide(
                color: focusedBorderColor ?? AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppSpacing.radiusMd,
              ),
              borderSide: BorderSide(
                color: errorBorderColor ?? AppColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppSpacing.radiusMd,
              ),
              borderSide: BorderSide(
                color: errorBorderColor ?? AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppSpacing.radiusMd,
              ),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            labelStyle: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      ],
    );
  }
}

/// App Search Input Field
class AppSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;

  const AppSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      hint: hint ?? AppStrings.search,
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      enabled: enabled,
      prefixIcon: const Icon(Icons.search_outlined, size: 20),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClear ?? () => controller?.clear(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          : null,
      fillColor: AppColors.gray100,
      borderRadius: AppSpacing.radiusLg,
    );
  }
}
