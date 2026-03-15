import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../data/landmarks_data.dart';
import '../domain/providers/favorites_provider.dart';
import '../domain/providers/gamification_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _rating = 0;
  bool _ratingSubmitted = false;
  final AudioPlayer _audio = AudioPlayer();
  final TextEditingController _feedbackCtrl = TextEditingController();

  @override
  void dispose() {
    _audio.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRatingChanged(double r) async {
    setState(() => _rating = r);
    if (r >= 4) {
      try {
        await _audio.play(AssetSource('audio/clapping.mp3'));
      } catch (_) {}
    }
  }

  void _submitRating() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating first.')),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _ratingSubmitted = true);
  }

  String _ratingMessage(double r) {
    if (r == 1) return 'We\'ll work harder for you 💪';
    if (r == 2) return 'Thanks — we can do better 🙏';
    if (r == 3) return 'Good — we appreciate it!';
    if (r == 4) return 'Great — you made our day! 😊';
    return 'Excellent — you\'re amazing! 🌟';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalLandmarks = LandmarksData.getLandmarks().length;

    return Consumer2<FavoritesProvider, GamificationProvider>(
      builder: (context, favProvider, gamProvider, _) {
        final favCount = favProvider.favorites.length;
        final quizCount = gamProvider.completedQuizzes.length;
        final badgeCount = gamProvider.unlockedBadges.length;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ─── App Bar ───────────────────────────────────────────────────
              const SliverAppBar(
                floating: true,
                snap: true,
                title: Text('My Profile'),
                centerTitle: true,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Stats Row ─────────────────────────────────────────
                      const _SectionLabel('Explorer Stats'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.favorite_rounded,
                              value: '$favCount',
                              label: 'Saved',
                              color: cs.error,
                              delay: 0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.quiz_rounded,
                              value: '$quizCount',
                              label: 'Quizzes',
                              color: cs.tertiary,
                              delay: 100,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.emoji_events_rounded,
                              value: '$badgeCount',
                              label: 'Badges',
                              color: AppTheme.goldColor,
                              delay: 200,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ─── Progress ─────────────────────────────────────────
                      const _SectionLabel('Landmark Explorer Progress'),
                      const SizedBox(height: 12),
                      _ExplorerProgress(
                        completed: quizCount,
                        total: totalLandmarks,
                      ),

                      const SizedBox(height: 24),

                      // ─── Achievement Badges ───────────────────────────────
                      const _SectionLabel('Achievement Badges'),
                      const SizedBox(height: 12),
                      _BadgesGrid(
                        unlockedBadges: gamProvider.unlockedBadges,
                      ),

                      const SizedBox(height: 24),

                      // ─── Rate the App ─────────────────────────────────────
                      const _SectionLabel('Rate the App'),
                      const SizedBox(height: 12),
                      _ratingSubmitted
                          ? _ThankYouCard(rating: _rating)
                          : _RatingCard(
                              rating: _rating,
                              feedbackCtrl: _feedbackCtrl,
                              onRatingChanged: _onRatingChanged,
                              onSubmit: _submitRating,
                              ratingMessage: _ratingMessage,
                            ),

                      const SizedBox(height: 24),

                      // ─── About ────────────────────────────────────────────
                      const _SectionLabel('About'),
                      const SizedBox(height: 12),
                      _AboutCard(),

                      const SizedBox(height: 16),
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
}

// ─── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }
}

// ─── Stat card ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 26, fontWeight: FontWeight.w800, color: cs.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    )
        .animate(delay: delay.ms)
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOut);
  }
}

// ─── Explorer progress bar ────────────────────────────────────────────────────
class _ExplorerProgress extends StatelessWidget {
  final int completed;
  final int total;

