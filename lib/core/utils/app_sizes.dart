import 'package:flutter/widgets.dart';

/// App size constants for SwiftPOS
class AppSizes {
  AppSizes._();

  // Icon Sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // Button Heights
  static const double buttonSm = 36.0;
  static const double buttonMd = 44.0;
  static const double buttonLg = 52.0;
  static const double buttonXl = 60.0;

  // Input Field Heights
  static const double inputSm = 40.0;
  static const double inputMd = 48.0;
  static const double inputLg = 56.0;

  // Avatar Sizes
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 48.0;
  static const double avatarXl = 64.0;
  static const double avatarXxl = 96.0;

  // Card Elevation
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0;
  static const double elevationMd = 2.0;
  static const double elevationLg = 4.0;
  static const double elevationXl = 8.0;
  static const double elevationXxl = 12.0;

  // Stroke Width
  static const double strokeWidthThin = 1.0;
  static const double strokeWidthNormal = 1.5;
  static const double strokeWidthThick = 2.0;
  static const double strokeWidthExtraThick = 3.0;

  // Opacity
  static const double opacityDisabled = 0.38;
  static const double opacitySecondary = 0.60;
  static const double opacityPrimary = 0.87;
  static const double opacityHover = 0.08;
  static const double opacityFocus = 0.12;
  static const double opacityPressed = 0.16;
  static const double opacitySelected = 0.20;
  static const double opacityActivated = 0.12;

  // Animation Duration
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationSlower = Duration(milliseconds: 500);

  // Animation Curve
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveFastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveBounce = Curves.bounceOut;

  // Breakpoints (for responsive design)
  static const double breakpointSm = 576.0;
  static const double breakpointMd = 768.0;
  static const double breakpointLg = 992.0;
  static const double breakpointXl = 1200.0;
  static const double breakpointXxl = 1400.0;

  // Max Widths
  static const double maxWidthSm = 576.0;
  static const double maxWidthMd = 768.0;
  static const double maxWidthLg = 992.0;
  static const double maxWidthXl = 1200.0;
  static const double maxWidthXxl = 1400.0;
  static const double maxWidthContainer = 1200.0;

  // Image Sizes
  static const double imageThumbnail = 64.0;
  static const double imageSmall = 128.0;
  static const double imageMedium = 256.0;
  static const double imageLarge = 512.0;
  static const double imageXLarge = 1024.0;

  // Divider Thickness
  static const double dividerThin = 0.5;
  static const double dividerNormal = 1.0;
  static const double dividerThick = 2.0;

  // List Item Height
  static const double listItemSm = 48.0;
  static const double listItemMd = 56.0;
  static const double listItemLg = 72.0;

  // Chip Height
  static const double chipSm = 24.0;
  static const double chipMd = 32.0;
  static const double chipLg = 40.0;

  // Tab Bar Height
  static const double tabBarHeight = 48.0;

  // Bottom Navigation Bar Height
  static const double bottomNavHeight = 56.0;

  // AppBar Height
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 64.0;

  // Bottom Sheet Radius
  static const double bottomSheetRadius = 20.0;

  // Dialog Radius
  static const double dialogRadius = 20.0;
}
