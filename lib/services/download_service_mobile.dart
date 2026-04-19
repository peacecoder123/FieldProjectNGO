import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mobile implementation of DownloadService.
/// Saves bytes to a temporary file and opens the system share sheet.
class DownloadService {
  static Future<void> downloadBytes(Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Use shareXFiles to allow the user to save or send the document
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: fileName,
    );
  }
}
