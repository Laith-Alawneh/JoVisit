import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Pagination dots indicator with animated active state
/// 
/// Displays a row of dots with smooth transitions for active state
class PaginationDots extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double spacing;

  const PaginationDots({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.activeColor = AppTheme.primaryGreen,
    this.inactiveColor = Colors.white54,
    this.dotSize = 8.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalCount,
        (index) => _buildDot(index == currentIndex),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      width: isActive ? dotSize * 2 : dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
    );
  }
}
