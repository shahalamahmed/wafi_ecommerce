import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/theme/theme.dart';
import 'package:wafi_ecommerce/core/theme/theme_provider.dart';
import 'package:wafi_ecommerce/features/auth/auth_model.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/features/auth/auth_screen.dart';
import 'package:wafi_ecommerce/shared/layout/main_layout.dart';

class WafiApp extends ConsumerStatefulWidget {
  const WafiApp({super.key});

  @override
  ConsumerState<WafiApp> createState() => _WafiAppState();
}

class _WafiAppState extends ConsumerState<WafiApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_initializeApp);
  }

  Future<void> _initializeApp() async {
    try {
      await ref.read(themeProvider.notifier).loadThemeFromPrefs();
      await ref.read(authControllerProvider.notifier).initializeAuth();
    } catch (e) {
      debugPrint("Init error: $e");
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Wafi Ecommerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.status == AuthStatus.authenticated
          ? const MainLayout()
          : const AuthScreen(),
    );
  }
}
