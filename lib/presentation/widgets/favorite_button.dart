import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/favorites_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

/// Favorite button widget with animation
/// 
/// Provides visual feedback when toggling favorites
/// Demonstrates professional UI patterns and state management
class FavoriteButton extends StatelessWidget {
  /// ID of the landmark to favorite/unfavorite
  final int landmarkId;

  const FavoriteButton({
    super.key,
    required this.landmarkId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(landmarkId);

        return Semantics(
          label: isFavorite
              ? 'Remove from favorites'
              : 'Add to favorites',
          hint: 'Double tap to toggle favorite status',
          button: true,
          child: InkWell(
            onTap: () => favoritesProvider.toggleFavorite(landmarkId),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            child: AnimatedContainer(
              duration: AppConstants.animationFast,
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: isFavorite
                    ? AppTheme.goldColor.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppTheme.goldColor : Colors.grey,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
