import 'package:flutter/material.dart';

/// App colors for SwiftPOS - 70-20-10 Professional Color System
/// 70% Dominant: Backgrounds, surfaces (neutral whites/grays)
/// 20% Secondary: Cards, borders, supporting UI (slate tones)
/// 10% Accent: CTAs, highlights, important actions (teal)
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════
  // 10% ACCENT COLORS - CTAs, Highlights, Important Actions
  // ═══════════════════════════════════════════════════════════════════
  // Professional Teal - trustworthy, modern, business-appropriate
  static const Color primary = Color(0xFF0D9488); // Teal 600
  static const Color primaryDark = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryBg = Color(0xFFF0FDFA); // Teal 50 - subtle bg tint

  // Secondary Accent - for secondary actions
  static const Color secondary = Color(0xFF64748B); // Slate 500
  static const Color secondaryDark = Color(0xFF475569); // Slate 600
  static const Color secondaryLight = Color(0xFF94A3B8); // Slate 400

  // ═══════════════════════════════════════════════════════════════════
  // 70% DOMINANT COLORS - Backgrounds, Surfaces, Large Areas
  // ═══════════════════════════════════════════════════════════════════
  static const Color background = Color(0xFFFAFAFA); // Neutral 50 - main bg
  static const Color surface = Color(0xFFFFFFFF); // White - cards, sheets
  static const Color surfaceVariant = Color(
    0xFFF8FAFC,
  ); // Slate 50 - alt surface

  // Neutral Grays (70% usage - text hierarchy)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0F172A); // Slate 900 - richest black
  static const Color gray50 = Color(0xFFF8FAFC); // Slate 50
  static const Color gray100 = Color(0xFFF1F5F9); // Slate 100
  static const Color gray200 = Color(0xFFE2E8F0); // Slate 200
  static const Color gray300 = Color(0xFFCBD5E1); // Slate 300
  static const Color gray400 = Color(0xFF94A3B8); // Slate 400
  static const Color gray500 = Color(0xFF64748B); // Slate 500
  static const Color gray600 = Color(0xFF475569); // Slate 600
  static const Color gray700 = Color(0xFF334155); // Slate 700
  static const Color gray800 = Color(0xFF1E293B); // Slate 800
  static const Color gray900 = Color(0xFF0F172A); // Slate 900

  // ═══════════════════════════════════════════════════════════════════
  // 20% SECONDARY COLORS - Borders, Dividers, Supporting Elements
  // ═══════════════════════════════════════════════════════════════════
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // ═══════════════════════════════════════════════════════════════════
  // TEXT COLORS - Professional hierarchy
  // ═══════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  // ═══════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS - Status indicators
  // ═══════════════════════════════════════════════════════════════════
  // Success - Teal family (matches primary)
  static const Color success = Color(0xFF0D9488); // Teal 600
  static const Color successLight = Color(0xFFF0FDFA); // Teal 50
  static const Color successDark = Color(0xFF115E59); // Teal 800

  // Error - Professional red
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFFEF2F2); // Red 50
  static const Color errorDark = Color(0xFF991B1B); // Red 800

  // Warning - Amber (kept for visibility)
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningLight = Color(0xFFFFFbeb); // Amber 50
  static const Color warningDark = Color(0xFF92400E); // Amber 800

  // Info - Slate (matches secondary)
  static const Color info = Color(0xFF475569); // Slate 600
  static const Color infoLight = Color(0xFFF8FAFC); // Slate 50
  static const Color infoDark = Color(0xFF1E293B); // Slate 800

  // ═══════════════════════════════════════════════════════════════════
  // SPECIALTY COLORS - POS-specific
  // ═══════════════════════════════════════════════════════════════════
  // Payment method colors (10% accent usage)
  static const Color cash = Color(0xFF0D9488); // Teal - same as primary
  static const Color gcash = Color(0xFF00A3E0); // GCash blue
  static const Color maya = Color(0xFF00A3E0); // Maya blue
  static const Color card = Color(0xFF6366F1); // Indigo for card

  // Category colors (subtle, professional)
  static const Color food = Color(0xFFEA580C); // Orange 600
  static const Color drinks = Color(0xFF0284C7); // Sky 500
  static const Color snacks = Color(0xFFCA8A04); // Yellow 600
  static const Color care = Color(0xFF059669); // Emerald 600
  static const Color others = Color(0xFF64748B); // Slate 500

  // ═══════════════════════════════════════════════════════════════════
  // EFFECTS
  // ═══════════════════════════════════════════════════════════════════
  static const Color shadow = Color(0x0F000000); // Subtle shadow
  static const Color shadowLight = Color(0x08000000);
  static const Color overlay = Color(0x52000000); // 32% opacity
  static const Color overlayLight = Color(0x29000000); // 16% opacity

  // Legacy compatibility (mapped to new colors)
  static const Color accent = Color(0xFF0D9488);
  static const Color accentDark = Color(0xFF0F766E);
  static const Color accentLight = Color(0xFF14B8A6);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color textOnDark = Color(0xFFFFFFFF);
}
