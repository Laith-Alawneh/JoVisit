import 'quiz_question.dart';

class Landmark {
  final int id;
  final String name;
  final String nameArabic;
  final String description;
  final String culturalValue;
  final String historicalSignificance;
  final String imageUrl;
  final String location;
  final String bestTimeToVisit;
  final Map<String, String> title;
  final Coordinates coordinates;
  final List<String> carouselImages;
  final List<QuizQuestion> quizData;

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
  
  String get primaryImageUrl => carouselImages.isNotEmpty ? carouselImages[0] : imageUrl;
  String get titleEn => title['en'] ?? name;
  String get titleAr => title['ar'] ?? nameArabic;
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({
    required this.lat,
    required this.lng,
  });
}
