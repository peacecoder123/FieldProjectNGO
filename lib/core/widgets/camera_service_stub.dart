import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Stub CameraService for non-web platforms (Android, iOS, Windows).
/// Mobile uses native image_picker in submit_task_form.dart directly.
class CameraService {
  Future<bool> startCamera() async => false;
  Future<Uint8List?> captureFrame() async => null;
  void stopCamera() {}
  void dispose() {}
  Widget buildPreview() => const SizedBox.shrink();
}
