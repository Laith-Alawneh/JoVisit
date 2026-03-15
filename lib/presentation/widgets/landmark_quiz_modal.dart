import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/landmark.dart';
import '../../models/quiz_question.dart';
import '../../domain/providers/gamification_provider.dart';
import '../../core/theme/app_theme.dart';
import 'confetti_widget.dart' as confetti_widget;

/// Full-screen quiz modal for landmark-specific trivia
/// 
/// Displays landmark-specific questions with instant feedback,
/// confetti animation on success, and badge unlocking
class LandmarkQuizModal extends StatefulWidget {
  final Landmark landmark;

  const LandmarkQuizModal({
    super.key,
    required this.landmark,
  });

  @override
  State<LandmarkQuizModal> createState() => _LandmarkQuizModalState();
}

class _LandmarkQuizModalState extends State<LandmarkQuizModal> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<QuizQuestion> get questions => widget.landmark.quizData;

  QuizQuestion? get currentQuestion {
    if (questions.isEmpty || _currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[_currentQuestionIndex];
  }

  bool get isLastQuestion => _currentQuestionIndex == questions.length - 1;

  bool get allQuestionsAnswered => _currentQuestionIndex >= questions.length;

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/success_chime.mp3'));
    } catch (e) {
      debugPrint('Audio file not found: $e');
    }
  }

  Future<void> _playErrorSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/wrong-buzzer.mp3'));
    } catch (e) {
      debugPrint('Audio file not found: $e');
      // If error sound not available, use haptic feedback
      HapticFeedback.vibrate();
    }
  }

  void _selectAnswer(int index) {
    if (_selectedAnswerIndex != null || currentQuestion == null) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isCorrect = index == currentQuestion!.correctAnswerIndex;
      _showFeedback = true;
    });

    HapticFeedback.mediumImpact();

    if (_isCorrect) {
      _playSuccessSound();
    } else {
      _playErrorSound();
    }
  }

  void _nextQuestion() {
    if (isLastQuestion) {
      _completeQuiz();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _showFeedback = false;
      });
    }
  }

  void _completeQuiz() {
    // Check if all questions were answered correctly
    // For simplicity, we'll unlock badge if user completes all questions
    // In a more sophisticated implementation, track correct answers
    final gamificationProvider = Provider.of<GamificationProvider>(
      context,
      listen: false,
    );
    
    gamificationProvider.unlockBadge(widget.landmark.id.toString());
    
    // Show confetti
    _confettiController.play();
    _playSuccessSound();
    
    // Auto-close after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Color _getAnswerColor(int index) {
    if (!_showFeedback || currentQuestion == null) {
      return Colors.white.withValues(alpha: 0.1);
    }

    if (index == _selectedAnswerIndex) {
      return _isCorrect ? Colors.green : Colors.red;
    }

    if (index == currentQuestion!.correctAnswerIndex && _showFeedback) {
      return Colors.green;
    }

    return Colors.white.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'No quiz available for this landmark',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (allQuestionsAnswered || currentQuestion == null) {
      return _buildCompletionScreen();
    }

    return Stack(
      children: [
        // Confetti overlay
        confetti_widget.ConfettiAnimation(controller: _confettiController),
        
        // Main quiz content
        Scaffold(
          backgroundColor: AppTheme.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              '${widget.landmark.name} Quiz',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),
                  
                  // Question
                  Text(
                    currentQuestion?.question ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Answer options
                  Expanded(
                    child: currentQuestion != null
                        ? ListView.builder(
                            itemCount: currentQuestion!.options.length,
                            itemBuilder: (context, index) {
                              return _buildAnswerOption(index);
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  
                  // Next button (if answer selected)
                  if (_showFeedback) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isLastQuestion ? 'Complete Quiz' : 'Next Question',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${questions.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              '${((_currentQuestionIndex + 1) / questions.length * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / questions.length,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildAnswerOption(int index) {
    if (currentQuestion == null) return const SizedBox.shrink();
    
    final isSelected = _selectedAnswerIndex == index;
    final isCorrectAnswer = index == currentQuestion!.correctAnswerIndex;
    final showCorrect = _showFeedback && isCorrectAnswer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getAnswerColor(index),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showCorrect
                  ? Colors.green
                  : isSelected && !_isCorrect
                      ? Colors.red
                      : Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentQuestion?.options[index] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (_showFeedback) ...[
                const SizedBox(width: 12),
                Icon(
                  showCorrect
                      ? Icons.check_circle
                      : isSelected && !_isCorrect
                          ? Icons.cancel
                          : null,
                  color: showCorrect
                      ? Colors.green
                      : isSelected && !_isCorrect
                          ? Colors.red
                          : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve unlocked the ${widget.landmark.name} badge!',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
