import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import '../shared/providers/app_providers.dart';

/// Root widget.  Wrapped by [ProviderScope] in [main.dart].
class NgoApp extends ConsumerWidget {
  const NgoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    // Trigger FCM Token Synchronization
    ref.watch(fcmTokenSyncProvider);

    return MaterialApp.router(
      title: 'Jayashree Foundation', // <-- Updated App Name
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      theme:      AppTheme.light(),
      darkTheme:  AppTheme.dark(),
      themeMode:  themeMode.isDark ? ThemeMode.dark : ThemeMode.light,

      // ── Navigation ─────────────────────────────────────────────────────────
      routerConfig: router,
    );
  }
}