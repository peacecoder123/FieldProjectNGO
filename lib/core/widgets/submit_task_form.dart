// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'geolocation_helper.dart';

// Conditional import: web version uses WebRTC
// Mobile version uses image_picker camera
import 'camera_service_stub.dart'
    if (dart.library.js_interop) 'camera_service_web.dart';

class SubmitTaskForm extends StatefulWidget {
  const SubmitTaskForm({super.key, required this.onSubmit});
  final Function(String imageUrl, String geotag) onSubmit;

  @override
  State<SubmitTaskForm> createState() => _SubmitTaskFormState();
}

class _SubmitTaskFormState extends State<SubmitTaskForm> {
  Uint8List? _capturedBytes;
  String _geotag = '';
  bool _isCapturing = false;
  bool _showCamera = false;
  bool _isSubmitting = false;

  // Camera service (web or stub)
  CameraService? _cameraService;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _cameraService = CameraService();
    }
  }

  @override
  void dispose() {
    _cameraService?.dispose();
    super.dispose();
  }

  // ── Web camera flow ─────────────────────────────────────────────────────────
  Future<void> _startWebCamera() async {
    setState(() {
      _isCapturing = true;
      _geotag = 'Fetching GPS...';
    });
    try {
      final tag = await GeolocationHelper.getCurrentGeotag();
      setState(() => _geotag = tag);
      
      final success = await _cameraService!.startCamera();
      if (success) {
        setState(() {
          _showCamera = true;
          _isCapturing = false;
        });
      } else {
        setState(() => _isCapturing = false);
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _geotag = 'Location Error';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera/location error: $e'), backgroundColor: AppColors.red600),
        );
      }
    }
  }

  Future<void> _captureFrame() async {
    setState(() => _isCapturing = true);
    try {
      final bytes = await _cameraService!.captureFrame();
      if (bytes != null) {
        _cameraService!.stopCamera();
        setState(() {
          _capturedBytes = bytes;
          _showCamera = false;
          _isCapturing = false;
        });
      } else {
        setState(() => _isCapturing = false);
      }
    } catch (e) {
      setState(() => _isCapturing = false);
    }
  }

  // ── Mobile camera flow ──────────────────────────────────────────────────────
  Future<void> _captureMobile() async {
    setState(() {
      _isCapturing = true;
      _geotag = 'Fetching GPS...';
    });
    try {
      final tag = await GeolocationHelper.getCurrentGeotag();
      setState(() => _geotag = tag);

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _capturedBytes = bytes);
      }
    } catch (e) {
      setState(() => _geotag = 'Location Error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red600),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _retake() {
    _cameraService?.stopCamera();
    setState(() {
      _capturedBytes = null;
      _geotag = '';
      _showCamera = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Provide a photo proof of task completion. Your GPS location will be geotagged automatically.',
          style: TextStyle(fontSize: 14, color: AppColors.slate600),
        ),
        const SizedBox(height: 16),
        Container(
          height: 240,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
          ),
          child: _buildBody(),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: (_capturedBytes == null || _isSubmitting)
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  try {
                    await widget.onSubmit(
                      'data:image/jpeg;base64,${base64Encode(_capturedBytes!)}',
                      _geotag,
                    );
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
          icon: _isSubmitting 
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check_circle_rounded),
          label: Text(_isSubmitting ? 'Submitting...' : 'Confirm Submission'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isCapturing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Requesting camera & location…',
                style: TextStyle(color: AppColors.slate400, fontSize: 13)),
          ],
        ),
      );
    }

    if (_capturedBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_capturedBytes!, fit: BoxFit.cover),
          Positioned(
            bottom: 8, left: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6)),
              child: Text('📍 $_geotag',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: TextButton.icon(
              onPressed: _retake,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retake'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black45,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ),
        ],
      );
    }

    if (_showCamera && kIsWeb && _cameraService != null) {
      return Stack(
        children: [
          _cameraService!.buildPreview(),
          Positioned(
            bottom: 12, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _captureFrame,
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 8)
                    ],
                  ),
                  child: const Icon(Icons.camera_rounded,
                      size: 34, color: AppColors.navy700),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: IconButton(
              onPressed: () {
                _cameraService?.stopCamera();
                setState(() => _showCamera = false);
              },
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black45),
              tooltip: 'Cancel',
            ),
          ),
        ],
      );
    }

    // Default: tap-to-open placeholder
    return InkWell(
      onTap: kIsWeb ? _startWebCamera : _captureMobile,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
              color: AppColors.navy100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_rounded,
                size: 36, color: AppColors.navy600),
          ),
          const SizedBox(height: 14),
          const Text('Tap to Open Camera',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy600,
                  fontSize: 15)),
          const SizedBox(height: 4),
          const Text(
            'GPS location will be attached automatically',
            style: TextStyle(fontSize: 11, color: AppColors.slate400),
          ),
        ],
      ),
    );
  }
}