  const _ExplorerProgress({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed / $total landmarks explored',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badges grid ─────────────────────────────────────────────────────────────
class _BadgesGrid extends StatelessWidget {
  final Set<String> unlockedBadges;

  const _BadgesGrid({required this.unlockedBadges});

  static const _badgeDefinitions = [
    _BadgeDef('1', Icons.account_balance_rounded, 'Petra Explorer', 'Completed the Petra quiz'),
    _BadgeDef('4', Icons.temple_buddhist_rounded, 'Jerash Scholar', 'Completed the Jerash quiz'),
    _BadgeDef('2', Icons.landscape_rounded, 'Desert Wanderer', 'Completed the Wadi Rum quiz'),
    _BadgeDef('3', Icons.water_rounded, 'Sea Explorer', 'Completed the Dead Sea quiz'),
    _BadgeDef('5', Icons.location_city_rounded, 'City Historian', 'Completed the Amman quiz'),
    _BadgeDef('6', Icons.beach_access_rounded, 'Coastal Champion', 'Completed the Aqaba quiz'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _badgeDefinitions.length,
      itemBuilder: (context, i) {
        final badge = _badgeDefinitions[i];
        final unlocked = unlockedBadges.contains(badge.id);
        return _BadgeTile(badge: badge, unlocked: unlocked, index: i);
      },
    );
  }
}

@immutable
class _BadgeDef {
  final String id;
  final IconData icon;
  final String name;
  final String description;
  const _BadgeDef(this.id, this.icon, this.name, this.description);
}

class _BadgeTile extends StatelessWidget {
  final _BadgeDef badge;
  final bool unlocked;
  final int index;

  const _BadgeTile({
    required this.badge,
    required this.unlocked,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: unlocked ? badge.description : 'Complete the quiz to unlock',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked
              ? cs.primaryContainer
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? badge.icon : Icons.lock_rounded,
              size: 28,
              color: unlocked
                  ? cs.onPrimaryContainer
                  : cs.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: unlocked
                        ? cs.onPrimaryContainer
                        : cs.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut);
  }
}

// ─── Rating card ──────────────────────────────────────────────────────────────
class _RatingCard extends StatelessWidget {
  final double rating;
  final TextEditingController feedbackCtrl;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onSubmit;
  final String Function(double) ratingMessage;

  const _RatingCard({
    required this.rating,
    required this.feedbackCtrl,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.ratingMessage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Star emoji
          const Text('⭐', style: TextStyle(fontSize: 36))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 12),
          Text(
            'How was your experience?',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Rating bar
          FittedBox(
            child: RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              itemCount: 5,
              itemSize: 48,
              itemPadding: const EdgeInsets.symmetric(horizontal: 6),
              glowColor: AppTheme.goldColor.withValues(alpha: 0.3),
              itemBuilder: (_, __) => const Icon(
                Icons.star_rounded,
                color: AppTheme.goldColor,
              ),
              onRatingUpdate: onRatingChanged,
            ),
          ),

          // Dynamic message
          if (rating > 0) ...[
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(rating),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: rating >= 4
                      ? cs.primaryContainer
                      : cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ratingMessage(rating),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: rating >= 4
                            ? cs.onPrimaryContainer
                            : cs.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Feedback text field
          TextField(
            controller: feedbackCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Tell us more (optional)…',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),

          const SizedBox(height: 20),

          // Submit
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Submit Rating'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Thank-you card ───────────────────────────────────────────────────────────
class _ThankYouCard extends StatelessWidget {
  final double rating;
  const _ThankYouCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'Thank You!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onPrimaryContainer,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your ${rating.toInt()}-star rating means a lot to us.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onPrimaryContainer,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOut);
  }
}

// ─── About card ───────────────────────────────────────────────────────────────
class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const _AboutTile(
            icon: Icons.flag_rounded,
            title: 'Jordan Tourism App',
            subtitle: 'Version 2.0 — Redesigned 2026',
          ),
          Divider(height: 1, color: cs.outlineVariant),
          const _AboutTile(
            icon: Icons.school_rounded,
            title: 'BTEC Level 3 Unit 7',
            subtitle: 'Jordanian Landmarks Mobile App',
          ),
          Divider(height: 1, color: cs.outlineVariant),
          const _AboutTile(
            icon: Icons.code_rounded,
            title: 'Built with Flutter',
            subtitle: 'Material 3 · Provider · Google Fonts',
          ),
          Divider(height: 1, color: cs.outlineVariant),
          const _AboutTile(
            icon: Icons.location_on_rounded,
            title: 'Covering Jordan',
            subtitle:
                'Petra • Jerash • Wadi Rum • Dead Sea • Amman • Aqaba',
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: cs.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
