import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../data/quiz_data.dart';
import '../models/quiz_question.dart';

/// Fully redesigned, animated quiz experience.
/// Fixes: borderRadius 0.0 buttons, missing progress, no animations.
class QuizScreenEnhanced extends StatefulWidget {
  const QuizScreenEnhanced({super.key});

  @override
  State<QuizScreenEnhanced> createState() => _QuizScreenEnhancedState();
}

class _QuizScreenEnhancedState extends State<QuizScreenEnhanced>
    with SingleTickerProviderStateMixin {
  final List<QuizQuestion> _questions = QuizData.getQuestions();
  late AnimationController _progressCtrl;

  int _currentQuestion = 0;
  int? _selectedAnswer;
  int _score = 0;
  bool _showResult = false;
  final List<Map<String, dynamic>> _answers = [];
  final AudioPlayer _audio = AudioPlayer();
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _updateProgress();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _confetti.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final target = (_currentQuestion + 1) / _questions.length;
    _progressCtrl.animateTo(target, curve: Curves.easeInOut);
  }

  Future<void> _playSound(bool correct) async {
    try {
      await _audio.play(AssetSource(
          correct ? 'audio/success_chime.mp3' : 'audio/wrong-buzzer.mp3'));
    } catch (_) {}
  }

  void _selectAnswer(int index) {
    if (_selectedAnswer != null) return;
    final q = _questions[_currentQuestion];
    final isCorrect = index == q.correctAnswerIndex;

    HapticFeedback.mediumImpact();
    setState(() {
      _selectedAnswer = index;
      if (isCorrect) _score++;
      _answers.add({
        'questionIndex': _currentQuestion,
        'selectedAnswer': index,
        'isCorrect': isCorrect,
      });
    });
    _playSound(isCorrect);
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
      });
      _updateProgress();
    } else {
      if (_score == _questions.length) _confetti.play();
      setState(() => _showResult = true);
    }
  }

  void _restart() {
    setState(() {
      _currentQuestion = 0;
      _selectedAnswer = null;
      _score = 0;
      _showResult = false;
      _answers.clear();
    });
    _progressCtrl.animateTo(1 / _questions.length);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResultScreen();

    final cs = Theme.of(context).colorScheme;
    final q = _questions[_currentQuestion];

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.6),
                  cs.surface,
                  cs.secondaryContainer.withValues(alpha: 0.3),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────────
                _buildHeader(context),

                // ── Animated progress bar ───────────────────────────────────
                _buildProgressBar(context),

                // ── Question & Answers ──────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Question card — keyed for AnimatedSwitcher
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                      begin: const Offset(0.06, 0),
                                      end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut)),
                              child: child,
                            ),
                          ),
                          child: _QuestionCard(
                            key: ValueKey(_currentQuestion),
                            question: q,
                            currentIndex: _currentQuestion,
                            total: _questions.length,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Answer buttons
                        ...q.options.asMap().entries.map(
                              (e) => _AnswerButton(
                                key: ValueKey('q${_currentQuestion}_a${e.key}'),
                                index: e.key,
                                text: e.value,
                                selectedAnswer: _selectedAnswer,
                                correctAnswer: q.correctAnswerIndex,
                                onTap: () => _selectAnswer(e.key),
                                delayMs: e.key * 60,
                              ),
                            ),

                        // Explanation card
                        if (_selectedAnswer != null) ...[
                          const SizedBox(height: 16),
                          _ExplanationCard(
                            isCorrect:
                                _selectedAnswer == q.correctAnswerIndex,
                            explanation: q.explanation,
                          ),
                          const SizedBox(height: 20),
                          _NextButton(
                            isLast: _currentQuestion == _questions.length - 1,
                            onTap: _nextQuestion,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Question counter chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentQuestion + 1} / ${_questions.length}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const Spacer(),
          // Score chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 16, color: AppTheme.goldColor),
                const SizedBox(width: 4),
                Text(
                  'Score: $_score',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _progressCtrl,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progressCtrl.value,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Result screen ──────────────────────────────────────────────────────────
  Widget _buildResultScreen() {
    final cs = Theme.of(context).colorScheme;
    final percentage = (_score / _questions.length * 100).round();
    final isPerfect = _score == _questions.length;
    final isGood = _score >= (_questions.length * 0.6).ceil();

    return Scaffold(
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                AppTheme.primaryGreen,
                AppTheme.primaryRed,
                AppTheme.goldColor,
                Colors.white,
              ],
            ),
          ),

          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.5),
                  cs.surface,
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Score circle
                  _ScoreCircle(
                    score: _score,
                    total: _questions.length,
                    percentage: percentage,
                    isPerfect: isPerfect,
                  ).animate().scale(
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    isPerfect
                        ? '🎉 Perfect Score!'
                        : isGood
                            ? '👍 Well Done!'
                            : '💪 Keep Practising!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: 8),

                  Text(
                    'You answered $_score out of ${_questions.length} correctly.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 500.ms),

                  const SizedBox(height: 28),

                  // Answer review
                  ..._answers.asMap().entries.map((e) {
                    final i = e.key;
                    final a = e.value;
                    final q = _questions[a['questionIndex'] as int];
                    return _ResultCard(
                      index: i,
                      question: q,
                      selectedAnswer: a['selectedAnswer'] as int,
                      isCorrect: a['isCorrect'] as bool,
                    );
                  }),

                  const SizedBox(height: 28),

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _restart,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try Again'),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms)
                      .slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Question card ────────────────────────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int currentIndex;
  final int total;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative accent line
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Answer button ────────────────────────────────────────────────────────────
class _AnswerButton extends StatelessWidget {
  final int index;
  final String text;
  final int? selectedAnswer;
  final int correctAnswer;
  final VoidCallback onTap;
  final int delayMs;

  const _AnswerButton({
    super.key,
    required this.index,
    required this.text,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.onTap,
    required this.delayMs,
  });

  _AnswerState get _state {
    if (selectedAnswer == null) return _AnswerState.idle;
    if (index == correctAnswer) return _AnswerState.correct;
    if (index == selectedAnswer) return _AnswerState.wrong;
    return _AnswerState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = _state;

    final bgColor = switch (state) {
      _AnswerState.correct => const Color(0xFF1B8A4E),
      _AnswerState.wrong   => const Color(0xFFB71C1C),
      _AnswerState.dimmed  => cs.surfaceContainerHighest.withValues(alpha: 0.5),
      _AnswerState.idle    => cs.surfaceContainerLow,
    };

    final textColor = switch (state) {
      _AnswerState.correct || _AnswerState.wrong => Colors.white,
      _AnswerState.dimmed  => cs.onSurface.withValues(alpha: 0.35),
      _AnswerState.idle    => cs.onSurface,
    };

    final borderColor = switch (state) {
      _AnswerState.correct => const Color(0xFF1B8A4E),
      _AnswerState.wrong   => const Color(0xFFB71C1C),
      _AnswerState.dimmed  => cs.outlineVariant.withValues(alpha: 0.3),
      _AnswerState.idle    => cs.outlineVariant,
    };

    final trailingIcon = switch (state) {
      _AnswerState.correct => Icons.check_circle_rounded,
      _AnswerState.wrong   => Icons.cancel_rounded,
      _AnswerState.dimmed || _AnswerState.idle => null,
    };

    // Letter labels: A, B, C, D
    final letter = String.fromCharCode(65 + index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: selectedAnswer == null ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Letter badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: state == _AnswerState.idle
                          ? cs.primaryContainer
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: state == _AnswerState.idle
                            ? cs.onPrimaryContainer
                            : textColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Answer text
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: state == _AnswerState.idle
                            ? FontWeight.w400
                            : FontWeight.w600,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                  ),

                  // Result icon
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, color: Colors.white, size: 22),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: delayMs.ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

enum _AnswerState { idle, correct, wrong, dimmed }

// ─── Explanation card ─────────────────────────────────────────────────────────
class _ExplanationCard extends StatelessWidget {
  final bool isCorrect;
  final String explanation;

  const _ExplanationCard({required this.isCorrect, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF1B8A4E).withValues(alpha: 0.12)
            : const Color(0xFFB71C1C).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF1B8A4E).withValues(alpha: 0.4)
              : const Color(0xFFB71C1C).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.lightbulb_rounded
                : Icons.info_outline_rounded,
            size: 20,
            color: isCorrect
                ? const Color(0xFF1B8A4E)
                : const Color(0xFFB71C1C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              explanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: cs.onSurface,
                  ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}

// ─── Next button ──────────────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;

  const _NextButton({required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded),
        label: Text(isLast ? 'See Results' : 'Next Question'),
      ),
    )
        .animate()
        .fadeIn(delay: 150.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

// ─── Score circle ─────────────────────────────────────────────────────────────
class _ScoreCircle extends StatelessWidget {
  final int score;
  final int total;
  final int percentage;
  final bool isPerfect;

  const _ScoreCircle({
    required this.score,
    required this.total,
    required this.percentage,
    required this.isPerfect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            isPerfect
                ? AppTheme.goldColor.withValues(alpha: 0.3)
                : cs.primaryContainer,
            cs.surface,
          ],
        ),
        border: Border.all(
          color: isPerfect ? AppTheme.goldColor : cs.primary,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPerfect ? AppTheme.goldColor : cs.primary).withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score/$total',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: isPerfect ? AppTheme.goldColor : cs.primary,
            ),
          ),
          Text(
            '$percentage%',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result card ──────────────────────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final int index;
  final QuizQuestion question;
  final int selectedAnswer;
  final bool isCorrect;

  const _ResultCard({
    required this.index,
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF1B8A4E).withValues(alpha: 0.08)
            : const Color(0xFFB71C1C).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF1B8A4E).withValues(alpha: 0.3)
              : const Color(0xFFB71C1C).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 18,
                color: isCorrect
                    ? const Color(0xFF1B8A4E)
                    : const Color(0xFFB71C1C),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Q${index + 1}: ${question.question}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Your answer: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextSpan(
                    text: question.options[selectedAnswer],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFB71C1C),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Correct: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextSpan(
                    text: question.options[question.correctAnswerIndex],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF1B8A4E),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate(delay: (index * 60 + 300).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1);
  }
}
