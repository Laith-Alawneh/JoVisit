import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../data/landmarks_data.dart';
import '../models/landmark.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../presentation/widgets/image_helper.dart';
import '../presentation/widgets/favorite_button.dart';
import 'landmark_detail_screen.dart';

/// Category filter model
enum _LandmarkCategory {
  all('All', Icons.apps_rounded),
  history('History', Icons.account_balance_rounded),
  nature('Nature', Icons.landscape_rounded),
  coastal('Coastal', Icons.water_rounded);

  final String label;
  final IconData icon;
  const _LandmarkCategory(this.label, this.icon);
}

// Category assignments per landmark ID
const _landmarkCategories = {
  1: _LandmarkCategory.history,  // Petra
  4: _LandmarkCategory.history,  // Jerash
  2: _LandmarkCategory.nature,   // Wadi Rum
  3: _LandmarkCategory.nature,   // Dead Sea
  5: _LandmarkCategory.history,  // Amman Citadel
  6: _LandmarkCategory.coastal,  // Aqaba
};

class LandmarksScreen extends StatefulWidget {
  const LandmarksScreen({super.key});

  @override
  State<LandmarksScreen> createState() => _LandmarksScreenState();
}

class _LandmarksScreenState extends State<LandmarksScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  _LandmarkCategory _category = _LandmarkCategory.all;
  String _query = '';
  bool _isLoading = true; // simulated for shimmer demo
  final List<Landmark> _allLandmarks = LandmarksData.getLandmarks();

  @override
  void initState() {
    super.initState();
    // Simulate a brief loading state for polish
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Landmark> get _filtered {
    return _allLandmarks.where((l) {
      final matchesCategory = _category == _LandmarkCategory.all ||
          _landmarkCategories[l.id] == _category;
      final matchesSearch = _query.isEmpty ||
          l.name.toLowerCase().contains(_query.toLowerCase()) ||
          l.nameArabic.contains(_query) ||
          l.location.toLowerCase().contains(_query.toLowerCase()) ||
          l.description.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            forceElevated: innerBoxScrolled,
            title: const Text('Discover Jordan'),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: SearchBar(
                      controller: _searchCtrl,
                      hintText: 'Search landmarks, locations…',
                      leading: Icon(Icons.search_rounded,
                          color: cs.onSurfaceVariant),
                      trailing: [
                        if (_query.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                      ],
                      onChanged: (v) => setState(() => _query = v),
                      backgroundColor: WidgetStatePropertyAll(
                          cs.surfaceContainerHighest),
                      elevation: const WidgetStatePropertyAll(0),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  // Category chips
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      children: _LandmarkCategory.values.map((cat) {
                        final selected = _category == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: Icon(cat.icon,
                                size: 16,
                                color: selected
                                    ? cs.onSecondaryContainer
                                    : cs.onSurfaceVariant),
                            label: Text(cat.label),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _category = cat),
                            selectedColor: cs.secondaryContainer,
                            checkmarkColor: cs.onSecondaryContainer,
                            labelStyle: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selected
                                  ? cs.onSecondaryContainer
                                  : cs.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: _isLoading
            ? _buildShimmerList()
            : filtered.isEmpty
                ? _buildEmptyState(context)
                : _buildLandmarkList(context, filtered),
      ),
    );
  }

  // ─── Loading shimmer ────────────────────────────────────────────────────────
  Widget _buildShimmerList() {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest,
        highlightColor: cs.surfaceContainerLow,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ─── Empty search state ─────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No results found',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or category.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                _searchCtrl.clear();
                setState(() {
                  _query = '';
                  _category = _LandmarkCategory.all;
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Landmark list ──────────────────────────────────────────────────────────
  Widget _buildLandmarkList(BuildContext context, List<Landmark> landmarks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > AppConstants.tabletBreakpoint;
        if (isTablet) {
          return _buildGrid(context, landmarks);
        }
        return _buildList(context, landmarks);
      },
    );
  }

  Widget _buildList(BuildContext context, List<Landmark> landmarks) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: landmarks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _LandmarkCard(
        landmark: landmarks[index],
        index: index,
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Landmark> landmarks) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: landmarks.length,
      itemBuilder: (context, index) => _LandmarkCard(
        landmark: landmarks[index],
        index: index,
      ),
    );
  }
}

// ─── Landmark card ────────────────────────────────────────────────────────────
class _LandmarkCard extends StatelessWidget {
  final Landmark landmark;
  final int index;

  const _LandmarkCard({required this.landmark, required this.index});

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
      transitionDuration: const Duration(milliseconds: 600),
      transitionType: ContainerTransitionType.fadeThrough,
      closedBuilder: (context, action) => _CardContent(landmark: landmark),
      openBuilder: (context, action) =>
          LandmarkDetailScreen(landmark: landmark),
    )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}

class _CardContent extends StatelessWidget {
  final Landmark landmark;
  const _CardContent({required this.landmark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cat = _landmarkCategories[landmark.id];

    return Hero(
      tag: 'landmark_${landmark.id}',
      child: SizedBox(
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              buildImage(landmark.primaryImageUrl, fit: BoxFit.cover),

              // Gradient
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.textLegibilityGradient,
                ),
              ),

              // Favourite button
              Positioned(
                top: 10,
                right: 10,
                child: FavoriteButton(landmarkId: landmark.id),
              ),

              // Category badge
              if (cat != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon,
                            size: 11, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          cat.label,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom text
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      landmark.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      landmark.nameArabic,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13,
                            color: cs.primaryContainer),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            landmark.location,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.6)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
