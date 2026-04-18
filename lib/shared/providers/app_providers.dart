import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'package:ngo_volunteer_management/services/document_generation/document_generator.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';
import 'package:ngo_volunteer_management/services/notification_service.dart';
import 'dart:async';

// ── Infrastructure ────────────────────────────────────────────────────────────

/// Provided via [ProviderScope.overrides] in [main.dart] — never constructed
/// inside the provider graph itself.
final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError(
          'sharedPreferencesProvider must be overridden in main.dart',
        ));

// ── Theme ─────────────────────────────────────────────────────────────────────

/// Persisted theme preference — mirrors React `theme` / `toggleTheme`.
final themeModeProvider =
    StateNotifierProvider<_ThemeModeNotifier, AppThemeMode>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _ThemeModeNotifier(prefs);
  },
);

class _ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  _ThemeModeNotifier(this._prefs)
      : super(
          _prefs.getString(AppConstants.prefThemeMode) == 'dark'
              ? AppThemeMode.dark
              : AppThemeMode.light,
        );

  final SharedPreferences _prefs;

  void toggle() {
    final next = state.isDark ? AppThemeMode.light : AppThemeMode.dark;
    state = next;
    _prefs.setString(AppConstants.prefThemeMode, next.name);
  }
}

// ── Current user ──────────────────────────────────────────────────────────────

/// The authenticated user, or `null` when logged out.
/// Mirrors React `currentUser` from AppContext.
final currentUserProvider =
    StateNotifierProvider<_CurrentUserNotifier, UserEntity?>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _CurrentUserNotifier(prefs);
  },
);

class _CurrentUserNotifier extends StateNotifier<UserEntity?> {
  _CurrentUserNotifier(this._prefs) : super(_loadFromPrefs(_prefs)) {
    // If we have a user from prefs on startup, start listening
    if (state != null) {
      _startDocumentListener(state!.id);
    }
  }

  final SharedPreferences _prefs;
  StreamSubscription? _docSubscription;

  static UserEntity? _loadFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(AppConstants.prefCurrentUser);
    if (raw == null) return null;
    try {
      return UserEntity.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  void login(UserEntity user) {
    state = user;
    _prefs.setString(
      AppConstants.prefCurrentUser,
      jsonEncode(user.toJson()),
    );
    _startDocumentListener(user.id);
  }

  void logout() {
    _docSubscription?.cancel();
    state = null;
    _prefs.remove(AppConstants.prefCurrentUser);
  }

  void _startDocumentListener(String userId) {
    _docSubscription?.cancel();
    if (userId.isEmpty) return;

    _docSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final updatedUser = _fromDoc(snapshot);
        if (updatedUser != state) {
          state = updatedUser;
          _prefs.setString(
            AppConstants.prefCurrentUser,
            jsonEncode(updatedUser.toJson()),
          );
          debugPrint('Real-time Update: Current user data synced from Firestore.');
        }
      }
    });
  }

  UserEntity _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final roleStr = data['role'] as String? ?? 'volunteer';
    
    final role = UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == roleStr.toLowerCase().trim(),
      orElse: () => UserRole.volunteer,
    );

    return UserEntity(
      id:                doc.id,
      email:             data['email'] ?? '',
      name:              data['name']  ?? '',
      role:              role,
      avatar:            data['avatar'] as String?,
      fcmToken:          data['fcmToken'] as String?,
      inviteEmailSentAt: data['inviteEmailSentAt'] != null 
          ? (data['inviteEmailSentAt'] as Timestamp).toDate() 
          : null,
    );
  }

  @override
  void dispose() {
    _docSubscription?.cancel();
    super.dispose();
  }
}

// ── Convenience read-only providers ──────────────────────────────────────────

/// `true` when the user is logged in.
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider) != null,
);

/// The current user's role, or `null` when logged out.
final currentRoleProvider = Provider<UserRole?>(
  (ref) => ref.watch(currentUserProvider)?.role,
);

// ── Document Generation ──────────────────────────────────────────────────────

/// Singleton instance of the dynamic template engine.
/// Use `ref.read(documentGeneratorProvider)` to access it.
final documentGeneratorProvider = Provider<DocumentGenerator>(
  (ref) => DocumentGenerator(),
);

/// Provider to synchronize the device's FCM token with the backend.
/// It watches the currentUser state and triggers an update whenever a user logs in.
final fcmTokenSyncProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  final authRepo = ref.watch(authRepositoryProvider);

  if (user != null) {
    debugPrint('Sync: User ${user.email} detected. Attempting FCM sync...');
    // Small delay to ensure browser/Firebase is fully settled
    Future.delayed(const Duration(seconds: 2), () {
      PushNotificationService.instance.getFcmToken().then((token) {
        if (token != null) {
          debugPrint('Sync: Token obtained successfully. Updating Firestore...');
          authRepo.updateFcmToken(user.id, token);
        } else {
          debugPrint('Sync: Could not obtain FCM token. Check console for errors.');
        }
      });
    });
  } else {
    debugPrint('Sync: No user logged in. FCM sync skipped.');
  }
});