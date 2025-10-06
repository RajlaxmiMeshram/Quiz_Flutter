import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/enhanced_quiz_question.dart';
import '../services/ai_service.dart';
import '../services/meme_service.dart';

class EnhancedResultScreen extends StatefulWidget {
  const EnhancedResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.userProgress,
    required this.onRestart,
    required this.onHome,
    required this.onNewQuiz,
  });

  final List<EnhancedQuizQuestion> questions;
  final List<String> userAnswers;
  final UserProgress userProgress;
  final void Function() onRestart;
  final void Function() onHome;
  final void Function() onNewQuiz;

  @override
  State<EnhancedResultScreen> createState() => _EnhancedResultScreenState();
}

class _EnhancedResultScreenState extends State<EnhancedResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _celebrationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _celebrationAnimation;

  int correctAnswers = 0;
  double percentage = 0;
  bool isPerfectScore = false;
  String aiFeedback = '';
  List<String> recommendations = [];
  Map<String, String>? celebrationMeme;
  bool showCelebration = false;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutBack),
    );

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    _calculateResults();
    _generateFeedback();
    _checkForCelebration();

    _scoreController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _calculateResults() {
    correctAnswers = 0;
    for (int i = 0; i < widget.questions.length && i < widget.userAnswers.length; i++) {
      if (widget.questions[i].isCorrect(widget.userAnswers[i])) {
        correctAnswers++;
      }
    }

    percentage = (correctAnswers / widget.questions.length) * 100;
    isPerfectScore = correctAnswers == widget.questions.length;
  }

  void _generateFeedback() {
    aiFeedback = AIService.generateFeedback(
      correctAnswers: correctAnswers,
      totalQuestions: widget.questions.length,
      questions: widget.questions,
      userAnswers: widget.userAnswers,
    );

    recommendations = AIService.generateRecommendations(
      userProgress: widget.userProgress,
      recentQuestions: widget.questions,
      userAnswers: widget.userAnswers,
    );
  }

  void _checkForCelebration() async {
    if (isPerfectScore) {
      showCelebration = MemeService.shouldShowSpecialCelebration(
        currentPerfectScores: widget.userProgress.perfectScores,
        totalQuizzesTaken: widget.userProgress.completedQuizzes.length,
        isFirstPerfectScore: widget.userProgress.perfectScores == 1,
      );

      if (showCelebration) {
        try {
          celebrationMeme = await MemeService.getCelebrationMeme();
          _celebrationController.forward();
        } catch (e) {
          debugPrint('Error loading celebration meme: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                Text(
                  'Quiz Complete!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // Score display
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Circular progress indicator
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _scoreAnimation.value * (percentage / 100),
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getScoreColor(percentage),
                                  ),
                                ),
                                Text(
                                  '${(_scoreAnimation.value * percentage).round()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            '$correctAnswers out of ${widget.questions.length} correct',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),

                          if (isPerfectScore) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.yellow),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.yellow, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    'PERFECT SCORE!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // AI Feedback
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'AI Feedback',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        aiFeedback,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recommendations
                if (recommendations.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Recommendations',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...recommendations.map((recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            recommendation,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),

                const SizedBox(height: 40), // Replace Spacer with fixed spacing

                // Action buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onRestart,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onNewQuiz,
                            icon: const Icon(Icons.quiz),
                            label: const Text('New Quiz'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onHome,
                        icon: const Icon(Icons.home),
                        label: const Text('Back to Home'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Celebration overlay
          if (showCelebration && celebrationMeme != null)
            AnimatedBuilder(
              animation: _celebrationAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _celebrationAnimation.value,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.8),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🎉 PERFECT SCORE! 🎉',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: celebrationMeme!['url']!,
                                width: 250,
                                height: 200,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 250,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 250,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text('🎉\nCelebration!'),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              celebrationMeme!['caption']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showCelebration = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text('Awesome!'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}