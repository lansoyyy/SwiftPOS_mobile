import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_sizes.dart';
import '../../core/utils/app_spacing.dart';
import '../text/app_text.dart';

/// App Chip widget for SwiftPOS
class AppChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final Widget? deleteIcon;
  final VoidCallback? onDelete;
  final VoidCallback? onSelected;
  final bool selected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppChip({
    super.key,
    required this.label,
    this.avatar,
    this.deleteIcon,
    this.onDelete,
    this.onSelected,
    this.selected = false,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.selectedTextColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = selected
        ? (selectedColor ?? AppColors.primaryLight)
        : (backgroundColor ?? AppColors.gray100);

    final effectiveTextColor = selected
        ? (selectedTextColor ?? AppColors.white)
        : (textColor ?? AppColors.textPrimary);

    final chip = Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusSm,
        ),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusSm,
        ),
        child: Padding(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[avatar!, const SizedBox(width: 8)],
              AppText(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: effectiveTextColor,
                ),
              ),
              if (deleteIcon != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  child: deleteIcon!,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return chip;
  }
}

/// Success Chip
class AppSuccessChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  final bool selected;

  const AppSuccessChip({
    super.key,
    required this.label,
    this.onDelete,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: label,
      selected: selected,
      selectedColor: AppColors.successLight,
      selectedTextColor: AppColors.successDark,
      onDelete: onDelete,
    );
  }
}

/// Error Chip
class AppErrorChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  final bool selected;

  const AppErrorChip({
    super.key,
    required this.label,
    this.onDelete,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: label,
      selected: selected,
      selectedColor: AppColors.errorLight,
      selectedTextColor: AppColors.errorDark,
      onDelete: onDelete,
    );
  }
}

/// Warning Chip
class AppWarningChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  final bool selected;

  const AppWarningChip({
    super.key,
    required this.label,
    this.onDelete,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: label,
      selected: selected,
      selectedColor: AppColors.warningLight,
      selectedTextColor: AppColors.warningDark,
      onDelete: onDelete,
    );
  }
}

/// Info Chip
class AppInfoChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  final bool selected;

  const AppInfoChip({
    super.key,
    required this.label,
    this.onDelete,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: label,
      selected: selected,
      selectedColor: AppColors.infoLight,
      selectedTextColor: AppColors.infoDark,
      onDelete: onDelete,
    );
  }
}
