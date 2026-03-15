import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../core/theme/app_theme.dart';
import '../data/landmarks_data.dart';
import '../domain/providers/favorites_provider.dart';
import '../models/landmark.dart';
import '../presentation/widgets/image_helper.dart';
import 'landmark_detail_screen.dart';
import 'landmarks_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FavoritesProvider>(
        builder: (context, favProvider, _) {
          final allLandmarks = LandmarksData.getLandmarks();
          final favorites = allLandmarks
              .where((l) => favProvider.isFavorite(l.id))
              .toList();

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, favorites.length),
              if (favorites.isEmpty)
                _buildEmptyState(context)
              else
                _buildGrid(context, favorites, favProvider),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, int count) {
    final cs = Theme.of(context).colorScheme;
    return SliverAppBar(
      floating: true,
      snap: true,
      title: Column(
        children: [
          const Text('My Favourites'),
          if (count > 0)
            Text(
              '$count saved',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                  ),
            ),
        ],
      ),
      centerTitle: true,
    );
  }

  SliverFillRemaining _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated heart icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 56,
                color: cs.error.withValues(alpha: 0.7),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 28),

            Text(
              'No favourites yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 12),

            Text(
              'Tap the heart icon on any landmark to save it here for quick access.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 500.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 36),

            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LandmarksScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Explore Landmarks'),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildGrid(
    BuildContext context,
    List<Landmark> favorites,
    FavoritesProvider favProvider,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _FavoriteCard(
            landmark: favorites[index],
            onUnfavorite: () => favProvider.toggleFavorite(favorites[index].id),
            index: index,
          ),
          childCount: favorites.length,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
      ),
    );
  }
}

// ─── Favorite card tile ───────────────────────────────────────────────────────
class _FavoriteCard extends StatelessWidget {
  final Landmark landmark;
  final VoidCallback onUnfavorite;
  final int index;

  const _FavoriteCard({
    required this.landmark,
    required this.onUnfavorite,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: cs.surface,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      transitionDuration: const Duration(milliseconds: 550),
      transitionType: ContainerTransitionType.fadeThrough,
      closedBuilder: (context, action) => _CardContent(
        landmark: landmark,
        onUnfavorite: onUnfavorite,
      ),
      openBuilder: (context, action) => LandmarkDetailScreen(landmark: landmark),
    )
        .animate(delay: (index * 80).ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}

class _CardContent extends StatelessWidget {
  final Landmark landmark;
  final VoidCallback onUnfavorite;

  const _CardContent({required this.landmark, required this.onUnfavorite});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Hero(
            tag: 'landmark_${landmark.id}_fav',
            child: buildImage(landmark.primaryImageUrl, fit: BoxFit.cover),
          ),

          // Gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.textLegibilityGradient,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unfavorite button (top-right)
                Align(
                  alignment: Alignment.topRight,
                  child: _UnfavoriteButton(onTap: onUnfavorite),
                ),
                const Spacer(),
                // Name
                Text(
                  landmark.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  landmark.nameArabic,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Location chip
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: cs.primaryContainer),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        landmark.location,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnfavoriteButton extends StatefulWidget {
  final VoidCallback onTap;
  const _UnfavoriteButton({required this.onTap});

  @override
  State<_UnfavoriteButton> createState() => _UnfavoriteButtonState();
}

class _UnfavoriteButtonState extends State<_UnfavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.75).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.redAccent,
            size: 20,
          ),
        ),
      ),
    );
  }
}
