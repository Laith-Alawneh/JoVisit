import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../data/landmarks_data.dart';
import '../models/landmark.dart';
import '../presentation/widgets/image_helper.dart';
import 'landmark_detail_screen.dart';
import 'landmarks_screen.dart';
import 'quiz_screen_enhanced.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late YoutubePlayerController _ytController;
  bool _videoError = false;
  List<Landmark> _landmarks = [];

  @override
  void initState() {
    super.initState();
    _landmarks = LandmarksData.getLandmarks();
    _initVideo();
  }

  void _initVideo() {
    _ytController = YoutubePlayerController(
      initialVideoId: '9TdfUlZHjZ4',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(() {
        if (_ytController.value.hasError && !_videoError) {
          if (mounted) setState(() => _videoError = true);
        }
      });
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats strip ─────────────────────────────────────────────
                _StatsStrip(),

                // ── Section: Featured Landmarks ──────────────────────────────
                const _SectionHeader(title: 'Top Destinations', emoji: '🗺️'),
                _FeaturedLandmarksRow(landmarks: _landmarks),

                // ── Section: Intro Video ────────────────────────────────────
                const _SectionHeader(title: 'Introduction to Jordan', emoji: '🎬'),
                _VideoSection(
                    controller: _ytController, hasError: _videoError),

                // ── Section: Quick Actions ───────────────────────────────────
                const _SectionHeader(title: 'Explore More', emoji: '✨'),
                _QuickActionsGrid(),

                // ── Section: About ───────────────────────────────────────────
                const _SectionHeader(title: 'About Jordan', emoji: '🇯🇴'),
                _AboutSection(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero SliverAppBar ──────────────────────────────────────────────────────
  Widget _buildHeroAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: cs.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Jordan Tourism',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Discover ancient wonders',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              'pics/petra-1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primaryContainer],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Gradient scrim
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 0.8, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0x99000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
            // Flag decorative strip (bottom of image)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Row(
                children: [
                  Expanded(
                      child: Container(height: 4, color: AppTheme.primaryGreen)),
                  Expanded(child: Container(height: 4, color: Colors.white)),
                  Expanded(
                      child: Container(height: 4, color: AppTheme.primaryRed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats strip ──────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(label: 'Landmarks', value: '6', icon: Icons.place_rounded),
          _Divider(),
          _StatChip(label: 'Years of History', value: '5000+', icon: Icons.history_edu_rounded),
          _Divider(),
          _StatChip(label: 'UNESCO Sites', value: '3', icon: Icons.star_rounded),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w800, color: cs.primary),
        ),
        Text(
          label,
          style:
              Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;

  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─── Featured Landmarks horizontal scroll ────────────────────────────────────
class _FeaturedLandmarksRow extends StatelessWidget {
  final List<Landmark> landmarks;

  const _FeaturedLandmarksRow({required this.landmarks});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        itemCount: landmarks.length,
        itemBuilder: (context, index) => _LandmarkMiniCard(
          landmark: landmarks[index],
          index: index,
        ),
      ),
    );
  }
}

class _LandmarkMiniCard extends StatelessWidget {
  final Landmark landmark;
  final int index;

  const _LandmarkMiniCard({required this.landmark, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LandmarkDetailScreen(landmark: landmark),
        ),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Hero(
              tag: 'home_landmark_${landmark.id}',
              child: buildImage(landmark.primaryImageUrl, fit: BoxFit.cover),
            ),
            // Gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.textLegibilityGradient,
              ),
            ),
            // Text
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    landmark.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 11, color: cs.primaryContainer),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          landmark.location.split(',').first,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
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
      ),
    )
        .animate(delay: (index * 80).ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

// ─── Video section ────────────────────────────────────────────────────────────
class _VideoSection extends StatelessWidget {
  final YoutubePlayerController controller;
  final bool hasError;

  const _VideoSection(
      {required this.controller, required this.hasError});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: hasError
            ? Container(
                height: 200,
                color: cs.surfaceContainerHighest,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off_rounded,
                        size: 48, color: cs.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      'Video unavailable',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check your internet connection',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            : YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppTheme.primaryGreen,
                  progressColors: ProgressBarColors(
                    playedColor: AppTheme.primaryGreen,
                    handleColor: AppTheme.secondaryColor,
                    bufferedColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
                builder: (_, player) => player,
              ),
      ),
    );
  }
}

// ─── Quick actions grid ───────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    void push(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    final actions = [
      _ActionData(
        icon: Icons.explore_rounded,
        label: 'All Landmarks',
        sublabel: '6 amazing places',
        color: cs.primary,
        onTap: () => push(const LandmarksScreen()),
      ),
      _ActionData(
        icon: Icons.quiz_rounded,
        label: 'Take a Quiz',
        sublabel: 'Test your knowledge',
        color: cs.tertiary,
        onTap: () => push(const QuizScreenEnhanced()),
      ),
      _ActionData(
        icon: Icons.favorite_rounded,
        label: 'My Saved',
        sublabel: 'Your favourites',
        color: cs.error,
        onTap: () => push(const FavoritesScreen()),
      ),
      _ActionData(
        icon: Icons.person_rounded,
        label: 'My Profile',
        sublabel: 'Stats & achievements',
        color: AppTheme.goldColor,
        onTap: () => push(const ProfileScreen()),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: actions.asMap().entries.map((e) {
          return _ActionCard(data: e.value, index: e.key);
        }).toList(),
      ),
    );
  }

}

class _ActionData {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionData data;
  final int index;

  const _ActionCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: data.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(data.icon, color: data.color, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                  ),
                  Text(
                    data.sublabel,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 80 + 200).ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}

// ─── About section ────────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            // Flag banner
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Row(
                children: [
                  Expanded(
                      child: Container(height: 6, color: AppTheme.primaryGreen)),
                  Expanded(child: Container(height: 6, color: Colors.white)),
                  Expanded(
                      child: Container(height: 6, color: AppTheme.primaryRed)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Hashemite Kingdom of Jordan',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Jordan is a country rich in history and culture, home to some of the world\'s most significant archaeological sites. '
                    'From the ancient Nabataean city of Petra to the Roman ruins of Jerash, Jordan offers a journey through thousands of years of human civilization.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Its diverse landscape spans the lowest point on Earth (Dead Sea), a vast desert wilderness (Wadi Rum), and the only coastal city (Aqaba) - making Jordan a uniquely varied destination.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Highlight chips
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FactChip('🏛️ Ancient History'),
                      _FactChip('🌅 Stunning Landscapes'),
                      _FactChip('🏊 Dead Sea Float'),
                      _FactChip('🚀 Wadi Rum Stargazing'),
                      _FactChip('🤿 Red Sea Diving'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  final String label;
  const _FactChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
