import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_providers.dart';

/// Provider to manage and persist notification IDs that have been dismissed by the user.
final dismissedNotifsProvider = StateNotifierProvider<DismissedNotifsNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DismissedNotifsNotifier(prefs);
});

class DismissedNotifsNotifier extends StateNotifier<Set<String>> {
  DismissedNotifsNotifier(this._prefs) : super(_loadFromPrefs(_prefs));

  final SharedPreferences _prefs;
  static const _key = 'dismissed_notifications';

  static Set<String> _loadFromPrefs(SharedPreferences prefs) {
    final list = prefs.getStringList(_key);
    return (list ?? []).toSet();
  }

  /// Adds a list of notification IDs to the dismissed set and persists them.
  void dismissAll(List<String> ids) {
    state = {...state, ...ids};
    _prefs.setStringList(_key, state.toList());
  }

  /// Clears all dismissed notifications (optional utility).
  void clear() {
    state = {};
    _prefs.remove(_key);
  }
}
