import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';

class SnackbarMessage {
  const SnackbarMessage._();

  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: _GlassSnackbarContent(message: message, isError: isError),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          padding: EdgeInsets
              .zero, // Content à¦¨à¦¿à¦œà§‡à¦‡ padding handle à¦•à¦°à¦¬à§‡
        ),
      );
  }
}

class _GlassSnackbarContent extends StatelessWidget {
  final String message;
  final bool isError;

  const _GlassSnackbarContent({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.success;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Blur effect
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.25), // Semi-transparent background
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.5), // Glass border
              width: 1.2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.15),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon with glow effect
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
