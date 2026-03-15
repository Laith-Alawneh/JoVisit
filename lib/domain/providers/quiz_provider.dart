import 'package:flutter/foundation.dart';
import '../../models/quiz_question.dart';
import '../../data/quiz_data.dart';

/// Provider for managing quiz state and logic
/// 
/// Handles question navigation, scoring, and answer tracking
/// Demonstrates professional state management patterns
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
  
  /// Get current question
  QuizQuestion? get currentQuestion {
    if (_currentQuestionIndex < questions.length) {
      return questions[_currentQuestionIndex];
    }
    return null;
  }

  /// Get quiz progress as percentage
  /// 
  /// Returns progress from 0.0 to 1.0
  double get progress {
    if (questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / questions.length;
  }

  /// Select an answer for the current question
  /// 
  /// [answerIndex] - The index of the selected answer (0-based)
  /// Returns true if the answer is correct, false otherwise
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

  /// Move to the next question
  /// 
  /// Returns true if there are more questions, false if quiz is complete
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

  /// Restart the quiz
  /// 
  /// Resets all quiz state to initial values
  void restart() {
    _currentQuestionIndex = 0;
    _selectedAnswerIndex = null;
    _score = 0;
    _showResult = false;
    _answers.clear();
    notifyListeners();
  }

  /// Get final score percentage
  /// 
  /// Returns percentage from 0 to 100
  int getScorePercentage() {
    if (questions.isEmpty) return 0;
    return ((_score / questions.length) * 100).round();
  }

  /// Check if user achieved perfect score
  /// 
  /// Returns true if score equals total questions
  bool isPerfectScore() {
    return _score == questions.length;
  }
}
