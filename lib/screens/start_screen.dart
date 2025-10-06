import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enhanced_quiz_question.dart';
import '../services/ai_service.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({
    super.key,
    required this.onStartQuiz,
    required this.onSelectCategory,
    required this.onViewProfile,
    this.userProgress,
  });

  final void Function() onStartQuiz;
  final void Function() onSelectCategory;
  final void Function() onViewProfile;
  final UserProgress? userProgress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header with user info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (userProgress != null)
                      Text(
                        '${userProgress!.perfectScores} Perfect Scores',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: onViewProfile,
                  icon: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Main content without fixed height (fixes overflow)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon/logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'AI-Powered Quiz',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Dynamic questions from open-source datasets\nwith intelligent feedback & personalized learning',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // Quick stats
                if (userProgress != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Quizzes', '${userProgress!.completedQuizzes.length}', Icons.quiz),
                        _buildStatItem('Perfect', '${userProgress!.perfectScores}', Icons.star),
                        _buildStatItem('Categories', '${userProgress!.categoryScores.length}', Icons.category),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // Action buttons
                Column(
                  children: [
                    _buildActionButton(
                      onPressed: onStartQuiz,
                      icon: Icons.play_arrow,
                      label: 'Quick Start',
                      subtitle: 'Mixed questions from all topics',
                      isPrimary: true,
                    ),

                    const SizedBox(height: 15),

                    _buildActionButton(
                      onPressed: onSelectCategory,
                      icon: Icons.category,
                      label: 'Choose Category',
                      subtitle: 'Pick your favorite topic',
                      isPrimary: false,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Motivational quote
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                AIService.getMotivationalQuote(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.transparent,
          foregroundColor: isPrimary ? Colors.deepPurple : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isPrimary ? BorderSide.none : const BorderSide(color: Colors.white, width: 1),
          ),
          elevation: isPrimary ? 5 : 0,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isPrimary
                          ? Colors.deepPurple.withOpacity(0.7)
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
