// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web CameraService using WebRTC getUserMedia + HtmlElementView.
class CameraService {
  web.MediaStream? _stream;
  web.HTMLVideoElement? _videoEl;
  final String _viewId = 'ngo-cam-${DateTime.now().millisecondsSinceEpoch}';
  bool _registered = false;

  Future<bool> startCamera() async {
    try {
      final constraints = web.MediaStreamConstraints(
        video: true.toJS,
        audio: false.toJS,
      );
      _stream = await web.window.navigator.mediaDevices
          .getUserMedia(constraints)
          .toDart;

      final video = web.HTMLVideoElement();
      video.srcObject = _stream;
      video.autoplay = true;
      video.muted = true;
      video.style.width = '100%';
      video.style.height = '100%';
      video.style.objectFit = 'cover';
      _videoEl = video;

      if (!_registered) {
        ui_web.platformViewRegistry.registerViewFactory(_viewId, (_) => video);
        _registered = true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List?> captureFrame() async {
    final video = _videoEl;
    if (video == null) return null;

    try {
      final w = video.videoWidth > 0 ? video.videoWidth : 640;
      final h = video.videoHeight > 0 ? video.videoHeight : 480;

      final canvas = web.HTMLCanvasElement()
        ..width = w
        ..height = h;
      final ctx = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
      ctx.drawImage(video, 0, 0);

      final dataUrl = canvas.toDataURL('image/jpeg', 0.85.toJS);
      final b64 = dataUrl.split(',').last;
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  void stopCamera() {
    try {
      _stream?.getTracks().toDart.forEach((t) => t.stop());
    } catch (_) {}
    _stream = null;
    _videoEl = null;
  }

  void dispose() => stopCamera();

  Widget buildPreview() => HtmlElementView(viewType: _viewId);
}
