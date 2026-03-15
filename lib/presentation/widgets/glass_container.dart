import 'package:flutter/material.dart';
import 'frosted_glass_effect.dart';
import '../../core/theme/app_theme.dart';

/// Glassmorphic container widget using FrostedGlass for advanced shader effects
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Get the radius value from BorderRadius
    final double radius = borderRadius != null ? borderRadius!.topLeft.x : 20.0;

    return FrostedGlass(
      borderRadius: radius,
      color: AppTheme.glassOverlay.withValues(alpha: 0.1),
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: AppTheme.textLegibilityGradient,
        ),
        child: child,
      ),
    );
  }
}
