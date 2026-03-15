import '../models/quiz_question.dart';

class QuizData {
  static List<QuizQuestion> getQuestions() {
    return [
      QuizQuestion(
        id: 1,
        question: 'What is Petra also known as?',
        options: [
          'The Golden City',
          'The Rose City',
          'The Ancient City',
          'The Desert City',
        ],
        correctAnswerIndex: 1,
        explanation: 'Petra is famously known as "The Rose City" due to the color of the stone from which it is carved.',
      ),
      QuizQuestion(
        id: 2,
        question: 'Which landmark is the lowest point on Earth\'s surface?',
        options: [
          'Wadi Rum',
          'Dead Sea',
          'Petra',
          'Jerash',
        ],
        correctAnswerIndex: 1,
        explanation: 'The Dead Sea is the lowest point on Earth\'s surface, sitting at approximately 430 meters below sea level.',
      ),
      QuizQuestion(
        id: 3,
        question: 'What ancient civilization built Petra?',
        options: [
          'Romans',
          'Greeks',
          'Nabataeans',
          'Byzantines',
        ],
        correctAnswerIndex: 2,
        explanation: 'Petra was built by the Nabataeans, an ancient Arab people who established a trading empire in the region.',
      ),
      QuizQuestion(
        id: 4,
        question: 'Which city is Jordan\'s only coastal city?',
        options: [
          'Amman',
          'Aqaba',
          'Irbid',
          'Zarqa',
        ],
        correctAnswerIndex: 1,
        explanation: 'Aqaba is Jordan\'s only coastal city, located on the Red Sea and serving as the country\'s main port.',
      ),
      QuizQuestion(
        id: 5,
        question: 'What is the name of the famous temple structure in Petra?',
        options: [
          'The Palace',
          'The Treasury (Al-Khazneh)',
          'The Monastery',
          'The Theater',
        ],
        correctAnswerIndex: 1,
        explanation: 'Al-Khazneh (The Treasury) is Petra\'s most famous structure, believed to be a mausoleum or temple from the 1st century AD.',
      ),
    ];
  }
}
