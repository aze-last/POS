import 'dart:io';

import 'package:flutter/material.dart';

/// Renders a local product image with offline-first fallback placeholder.
class ProductImageWidget extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final double placeholderIconSize;

  const ProductImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholderIconSize = 28,
  });

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.amber.shade200, width: 0.8),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.eco_rounded,
        size: placeholderIconSize,
        color: Colors.amber.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null || path.isEmpty) {
      return _buildPlaceholder();
    }

    final file = File(path);
    if (!file.existsSync()) {
      return _buildPlaceholder();
    }

    Widget image = Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
