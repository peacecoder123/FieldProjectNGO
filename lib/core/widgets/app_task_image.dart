import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

class AppTaskImage extends StatelessWidget {
  const AppTaskImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    Widget image;
    
    // Check if it's a base64 Data URL
    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64String = imageUrl!.split(',').last;
        final bytes = base64Decode(base64String);
        image = Image.memory(
          bytes,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(isError: true),
        );
      } catch (e) {
        image = _buildPlaceholder(isError: true);
      }
    } else {
      // Standard Network URL
      image = Image.network(
        imageUrl!,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading();
        },
        errorBuilder: (_, __, ___) => _buildPlaceholder(isError: true),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }

  Widget _buildPlaceholder({bool isError = false}) {
    return Container(
      height: height,
      width: width,
      color: AppColors.slate100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.broken_image_rounded : Icons.image_not_supported_rounded,
            color: AppColors.slate400,
            size: height != null && height! < 100 ? 24 : 48,
          ),
          if (height == null || height! >= 100) ...[
            const SizedBox(height: 8),
            Text(
              isError ? 'Error loading image' : 'No image provided',
              style: const TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: height,
      width: width,
      color: AppColors.slate50,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
