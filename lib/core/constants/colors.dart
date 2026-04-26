import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Dark Backgrounds (Obsidian) ──────────────────────────────────────────
  static const Color bgPrimary    = Color(0xFF08080A);  // scaffold
  static const Color bgSecondary  = Color(0xFF111114);  // card/surface
  static const Color bgTertiary   = Color(0xFF18181C);  // elevated surface

  // ── Light Backgrounds (Arctic) ───────────────────────────────────────────
  static const Color bgPrimaryLight   = Color(0xFFFCFCFD);  // scaffold
  static const Color bgSecondaryLight = Color(0xFFFFFFFF);  // card/surface
  static const Color bgTertiaryLight  = Color(0xFFF4F4F6);  // elevated surface

  // ── Glass Surface (Dark) ─────────────────────────────────────────────────
  static const Color glassSurface      = Color(0xFF18181C);  // solid dark glass
  static const Color glassBorder       = Color(0xFF242428);  // dark border
  static const Color glassShine        = Color(0x0FFFFFFF);  // subtle shine

  // ── Glass Surface (Light) ────────────────────────────────────────────────
  static const Color glassSurfaceLight = Color(0xFFFFFFFF);  // solid white glass
  static const Color glassBorderLight  = Color(0xFFE4E4EA);  // light border
  static const Color glassShineLight   = Color(0x80FFFFFF);  // white shine

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary     = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color purple      = Color(0xFFB45309);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF50E8A0);
  static const Color warning = Color(0xFFFFB040);
  static const Color error   = Color(0xFFFF5555);
  static const Color info    = Color(0xFF64A0FF);

  // ── Text (Dark) ──────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF2F2F4);
  static const Color textSecondary = Color(0xFF8A8A96);
  static const Color textHint      = Color(0xFF3C3C44);

  // ── Text (Light) ─────────────────────────────────────────────────────────
  static const Color textPrimaryLight   = Color(0xFF0A0A0F);
  static const Color textSecondaryLight = Color(0xFF6B6B78);
  static const Color textHintLight      = Color(0xFFAAAAAB);

  // ── Badge ────────────────────────────────────────────────────────────────
  static const Color badgeGreenBg   = Color(0x2050E8A0);
  static const Color badgeGreenText = Color(0xFF50E8A0);
  static const Color badgeAmberBg   = Color(0x20FFB040);
  static const Color badgeAmberText = Color(0xFFFFB040);

  // ── Helpers ──────────────────────────────────────────────────────────────
  static Color glassSurfaceFor(Brightness b) =>
      b == Brightness.dark ? glassSurface : glassSurfaceLight;

  static Color glassBorderFor(Brightness b) =>
      b == Brightness.dark ? glassBorder : glassBorderLight;

  static Color glassShineFor(Brightness b) =>
      b == Brightness.dark ? glassShine : glassShineLight;

  static Color textPrimaryFor(Brightness b) =>
      b == Brightness.dark ? textPrimary : textPrimaryLight;

  static Color textSecondaryFor(Brightness b) =>
      b == Brightness.dark ? textSecondary : textSecondaryLight;

  static Color textHintFor(Brightness b) =>
      b == Brightness.dark ? textHint : textHintLight;
}