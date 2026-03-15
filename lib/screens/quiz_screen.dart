import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/quiz_data.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _showResult = false;
  final List<Map<String, dynamic>> _answers = [];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/success_chime.mp3'));
    } catch (e) {
      // If audio file not found, continue without sound
      debugPrint('Audio file not found: $e');
    }
  }

  Future<void> _playErrorSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/wrong-buzzer.mp3'));
    } catch (e) {
      debugPrint('Audio file not found: $e');
    }
  }

  void _selectAnswer(int index) {
    if (_selectedAnswerIndex != null) return;

    setState(() {
      _selectedAnswerIndex = index;
      final question = QuizData.getQuestions()[_currentQuestionIndex];
      final isCorrect = index == question.correctAnswerIndex;

      if (isCorrect) {
        _score++;
        _playSuccessSound();
      } else {
        _playErrorSound();
      }

      _answers.add({
        'questionIndex': _currentQuestionIndex,
        'selectedAnswer': index,
        'isCorrect': isCorrect,
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < QuizData.getQuestions().length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
      });
    } else {
      setState(() {
        _showResult = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _score = 0;
      _showResult = false;
      _answers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _buildResultScreen();
    }

    final questions = QuizData.getQuestions();
    final currentQuestion = questions[_currentQuestionIndex];
    final progress = ((_currentQuestionIndex + 1) / questions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jordan Knowledge Quiz'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor])),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, AppTheme.backgroundColor])),
        child: Column(
          children: [
            // Progress Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_currentQuestionIndex + 1}/${questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Question and Answers
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.help_outline,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    currentQuestion.question,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Answer Options
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _selectedAnswerIndex == index;
                      final isCorrect = index == currentQuestion.correctAnswerIndex;
                      final showFeedback = _selectedAnswerIndex != null;

                      Color? cardColor;
                      IconData? icon;
                      Color? iconColor;

                      if (showFeedback) {
                        if (isSelected && isCorrect) {
                          cardColor = Colors.green[50];
                          icon = Icons.check_circle;
                          iconColor = Colors.green;
                        } else if (isSelected && !isCorrect) {
                          cardColor = Colors.red[50];
                          icon = Icons.cancel;
                          iconColor = Colors.red;
                        } else if (!isSelected && isCorrect) {
                          cardColor = Colors.green[50];
                          icon = Icons.check_circle;
                          iconColor = Colors.green;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _selectAnswer(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Card(
                            color: cardColor,
                            elevation: showFeedback ? 2 : 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index), // A, B, C, D
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (icon != null)
                                    Icon(icon, color: iconColor, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Feedback
                    if (_selectedAnswerIndex != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedAnswerIndex == currentQuestion.correctAnswerIndex
                              ? Colors.green[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedAnswerIndex == currentQuestion.correctAnswerIndex
                                ? Colors.green
                                : Colors.orange,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedAnswerIndex == currentQuestion.correctAnswerIndex
                                  ? Icons.check_circle
                                  : Icons.info,
                              color: _selectedAnswerIndex == currentQuestion.correctAnswerIndex
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedAnswerIndex == currentQuestion.correctAnswerIndex
                                    ? 'Correct! ${currentQuestion.explanation}'
                                    : 'Incorrect. ${currentQuestion.explanation}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedAnswerIndex == currentQuestion.correctAnswerIndex
                                      ? Colors.green[900]
                                      : Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Next Button
                    if (_selectedAnswerIndex != null) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentQuestionIndex < questions.length - 1
                                    ? 'Next Question'
                                    : 'View Results',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final questions = QuizData.getQuestions();
    final percentage = ((_score / questions.length) * 100).round();
    String message;
    Color messageColor;

    if (percentage >= 80) {
      message = 'Excellent! You know Jordan very well!';
      messageColor = Colors.green;
    } else if (percentage >= 60) {
      message = 'Good job! You have good knowledge about Jordan.';
      messageColor = Colors.orange;
    } else {
      message = 'Keep learning! Explore more about Jordan.';
      messageColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor])),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, AppTheme.backgroundColor])),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Score Display
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: AppTheme.goldColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        'out of ${questions.length}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: messageColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: messageColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Answer Review
              const Text(
                'Your Answers:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ..._answers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;
                final question = questions[answer['questionIndex']];
                final selectedOption = question.options[answer['selectedAnswer']];
                final correctOption = question.options[question.correctAnswerIndex];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              answer['isCorrect']
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: answer['isCorrect']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.question,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your answer: $selectedOption',
                          style: TextStyle(
                            fontSize: 14,
                            color: answer['isCorrect']
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!answer['isCorrect']) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Correct answer: $correctOption',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Restart Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _restartQuiz,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text(
                        'Take Quiz Again',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


