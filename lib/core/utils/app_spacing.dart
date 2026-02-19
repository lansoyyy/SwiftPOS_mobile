import 'package:flutter/widgets.dart';

/// App spacing constants for SwiftPOS
class AppSpacing {
  AppSpacing._();

  // Extra Small Spacing
  static const double xs = 4.0;
  static const double xs2 = 8.0;

  // Small Spacing
  static const double sm = 12.0;
  static const double sm2 = 16.0;

  // Medium Spacing
  static const double md = 20.0;
  static const double md2 = 24.0;

  // Large Spacing
  static const double lg = 32.0;
  static const double lg2 = 40.0;

  // Extra Large Spacing
  static const double xl = 48.0;
  static const double xl2 = 56.0;

  // Extra Extra Large Spacing
  static const double xxl = 64.0;
  static const double xxl2 = 80.0;

  // Screen Padding
  static const double screenPadding = 16.0;
  static const double screenPaddingLarge = 24.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // SizedBox helpers
  static const SizedBox wXs = SizedBox(width: xs);
  static const SizedBox wXs2 = SizedBox(width: xs2);
  static const SizedBox wSm = SizedBox(width: sm);
  static const SizedBox wSm2 = SizedBox(width: sm2);
  static const SizedBox wMd = SizedBox(width: md);
  static const SizedBox wMd2 = SizedBox(width: md2);
  static const SizedBox wLg = SizedBox(width: lg);
  static const SizedBox wLg2 = SizedBox(width: lg2);
  static const SizedBox wXl = SizedBox(width: xl);
  static const SizedBox wXl2 = SizedBox(width: xl2);

  static const SizedBox hXs = SizedBox(height: xs);
  static const SizedBox hXs2 = SizedBox(height: xs2);
  static const SizedBox hSm = SizedBox(height: sm);
  static const SizedBox hSm2 = SizedBox(height: sm2);
  static const SizedBox hMd = SizedBox(height: md);
  static const SizedBox hMd2 = SizedBox(height: md2);
  static const SizedBox hLg = SizedBox(height: lg);
  static const SizedBox hLg2 = SizedBox(height: lg2);
  static const SizedBox hXl = SizedBox(height: xl);
  static const SizedBox hXl2 = SizedBox(height: xl2);

  // EdgeInsets helpers
  static const EdgeInsets pXs = EdgeInsets.all(xs);
  static const EdgeInsets pXs2 = EdgeInsets.all(xs2);
  static const EdgeInsets pSm = EdgeInsets.all(sm);
  static const EdgeInsets pSm2 = EdgeInsets.all(sm2);
  static const EdgeInsets pMd = EdgeInsets.all(md);
  static const EdgeInsets pMd2 = EdgeInsets.all(md2);
  static const EdgeInsets pLg = EdgeInsets.all(lg);
  static const EdgeInsets pLg2 = EdgeInsets.all(lg2);

  static const EdgeInsets pHXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets pHXs2 = EdgeInsets.symmetric(horizontal: xs2);
  static const EdgeInsets pHSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets pHSm2 = EdgeInsets.symmetric(horizontal: sm2);
  static const EdgeInsets pHMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pHMd2 = EdgeInsets.symmetric(horizontal: md2);
  static const EdgeInsets pHLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets pHLg2 = EdgeInsets.symmetric(horizontal: lg2);

  static const EdgeInsets pVXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets pVXs2 = EdgeInsets.symmetric(vertical: xs2);
  static const EdgeInsets pVSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets pVSm2 = EdgeInsets.symmetric(vertical: sm2);
  static const EdgeInsets pVMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets pVMd2 = EdgeInsets.symmetric(vertical: md2);
  static const EdgeInsets pVLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets pVLg2 = EdgeInsets.symmetric(vertical: lg2);

  static const EdgeInsets pScreen = EdgeInsets.all(screenPadding);
  static const EdgeInsets pScreenLarge = EdgeInsets.all(screenPaddingLarge);
  static const EdgeInsets pHScreen = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );
  static const EdgeInsets pVScreen = EdgeInsets.symmetric(
    vertical: screenPadding,
  );
}
