import 'dart:async';

/// Stub for non-web platforms. Never called on mobile because of kIsWeb guard.
Future<String> getWebGeolocation() async {
  return 'Location unavailable';
}
