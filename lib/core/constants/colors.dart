import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background (Dark Deep)
  static const Color bgPrimary   = Color(0xFF0A0A1A);
  static const Color bgSecondary = Color(0xFF0D1B3E);
  static const Color bgTertiary  = Color(0xFF1A0A2E);

  // Background (Light Glass)
  static const Color bgPrimaryLight   = Color(0xFFF3F7FF);
  static const Color bgSecondaryLight = Color(0xFFE7F0FF);
  static const Color bgTertiaryLight  = Color(0xFFF9FBFF);

  // Glass Surface
  static const Color glassSurface = Color(0x12FFFFFF);
  static const Color glassBorder  = Color(0x2EFFFFFF);
  static const Color glassShine   = Color(0x26FFFFFF);
  static const Color glassSurfaceLight = Color(0xCCFFFFFF);
  static const Color glassBorderLight  = Color(0x1F102040);
  static const Color glassShineLight   = Color(0x99FFFFFF);

  // Primary
  static const Color primary      = Color(0xFF64A0FF);
  static const Color primaryDark  = Color(0xFF3C64DC);
  static const Color purple       = Color(0xFFA064FF);

  // Status
  static const Color success  = Color(0xFF50E8A0);
  static const Color warning  = Color(0xFFFFB040);
  static const Color error    = Color(0xFFFF5555);
  static const Color info     = Color(0xFF64A0FF);

  // Text
  static const Color textPrimary   = Color(0xD9FFFFFF);
  static const Color textSecondary = Color(0x66FFFFFF);
  static const Color textHint      = Color(0x4DFFFFFF);
  static const Color textPrimaryLight   = Color(0xFF101426);
  static const Color textSecondaryLight = Color(0xFF5F6980);
  static const Color textHintLight      = Color(0xFF8D96AA);

  // Badge
  static const Color badgeGreenBg   = Color(0x3350E8A0);
  static const Color badgeGreenText = Color(0xFF50E8A0);
  static const Color badgeAmberBg   = Color(0x33FFB040);
  static const Color badgeAmberText = Color(0xFFFFB040);

  static Color glassSurfaceFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? glassSurface
        : glassSurfaceLight;
  }

  static Color glassBorderFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? glassBorder
        : glassBorderLight;
  }

  static Color glassShineFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? glassShine
        : glassShineLight;
  }

  static Color textPrimaryFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? textPrimary
        : textPrimaryLight;
  }

  static Color textSecondaryFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? textSecondary
        : textSecondaryLight;
  }

  static Color textHintFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? textHint
        : textHintLight;
  }
}
