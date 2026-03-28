import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import '../../features/auth/domain/entities/user_entity.dart';

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
  _CurrentUserNotifier(this._prefs) : super(_loadFromPrefs(_prefs));

  final SharedPreferences _prefs;

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
  }

  void logout() {
    state = null;
    _prefs.remove(AppConstants.prefCurrentUser);
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