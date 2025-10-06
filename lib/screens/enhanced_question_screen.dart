import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enhanced_quiz_question.dart';
import '../services/ai_service.dart';

class EnhancedQuestionScreen extends StatefulWidget {
  const EnhancedQuestionScreen({
    super.key,
    required this.questions,
    required this.onSelectAnswer,
    required this.selectedAnswers,
  });

  final List<EnhancedQuizQuestion> questions;
  final void Function(String answer) onSelectAnswer;
  final List<String> selectedAnswers;

  @override
  State<EnhancedQuestionScreen> createState() => _EnhancedQuestionScreenState();
}

class _EnhancedQuestionScreenState extends State<EnhancedQuestionScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showHint = false;
  bool isAnswering = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    currentQuestionIndex = widget.selectedAnswers.length;
    _progressController.value = currentQuestionIndex / widget.questions.length;
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectAnswer(String answer) {
    if (isAnswering) return;

    setState(() {
      selectedAnswer = answer;
      isAnswering = true;
    });

    // Add a small delay for visual feedback
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onSelectAnswer(answer);

      if (currentQuestionIndex < widget.questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          showHint = false;
          isAnswering = false;
        });

        _progressController.animateTo(currentQuestionIndex / widget.questions.length);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestionIndex >= widget.questions.length) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final currentQuestion = widget.questions[currentQuestionIndex];
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header with progress
                Row(
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${currentQuestionIndex + 1}/${widget.questions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.greenAccent, Colors.blueAccent],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Category and difficulty badges
                Row(
                  children: [
                    _buildBadge(currentQuestion.category, Icons.category, Colors.blue),
                    const SizedBox(width: 10),
                    _buildBadge(
                      currentQuestion.difficulty.toUpperCase(),
                      Icons.speed,
                      _getDifficultyColor(currentQuestion.difficulty),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _toggleHint,
                      icon: Icon(
                        showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                        color: Colors.yellow,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Question content
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Question text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          currentQuestion.text,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Hint section
                      if (showHint) ...[
                        const SizedBox(height: 20),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.yellow.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Colors.yellow,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  AIService.generateHint(currentQuestion),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Answer options
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentQuestion.answers.length,
                        itemBuilder: (context, answerIndex) {
                          final answer = currentQuestion.answers[answerIndex];
                          final isSelected = selectedAnswer == answer;
                          final isCorrect = currentQuestion.isCorrect(answer);

                          Color backgroundColor;
                          Color borderColor;
                          Color textColor = Colors.white;

                          if (isAnswering && isSelected) {
                            if (isCorrect) {
                              backgroundColor = Colors.green.withValues(alpha: 0.3);
                              borderColor = Colors.green;
                            } else {
                              backgroundColor = Colors.red.withValues(alpha: 0.3);
                              borderColor = Colors.red;
                            }
                          } else if (isSelected) {
                            backgroundColor = Colors.white.withValues(alpha: 0.2);
                            borderColor = Colors.white;
                          } else {
                            backgroundColor = Colors.white.withValues(alpha: 0.1);
                            borderColor = Colors.white.withValues(alpha: 0.3);
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: InkWell(
                                onTap: isAnswering ? null : () => _selectAnswer(answer),
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: borderColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: borderColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + answerIndex), // A, B, C, D
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          answer,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      if (isAnswering && isSelected)
                                        Icon(
                                          isCorrect ? Icons.check_circle : Icons.cancel,
                                          color: isCorrect ? Colors.green : Colors.red,
                                          size: 24,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}