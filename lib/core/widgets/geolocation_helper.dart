import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

// Web-only geolocation — conditional import avoids mobile compilation issues
import 'web_geolocation_stub.dart'
    if (dart.library.html) 'web_geolocation.dart';

/// Cross-platform geolocation helper.
class GeolocationHelper {
  static Future<String> getCurrentGeotag() async {
    if (kIsWeb) {
      try {
        return await getWebGeolocation();
      } catch (e) {
        return 'Location unavailable';
      }
    }
    return _getMobileGeolocation();
  }

  static Future<String> _getMobileGeolocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Location services disabled';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permission denied';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return 'Location permission permanently denied';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return '${position.latitude.toStringAsFixed(6)}, '
          '${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      return 'Location unavailable';
    }
  }
}
