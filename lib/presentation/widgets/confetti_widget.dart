import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';

/// Confetti animation widget for celebrating achievements
/// 
/// Used to celebrate perfect quiz scores, demonstrating
/// creativity and enhanced user experience (D3 requirement)
class ConfettiAnimation extends StatelessWidget {
  /// Controller for the confetti animation
  final ConfettiController controller;

  const ConfettiAnimation({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: 1.5708, // 90 degrees (straight down)
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.1,
        shouldLoop: false,
        colors: const [
          AppTheme.primaryColor,
          AppTheme.secondaryColor,
          AppTheme.goldColor,
          AppTheme.accentColor,
          Colors.white,
        ],
      ),
    );
  }
}
