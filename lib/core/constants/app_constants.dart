/// Application-wide constants
/// 
/// Contains spacing, sizing, and other reusable constants
/// to maintain consistency across the app
class AppConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;

  // Padding
  static const double paddingCard = 16.0;
  static const double paddingL = 16.0; // Alias for paddingCard
  static const double paddingSection = 24.0;
  static const double paddingScreen = 20.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // Breakpoints for responsive design
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1200.0;
}
