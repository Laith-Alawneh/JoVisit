import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'pagination_dots.dart';
import '../../core/theme/app_theme.dart';

/// Horizontal scrolling image carousel with pagination dots and auto-advance
/// 
/// Memory-optimized carousel using PageView with cached network images
/// Supports full-width images with proper aspect ratio
/// Auto-advances through images automatically
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final ValueChanged<int>? onPageChanged;
  final bool showDots;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const ImageCarousel({
    super.key,
    required this.images,
    this.height = 200.0,
    this.onPageChanged,
    this.showDots = true,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoPlay && widget.images.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentPage < widget.images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    HapticFeedback.selectionClick();
    widget.onPageChanged?.call(index);
    
    // Restart auto-play timer
    if (widget.autoPlay && widget.images.length > 1) {
      _startAutoPlay();
    }
  }

  bool _isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _buildImage(String imageUrl) {
    if (_isNetworkImage(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    } else {
      // Local asset image
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: _onPageChanged,
            pageSnapping: true,
            itemBuilder: (context, index) {
              return _buildImage(widget.images[index]);
            },
          ),
        ),
        if (widget.showDots && widget.images.length > 1) ...[
          const SizedBox(height: 12),
          PaginationDots(
            currentIndex: _currentPage,
            totalCount: widget.images.length,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ],
    );
  }
}
