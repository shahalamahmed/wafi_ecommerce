import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

class AppTheme {
  AppTheme._();

  // ── DARK: Obsidian Glass ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF08080A),
      primaryColor: AppColors.primary,

      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.purple,
        surface: const Color(0xFF111114),
        surfaceContainerHighest: const Color(0xFF18181C),
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFFF2F2F4),
        onSurfaceVariant: const Color(0xFF8A8A96),
        outline: const Color(0xFF242428),
        outlineVariant: const Color(0xFF1C1C20),
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFFF2F2F4)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF08080A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.15,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: AppSizes.fontXxl,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFB0B0BC),
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFD8D8E0),
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF8A8A96),
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF52525E),
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF8A8A96),
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF2F2F4),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          side: const BorderSide(color: Color(0xFF242428), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          backgroundColor: const Color(0xFF111114),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111114),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: Color(0xFF242428), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: Color(0xFF242428), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF3C3C44),
          fontSize: AppSizes.fontMd,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF8A8A96),
          fontSize: AppSizes.fontMd,
        ),
        floatingLabelStyle: TextStyle(
          color: AppColors.primary,
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: const Color(0xFF52525E),
        suffixIconColor: const Color(0xFF52525E),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF111114),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: const BorderSide(color: Color(0xFF242428), width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: Color(0xFF8A8A96),
        textColor: Color(0xFFF2F2F4),
        subtitleTextStyle: TextStyle(
          color: Color(0xFF8A8A96),
          fontSize: AppSizes.fontSm,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF08080A),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF3C3C44),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w400,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF1C1C20),
        thickness: 1,
        space: 0,
      ),

      iconTheme: const IconThemeData(
        color: Color(0xFF52525E),
        size: AppSizes.iconMd,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF18181C),
        contentTextStyle: const TextStyle(
          color: Color(0xFFF2F2F4),
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF2A2A30), width: 1),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF3C3C44);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return const Color(0xFF1C1C20);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF3C3C44), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Color(0xFF1C1C20),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF18181C),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          color: Color(0xFF8A8A96),
          fontSize: AppSizes.fontSm,
        ),
        side: const BorderSide(color: Color(0xFF242428), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }

  // ── LIGHT: Arctic Glass ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFCFCFD),
      primaryColor: AppColors.primary,

      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.purple,
        surface: const Color(0xFFFFFFFF),
        surfaceContainerHighest: const Color(0xFFF4F4F6),
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF0A0A0F),
        onSurfaceVariant: const Color(0xFF6B6B78),
        outline: const Color(0xFFE4E4EA),
        outlineVariant: const Color(0xFFF0F0F5),
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFF0A0A0F)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFFFCFCFD),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.15,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: AppSizes.fontXxl,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF5A5A68),
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF2A2A35),
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF6B6B78),
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFFAAAAAB),
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF9A9AA8),
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0A0A0F),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          side: const BorderSide(color: Color(0xFFE4E4EA), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: Color(0xFFE4E4EA), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: Color(0xFFE4E4EA), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFCCCCD4),
          fontSize: AppSizes.fontMd,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF9A9AA8),
          fontSize: AppSizes.fontMd,
        ),
        floatingLabelStyle: TextStyle(
          color: AppColors.primary,
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: const Color(0xFFAAAAAB),
        suffixIconColor: const Color(0xFFAAAAAB),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: const BorderSide(color: Color(0xFFE8E8EE), width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.transparent,
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: Color(0xFFAAAAAB),
        textColor: Color(0xFF0A0A0F),
        subtitleTextStyle: TextStyle(
          color: Color(0xFF9A9AA8),
          fontSize: AppSizes.fontSm,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFFCCCCD4),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w400,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0F0F5),
        thickness: 1,
        space: 0,
      ),

      iconTheme: const IconThemeData(
        color: Color(0xFFAAAAAB),
        size: AppSizes.iconMd,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        contentTextStyle: const TextStyle(
          color: Color(0xFF0A0A0F),
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE4E4EA), width: 1),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFFDDDDE4);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return const Color(0xFFF0F0F5);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return const Color(0xFFE4E4EA);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFFCCCCD4), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primary.withValues(alpha: 0.1),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF4F4F6),
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        labelStyle: const TextStyle(
          color: Color(0xFF6B6B78),
          fontSize: AppSizes.fontSm,
        ),
        side: const BorderSide(color: Color(0xFFE8E8EE), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}