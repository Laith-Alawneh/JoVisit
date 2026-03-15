import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/quiz_data.dart';
import '../domain/providers/quiz_provider.dart';
import '../core/theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// ❌ BUG: Playing wrong audio file (clapping instead of success_chime)
  Future<void> _playSuccessSound() async {
    try {
      // ❌ BUG: Should be 'audio/success_chime.mp3' but using 'audio/clapping.mp3'
      await _audioPlayer.play(AssetSource('audio/clapping.mp3'));
    } catch (e) {
      debugPrint('Audio file not found: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.showResult) {
          return _buildResultScreen(context, quizProvider);
        }

        final question = quizProvider.currentQuestion;
        if (question == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.questions.length}'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      final isSelected = quizProvider.selectedAnswerIndex == index;
                      final isCorrect = index == question.correctAnswerIndex;
                      Color? cardColor;
                      IconData? icon;

                      if (quizProvider.selectedAnswerIndex != null) {
                        if (isSelected && isCorrect) {
                          cardColor = Colors.green[100];
                          icon = Icons.check_circle;
                        } else if (isSelected && !isCorrect) {
                          cardColor = Colors.red[100];
                          icon = Icons.cancel;
                        } else if (isCorrect) {
                          cardColor = Colors.green[50];
                          icon = Icons.check_circle;
                        }
                      }

                      return Card(
                        color: cardColor,
                        child: ListTile(
                          title: Text(question.options[index]),
                          trailing: icon != null ? Icon(icon) : null,
                          onTap: () {
                            if (quizProvider.selectedAnswerIndex == null) {
                              final isCorrect = quizProvider.selectAnswer(index);
                              if (isCorrect) {
                                _playSuccessSound();
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (quizProvider.selectedAnswerIndex != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => quizProvider.nextQuestion(),
                        child: const Text('Next Question'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultScreen(BuildContext context, QuizProvider quizProvider) {
    final score = quizProvider.score;
    final total = quizProvider.questions.length;
    final percentage = (score / total * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '$score / $total',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                quizProvider.restart();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
