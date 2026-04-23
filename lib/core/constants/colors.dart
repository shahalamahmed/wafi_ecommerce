import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color bgPrimary = Color(0xFF0F1115);
  static const Color bgSecondary = Color(0xFF171B22);
  static const Color bgTertiary = Color(0xFF111827);

  static const Color bgPrimaryLight = Color(0xFFF7F4EE);
  static const Color bgSecondaryLight = Color(0xFFEEEAE3);
  static const Color bgTertiaryLight = Color(0xFFFCFBF8);

  // Glass Surface
  static const Color glassSurface = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x24FFFFFF);
  static const Color glassShine = Color(0x24FFFFFF);
  static const Color glassSurfaceLight = Color(0xE8FFFFFF);
  static const Color glassBorderLight = Color(0x1F16202D);
  static const Color glassShineLight = Color(0xB3FFFFFF);

  // Primary
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color purple = Color(0xFFB45309);

  // Status
  static const Color success = Color(0xFF50E8A0);
  static const Color warning = Color(0xFFFFB040);
  static const Color error = Color(0xFFFF5555);
  static const Color info = Color(0xFF64A0FF);

  // Text
  static const Color textPrimary = Color(0xEEFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF);
  static const Color textHint = Color(0x66FFFFFF);
  static const Color textPrimaryLight = Color(0xFF14181F);
  static const Color textSecondaryLight = Color(0xFF5C6370);
  static const Color textHintLight = Color(0xFF8A91A3);

  // Badge
  static const Color badgeGreenBg = Color(0x3350E8A0);
  static const Color badgeGreenText = Color(0xFF50E8A0);
  static const Color badgeAmberBg = Color(0x33FFB040);
  static const Color badgeAmberText = Color(0xFFFFB040);

  static Color glassSurfaceFor(Brightness brightness) {
    return brightness == Brightness.dark ? glassSurface : glassSurfaceLight;
  }

  static Color glassBorderFor(Brightness brightness) {
    return brightness == Brightness.dark ? glassBorder : glassBorderLight;
  }

  static Color glassShineFor(Brightness brightness) {
    return brightness == Brightness.dark ? glassShine : glassShineLight;
  }

  static Color textPrimaryFor(Brightness brightness) {
    return brightness == Brightness.dark ? textPrimary : textPrimaryLight;
  }

  static Color textSecondaryFor(Brightness brightness) {
    return brightness == Brightness.dark ? textSecondary : textSecondaryLight;
  }

  static Color textHintFor(Brightness brightness) {
    return brightness == Brightness.dark ? textHint : textHintLight;
  }
}
