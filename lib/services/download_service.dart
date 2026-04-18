import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Service to handle file downloads specifically for Flutter Web.
/// Bypasses the printing package's overlay issues by using native browser APIs.
class DownloadService {
  static void downloadBytes(Uint8List bytes, String fileName) {
    // Create a blob from the bytes
    final blob = web.Blob([bytes.toJS].toJS);
    
    // Create an object URL for the blob
    final url = web.URL.createObjectURL(blob);
    
    // Create a temporary anchor element and trigger a download
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = fileName;
    
    web.document.body?.appendChild(anchor);
    anchor.click();
    
    // Cleanup
    web.document.body?.removeChild(anchor);
    web.URL.revokeObjectURL(url);
  }
}
