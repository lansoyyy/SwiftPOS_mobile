import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_sizes.dart';
import '../../core/utils/app_spacing.dart';
import 'dart:ui' as ui;

/// App Card widget for SwiftPOS
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? elevation;
  final VoidCallback? onTap;
  final Border? border;
  final Clip? clipBehavior;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.onTap,
    this.border,
    this.clipBehavior,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusLg,
        ),
        border: border,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: shadowColor ?? AppColors.shadow,
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      clipBehavior: clipBehavior ?? ui.Clip.none,
      child: Padding(padding: padding ?? AppSpacing.pMd, child: child),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusLg,
        ),
        child: card,
      );
    }

    return card;
  }
}

/// App Card with elevation
class AppElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Border? border;
  final double? width;
  final double? height;

  const AppElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: child,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      elevation: AppSizes.elevationMd,
      onTap: onTap,
      border: border,
      width: width,
      height: height,
    );
  }
}

/// App Card with border
class AppBorderedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AppBorderedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: child,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      elevation: AppSizes.elevationNone,
      onTap: onTap,
      border: Border.all(color: borderColor ?? AppColors.border),
      width: width,
      height: height,
    );
  }
}
