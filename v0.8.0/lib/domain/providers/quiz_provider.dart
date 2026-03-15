import 'package:flutter/foundation.dart';
import '../../models/quiz_question.dart';
import '../../data/quiz_data.dart';

class QuizProvider with ChangeNotifier {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _showResult = false;
  final List<Map<String, dynamic>> _answers = [];
  
  List<QuizQuestion> get questions => QuizData.getQuestions();
  int get currentQuestionIndex => _currentQuestionIndex;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  int get score => _score;
  bool get showResult => _showResult;
  List<Map<String, dynamic>> get answers => _answers;
  
  QuizQuestion? get currentQuestion {
    if (_currentQuestionIndex < questions.length) {
      return questions[_currentQuestionIndex];
    }
    return null;
  }

  double get progress {
    if (questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / questions.length;
  }

  bool selectAnswer(int answerIndex) {
    if (_selectedAnswerIndex != null || currentQuestion == null) {
      return false;
    }

    _selectedAnswerIndex = answerIndex;
    final isCorrect = answerIndex == currentQuestion!.correctAnswerIndex;

    if (isCorrect) {
      _score++;
    }

    _answers.add({
      'questionIndex': _currentQuestionIndex,
      'selectedAnswer': answerIndex,
      'isCorrect': isCorrect,
    });

    notifyListeners();
    return isCorrect;
  }

  bool nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      notifyListeners();
      return true;
    } else {
      _showResult = true;
      notifyListeners();
      return false;
    }
  }

  void restart() {
    _currentQuestionIndex = 0;
    _selectedAnswerIndex = null;
    _score = 0;
    _showResult = false;
    _answers.clear();
    notifyListeners();
  }

  int getScorePercentage() {
    if (questions.isEmpty) return 0;
    return ((_score / questions.length) * 100).round();
  }

  bool isPerfectScore() {
    return _score == questions.length;
  }
}
