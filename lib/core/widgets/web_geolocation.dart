// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Web-only: uses browser navigator.geolocation to get lat/long.
Future<String> getWebGeolocation() async {
  final completer = Completer<String>();
  final geo = web.window.navigator.geolocation;

  geo.getCurrentPosition(
    (web.GeolocationPosition pos) {
      if (!completer.isCompleted) {
        final lat = pos.coords.latitude.toStringAsFixed(6);
        final lng = pos.coords.longitude.toStringAsFixed(6);
        completer.complete('$lat, $lng');
      }
    }.toJS,
    (web.GeolocationPositionError err) {
      if (!completer.isCompleted) {
        completer.complete('Location denied by user');
      }
    }.toJS,
  );

  return completer.future.timeout(
    const Duration(seconds: 12),
    onTimeout: () => 'Location timeout',
  );
}
