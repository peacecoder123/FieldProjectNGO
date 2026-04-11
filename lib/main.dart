import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'shared/providers/app_providers.dart';
import 'services/data_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait + landscape (tablets need landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Status-bar style — will be overridden per-theme in AppTheme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // Load shared prefs so theme & user can be hydrated before first frame
  final prefs = await SharedPreferences.getInstance();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e, stack) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('Stack: $stack');
    // Re-throw to fail fast
    rethrow;
  }

  // Clear old boolean-flag key in case it exists from a previous version
  prefs.remove('firestore_seeded');

  // If seeder version changed, also clear any cached user session so stale
  // roles (e.g. 'admin' instead of 'superAdmin') don't persist across seeds.
  const currentSeederVersion = 'v10';
  final cachedSeederVersion = prefs.getString('firestore_seeded_v') ?? '';
  if (cachedSeederVersion != currentSeederVersion) {
    await prefs.remove('current_user_id'); // force fresh login after seed
    debugPrint('🔄 Seed version changed — cleared cached user session.');
  }

  // Seed Firestore with consistent demo data (runs only when version changes)
  await seedFirestoreIfEmpty();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the pre-loaded SharedPreferences instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NgoApp(),
    ),
  );
}