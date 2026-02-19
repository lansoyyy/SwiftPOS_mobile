import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_sizes.dart';
import '../../core/utils/app_spacing.dart';
import '../text/app_text.dart';

/// App Avatar widget for SwiftPOS
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final Widget? icon;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.size,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? AppSizes.avatarLg;
    final initials = _getInitials(name ?? '');

    Widget avatarContent;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: Image.network(
          imageUrl!,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar(initials, avatarSize);
          },
        ),
      );
    } else if (icon != null) {
      avatarContent = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.gray200,
          shape: BoxShape.circle,
        ),
        child: IconTheme(
          data: IconThemeData(
            size: avatarSize * 0.5,
            color: textColor ?? AppColors.textSecondary,
          ),
          child: icon!,
        ),
      );
    } else if (initials.isNotEmpty) {
      avatarContent = _buildInitialsAvatar(initials, avatarSize);
    } else {
      avatarContent = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.gray200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          size: avatarSize * 0.5,
          color: textColor ?? AppColors.textSecondary,
        ),
      );
    }

    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: showBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? AppColors.border,
                width: borderWidth ?? AppSizes.strokeWidthNormal,
              ),
            )
          : null,
      child: avatarContent,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitialsAvatar(String initials, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? _getBackgroundColor(initials),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppText(
          initials,
          style: AppTextStyles.titleLarge.copyWith(
            color: textColor ?? AppColors.white,
            fontSize: size * 0.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }

  Color _getBackgroundColor(String initials) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.error,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];
    final index = initials.hashCode % colors.length;
    return colors[index.abs()];
  }
}

/// Small Avatar
class AppAvatarSmall extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const AppAvatarSmall({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      imageUrl: imageUrl,
      name: name,
      icon: icon,
      size: AppSizes.avatarSm,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onTap: onTap,
    );
  }
}

/// Medium Avatar
class AppAvatarMedium extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const AppAvatarMedium({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      imageUrl: imageUrl,
      name: name,
      icon: icon,
      size: AppSizes.avatarMd,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onTap: onTap,
    );
  }
}

/// Large Avatar
class AppAvatarLarge extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const AppAvatarLarge({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      imageUrl: imageUrl,
      name: name,
      icon: icon,
      size: AppSizes.avatarLg,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onTap: onTap,
    );
  }
}
