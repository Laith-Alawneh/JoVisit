import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/landmark.dart';
import '../core/theme/app_theme.dart';
import '../presentation/widgets/glass_container.dart';
import '../presentation/widgets/animated_fab.dart';
import '../presentation/widgets/pagination_dots.dart';
import '../presentation/widgets/landmark_quiz_modal.dart';

/// Immersive landmark detail screen with full-bleed background
/// 
/// Features:
/// - Full-bleed background image
/// - Glassmorphic bottom container with carousel
/// - Floating Action Button cluster (Quiz, Info)
/// - Synchronized background-carousel updates
class LandmarkDetailScreen extends StatefulWidget {
  final Landmark landmark;

  const LandmarkDetailScreen({super.key, required this.landmark});

  @override
  State<LandmarkDetailScreen> createState() => _LandmarkDetailScreenState();
}

class _LandmarkDetailScreenState extends State<LandmarkDetailScreen> with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  late PageController _backgroundPageController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _backgroundPageController = PageController();
    if (widget.landmark.carouselImages.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _backgroundPageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentImageIndex < widget.landmark.carouselImages.length - 1) {
        _currentImageIndex++;
      } else {
        _currentImageIndex = 0;
      }
      _backgroundPageController.animateToPage(
        _currentImageIndex,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  bool _isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _buildBackgroundImage(String imageUrl) {
    if (_isNetworkImage(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        key: ValueKey(imageUrl),
        placeholder: (context, url) => Container(
          color: AppTheme.darkBackground,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppTheme.darkBackground,
          child: const Icon(Icons.error, color: Colors.white),
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        key: ValueKey(imageUrl),
        cacheWidth: null,
        cacheHeight: null,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppTheme.darkBackground,
          child: const Icon(Icons.error, color: Colors.white),
        ),
      );
    }
  }

  void _onBackgroundPageChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
    // Restart auto-play timer
    if (widget.landmark.carouselImages.length > 1) {
      _startAutoPlay();
    }
  }


  void _openQuiz() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: LandmarkQuizModal(landmark: widget.landmark),
      ),
    );
  }

  void _openInfoOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInfoOverlay(),
    );
  }

  Widget _buildInfoOverlay() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.landmark.titleEn,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.landmark.titleAr,
                        style: AppTheme.arabicHeadline(context).copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Description
                      _buildInfoSection('Description', widget.landmark.description),
                      const SizedBox(height: 24),
                      
                      // Cultural Value
                      _buildInfoSection('Cultural Value', widget.landmark.culturalValue),
                      const SizedBox(height: 24),
                      
                      // Historical Significance
                      _buildInfoSection(
                        'Historical Significance',
                        widget.landmark.historicalSignificance,
                      ),
                      const SizedBox(height: 24),
                      
                      // Location
                      _buildInfoCard(Icons.location_on, 'Location', widget.landmark.location),
                      const SizedBox(height: 16),
                      
                      // Best Time to Visit
                      _buildInfoCard(
                        Icons.calendar_today,
                        'Best Time to Visit',
                        widget.landmark.bestTimeToVisit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTruncatedDescription() {
    final sentences = widget.landmark.description.split('.');
    if (sentences.length <= 2) {
      return widget.landmark.description;
    }
    return '${sentences[0]}. ${sentences[1]}.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-bleed background image with swipeable PageView
          Positioned.fill(
            child: widget.landmark.carouselImages.isNotEmpty
                ? PageView.builder(
                    controller: _backgroundPageController,
                    onPageChanged: _onBackgroundPageChanged,
                    itemCount: widget.landmark.carouselImages.length,
                    itemBuilder: (context, index) {
                      return _buildBackgroundImage(widget.landmark.carouselImages[index]);
                    },
                  )
                : _buildBackgroundImage(widget.landmark.primaryImageUrl),
          ),

          // Glassmorphic bottom container with rounded bottom corners
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassContainer(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dual-language title
                  Text(
                    widget.landmark.titleEn,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.landmark.titleAr,
                    style: AppTheme.arabicHeadline(context).copyWith(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Truncated description
                  Text(
                    _getTruncatedDescription(),
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),

                  // Pagination dots only (carousel removed, background handles images)
                  if (widget.landmark.carouselImages.isNotEmpty)
                    PaginationDots(
                      currentIndex: _currentImageIndex,
                      totalCount: widget.landmark.carouselImages.length,
                      activeColor: AppTheme.primaryGreen,
                    ),
                ],
              ),
            ),
          ),

          // FAB Cluster (right-center edge)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quiz FAB (Red)
                AnimatedFAB(
                  icon: Icons.quiz,
                  backgroundColor: AppTheme.primaryRed,
                  onPress: _openQuiz,
                  tooltip: 'Take Quiz',
                ),
                const SizedBox(height: 16),

                // Info FAB (Neutral)
                AnimatedFAB(
                  icon: Icons.info,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  onPress: _openInfoOverlay,
                  tooltip: 'More Information',
                ),
              ],
            ),
          ),

          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
