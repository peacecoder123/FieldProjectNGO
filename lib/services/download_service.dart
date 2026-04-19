export 'download_service_mobile.dart' // Default fallback for mobile/desktop
    if (dart.library.js_interop) 'download_service_web.dart';
