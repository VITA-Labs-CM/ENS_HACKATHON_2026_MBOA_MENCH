import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Interface de quiz — QCM, Vrai/Faux, réponse courte.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.chapterId});

  final String chapterId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  String _shortAnswer = '';
  bool _showResult = false;
  bool _finished = false;
  int _secondsLeft = 300;
  Timer? _timer;
  final _shortController = TextEditingController();

  List<QuizQuestion> get _questions => MockData.quizQuestions;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0 && !_finished) {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shortController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final q = _questions[_currentIndex];
    String? answer = q.type == QuizQuestionType.shortAnswer
        ? _shortController.text.trim()
        : _selectedAnswer;

    if (answer == null || answer.isEmpty) return;

    final correct = answer.toLowerCase() == q.correctAnswer.toLowerCase();
    if (correct) _score++;

    setState(() => _showResult = true);
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _shortController.clear();
        _showResult = false;
      });
    } else {
      setState(() => _finished = true);
      _timer?.cancel();
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      final pct = (_score / _questions.length * 100).round();
      final passed = pct >= AppConstants.chapterUnlockScore;
      return Scaffold(
        appBar: AppBar(title: const Text('Résultat')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  passed ? Icons.emoji_events : Icons.replay,
                  size: 80,
                  color: passed ? AppColors.emeraldGreen : AppColors.accentOrange,
                ),
                const SizedBox(height: 24),
                Text('$pct %', style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: passed ? AppColors.emeraldGreen : AppColors.accentOrange,
                    )),
                Text('$_score / ${_questions.length} bonnes réponses'),
                const SizedBox(height: 16),
                Text(
                  passed
                      ? 'Chapitre suivant débloqué !'
                      : 'Il faut ${AppConstants.chapterUnlockScore} % pour continuer.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                LoadingButton(
                  label: passed ? 'Continuer' : 'Réessayer',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${_questions.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 4),
                  Text(_formatTime(_secondsLeft)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProgressBar(progress: progress, label: 'Progression'),
            const SizedBox(height: 8),
            Text('Score actuel : $_score', style: TextStyle(color: AppColors.darkGray)),
            const SizedBox(height: 24),
            Text(
              q.question,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildAnswerWidget(q),
            ),
            if (_showResult && q.explanation != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(q.explanation!),
              ),
            LoadingButton(
              label: _showResult ? 'Suivant' : 'Valider',
              onPressed: _showResult ? _nextQuestion : _submitAnswer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerWidget(QuizQuestion q) {
    if (q.type == QuizQuestionType.shortAnswer) {
      return TextField(
        controller: _shortController,
        enabled: !_showResult,
        decoration: const InputDecoration(hintText: 'Votre réponse...'),
        onSubmitted: (_) => _submitAnswer(),
      );
    }

    return ListView(
      children: q.options.map((opt) {
        final isSelected = _selectedAnswer == opt;
        final isCorrect = opt == q.correctAnswer;
        Color? tileColor;
        if (_showResult) {
          if (isCorrect) tileColor = AppColors.emeraldGreen.withValues(alpha: 0.15);
          else if (isSelected) tileColor = AppColors.errorRed.withValues(alpha: 0.15);
        }

        return Card(
          color: tileColor,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(opt),
            leading: Radio<String>(
              value: opt,
              groupValue: _selectedAnswer,
              onChanged: _showResult ? null : (v) => setState(() => _selectedAnswer = v),
            ),
            onTap: _showResult ? null : () => setState(() => _selectedAnswer = opt),
          ),
        );
      }).toList(),
    );
  }
}
