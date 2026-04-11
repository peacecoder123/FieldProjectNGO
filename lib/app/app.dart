import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import '../shared/providers/app_providers.dart';
import '../features/public/presentation/screens/splash_screen.dart';

/// Root widget.  Wrapped by [ProviderScope] in [main.dart].
class NgoApp extends ConsumerStatefulWidget {
  const NgoApp({super.key});

  @override
  ConsumerState<NgoApp> createState() => _NgoAppState();
}

class _NgoAppState extends ConsumerState<NgoApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    // Trigger FCM Token Synchronization
    ref.watch(fcmTokenSyncProvider);

    return MaterialApp.router(
      title: 'Jayashree Foundation',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      theme:      AppTheme.light(),
      darkTheme:  AppTheme.dark(),
      themeMode:  themeMode.isDark ? ThemeMode.dark : ThemeMode.light,

      // ── Navigation ─────────────────────────────────────────────────────────
      routerConfig: router,

      // ── One-time splash overlay ────────────────────────────────────────────
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (_showSplash)
              SplashScreen(
                onFinished: () {
                  if (mounted) setState(() => _showSplash = false);
                },
              ),
          ],
        );
      },
    );
  }
}