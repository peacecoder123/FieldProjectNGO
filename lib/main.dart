import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'shared/providers/app_providers.dart';
import 'services/data_seeder.dart';
import 'services/notification_service.dart';

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

  // Load core services concurrently to save startup time
  final initializationResults = await Future.wait([
    SharedPreferences.getInstance(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  final prefs = initializationResults[0] as SharedPreferences;
  // Firebase initialized in initializationResults[1]

  // Initialize Notifications in background (non-blocking for startup)
  PushNotificationService.instance.initialize().catchError((e) {
    debugPrint('Warning: Non-blocking Notification initialization error: $e');
  });

  // Clear old boolean-flag key in case it exists from a previous version
  prefs.remove('firestore_seeded');

  // Seed Firestore with demo data (DISABLED as per user request to use real data only)
  /*
  try {
    await seedFirestoreIfEmpty();
  } catch (e) {
    debugPrint('Warning: Optional Firestore seeding failed (likely offline): $e');
  }
  */

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