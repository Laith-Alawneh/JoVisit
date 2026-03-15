import '../models/landmark.dart';
import '../models/quiz_question.dart';

class LandmarksData {
  static List<Landmark> getLandmarks() {
    return [
      Landmark(
        id: 1,
        name: 'Petra',
        nameArabic: 'البتراء',
        description: 'Petra, also known as the "Rose City", is a historical and archaeological city in southern Jordan. It is one of the New Seven Wonders of the World and a UNESCO World Heritage Site.',
        culturalValue: 'Petra represents the architectural genius of the Nabataean civilization.',
        historicalSignificance: 'Established possibly as early as 312 BC as the capital city of the Nabataeans.',
        imageUrl: 'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800',
        location: 'Ma\'an Governorate, Jordan',
        bestTimeToVisit: 'March to May, September to November',
        title: {'en': 'Petra', 'ar': 'البتراء'},
        coordinates: Coordinates(lat: 30.3285, lng: 35.4444),
        carouselImages: [
          'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=1200',
        ],
        quizData: [],
      ),
      Landmark(
        id: 4,
        name: 'Jerash',
        nameArabic: 'جرش',
        description: 'Jerash is an ancient city in northern Jordan, known for its well-preserved ruins of the Greco-Roman city of Gerasa.',
        culturalValue: 'Jerash represents the fusion of Greco-Roman urban planning with Semitic traditions.',
        historicalSignificance: 'Jerash was inhabited during the Bronze Age, but it flourished during the Roman period.',
        imageUrl: 'pics/jerash.jpg',
        location: 'Jerash Governorate, Jordan',
        bestTimeToVisit: 'March to May, September to November',
        title: {'en': 'Jerash', 'ar': 'جرش'},
        coordinates: Coordinates(lat: 32.28056, lng: 35.89722),
        carouselImages: ['pics/jerash.jpg'],
        quizData: [],
      ),
      Landmark(
        id: 2,
        name: 'Wadi Rum',
        nameArabic: 'وادي رم',
        description: 'Wadi Rum, also known as the Valley of the Moon, is a protected desert wilderness in southern Jordan.',
        culturalValue: 'Wadi Rum has been inhabited by many human cultures since prehistoric times.',
        historicalSignificance: 'The area has been inhabited by various cultures for over 12,000 years.',
        imageUrl: 'pics/wadi-rum.jpg',
        location: 'Aqaba Governorate, Jordan',
        bestTimeToVisit: 'October to April',
        title: {'en': 'Wadi Rum', 'ar': 'وادي رم'},
        coordinates: Coordinates(lat: 29.5765, lng: 35.4208),
        carouselImages: ['pics/wadi-rum.jpg'],
        quizData: [],
      ),
      Landmark(
        id: 3,
        name: 'Dead Sea',
        nameArabic: 'البحر الميت',
        description: 'The Dead Sea is a salt lake bordered by Jordan to the east. It is the lowest point on Earth\'s surface.',
        culturalValue: 'The Dead Sea has been a source of various products for thousands of years.',
        historicalSignificance: 'The Dead Sea has been referenced in historical texts dating back to ancient times.',
        imageUrl: 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=800',
        location: 'Jordan Valley, Jordan',
        bestTimeToVisit: 'Year-round',
        title: {'en': 'Dead Sea', 'ar': 'البحر الميت'},
        coordinates: Coordinates(lat: 31.5, lng: 35.5),
        carouselImages: ['https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=1200'],
        quizData: [],
      ),
    ];
  }
}
