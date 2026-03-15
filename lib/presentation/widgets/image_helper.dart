import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Helper widget to handle both asset and network images
/// 
/// Automatically detects image source type and uses appropriate widget
/// Provides consistent error handling and loading states
/// 
/// [imageUrl] - URL or asset path to the image
/// [height] - Optional height constraint
/// [width] - Optional width constraint
/// [fit] - How the image should be fitted (default: BoxFit.cover)
Widget buildImage(
  String imageUrl, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
}) {
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    // Network image with caching
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Container(
        height: height,
        width: width,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width,
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 50),
      ),
    );
  } else {
    // Asset image
    return Image.asset(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 50),
      ),
    );
  }
}
