import 'quiz_question.dart';

/// Represents a landmark with enhanced data for immersive UI
class Landmark {
  final int id;
  final String name;
  final String nameArabic;
  final String description;
  final String culturalValue;
  final String historicalSignificance;
  final String imageUrl; // Legacy field, use carouselImages[0] for primary image
  final String location;
  final String bestTimeToVisit;
  
  // Enhanced fields for new UI
  final Map<String, String> title; // {en: String, ar: String} for dual-language support
  final Coordinates coordinates; // Latitude and longitude for map projection
  final List<String> carouselImages; // Multiple images for carousel
  final List<QuizQuestion> quizData; // Landmark-specific trivia questions

  Landmark({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.culturalValue,
    required this.historicalSignificance,
    required this.imageUrl,
    required this.location,
    required this.bestTimeToVisit,
    required this.title,
    required this.coordinates,
    required this.carouselImages,
    required this.quizData,
  });
  
  /// Get primary image URL (first from carousel or fallback to imageUrl)
  String get primaryImageUrl => carouselImages.isNotEmpty ? carouselImages[0] : imageUrl;
  
  /// Get English title
  String get titleEn => title['en'] ?? name;
  
  /// Get Arabic title
  String get titleAr => title['ar'] ?? nameArabic;
}

/// Geographic coordinates for map projection
class Coordinates {
  final double lat;
  final double lng;

  Coordinates({
    required this.lat,
    required this.lng,
  });
}
