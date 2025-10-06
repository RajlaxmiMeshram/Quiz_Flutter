import 'dart:convert';
import 'dart:math';
import '../models/enhanced_quiz_question.dart';

class AIService {
  // Simulated AI responses - In a real app, you'd integrate with actual AI services
  static final List<String> _encouragingMessages = [
    "Great job! Your knowledge is impressive! 🌟",
    "Excellent work! Keep up the fantastic learning! 🎉",
    "Outstanding performance! You're on fire! 🔥",
    "Brilliant! Your dedication to learning shows! ✨",
    "Superb! You're mastering these topics wonderfully! 🏆",
  ];

  static final List<String> _motivationalMessages = [
    "Don't worry! Every expert was once a beginner. Keep learning! 💪",
    "Great effort! Learning is a journey, not a destination. 🚀",
    "Nice try! Each question teaches us something new. 📚",
    "Keep going! Your curiosity will lead to great knowledge! 🌱",
    "Good attempt! Remember, mistakes are stepping stones to success! ⭐",
  ];

  static final List<String> _perfectScoreMessages = [
    "INCREDIBLE! Perfect score! You're absolutely brilliant! 🎊🏆",
    "AMAZING! 100% correct! You've mastered this topic! 🌟🎉",
    "OUTSTANDING! Flawless performance! You're a true champion! 👑✨",
    "PHENOMENAL! Perfect answers! Your knowledge is exceptional! 🚀🔥",
    "SPECTACULAR! All correct! You're an absolute genius! 💎🎯",
  ];

  // Generate personalized feedback based on performance
  static String generateFeedback({
    required int correctAnswers,
    required int totalQuestions,
    required List<EnhancedQuizQuestion> questions,
    required List<String> userAnswers,
  }) {
    final double percentage = (correctAnswers / totalQuestions) * 100;
    
    if (percentage == 100) {
      return _getRandomMessage(_perfectScoreMessages);
    } else if (percentage >= 80) {
      return _getRandomMessage(_encouragingMessages);
    } else if (percentage >= 60) {
      return "Good work! You got ${correctAnswers} out of ${totalQuestions} correct. "
          "Focus on the areas where you missed questions to improve further! 📈";
    } else {
      return _getRandomMessage(_motivationalMessages) + 
          " You scored ${correctAnswers}/${totalQuestions}. Review the explanations to boost your knowledge! 🎯";
    }
  }

  // Generate personalized recommendations
  static List<String> generateRecommendations({
    required UserProgress userProgress,
    required List<EnhancedQuizQuestion> recentQuestions,
    required List<String> userAnswers,
  }) {
    final List<String> recommendations = [];
    
    // Analyze weak categories
    final Map<String, double> categoryPerformance = {};
    for (final entry in userProgress.categoryScores.entries) {
      final attempts = userProgress.categoryAttempts[entry.key] ?? 1;
      categoryPerformance[entry.key] = entry.value / attempts;
    }
    
    // Find weakest category
    if (categoryPerformance.isNotEmpty) {
      final weakestCategory = categoryPerformance.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;
      
      recommendations.add(
        "💡 Consider practicing more $weakestCategory questions to improve your skills!"
      );
    }
    
    // Analyze recent performance
    int recentCorrect = 0;
    for (int i = 0; i < recentQuestions.length && i < userAnswers.length; i++) {
      if (recentQuestions[i].isCorrect(userAnswers[i])) {
        recentCorrect++;
      }
    }
    
    final recentPercentage = recentQuestions.isNotEmpty 
        ? (recentCorrect / recentQuestions.length) * 100 
        : 0;
    
    if (recentPercentage < 70) {
      recommendations.add(
        "📚 Try reviewing the explanations for questions you missed - they contain valuable insights!"
      );
    }
    
    // Suggest new categories
    final playedCategories = userProgress.categoryScores.keys.toSet();
    final allCategories = {'Science', 'History', 'Technology', 'Flutter Development', 'Geography', 'Literature'};
    final unplayedCategories = allCategories.difference(playedCategories);
    
    if (unplayedCategories.isNotEmpty) {
      final newCategory = unplayedCategories.first;
      recommendations.add(
        "🌟 Explore the $newCategory category for a new challenge!"
      );
    }
    
    // Difficulty recommendations
    if (recentPercentage > 85) {
      recommendations.add(
        "🚀 You're doing great! Try harder difficulty questions for an extra challenge!"
      );
    } else if (recentPercentage < 50) {
      recommendations.add(
        "🎯 Consider starting with easier questions to build confidence and knowledge!"
      );
    }
    
    // Streak recommendations
    if (userProgress.perfectScores >= 3) {
      recommendations.add(
        "🏆 Amazing streak! You're on fire! Keep challenging yourself with diverse topics!"
      );
    }
    
    return recommendations.take(3).toList();
  }

  // Generate intelligent hints for questions
  static String generateHint(EnhancedQuizQuestion question) {
    final hints = [
      "💡 Think about the key concepts in ${question.category}",
      "🤔 Consider what you know about ${question.difficulty} level topics",
      "📝 Break down the question into smaller parts",
      "🔍 Look for keywords in the question that might guide you",
      "💭 Eliminate answers that seem obviously incorrect first",
    ];
    
    // Add category-specific hints
    switch (question.category.toLowerCase()) {
      case 'science':
        hints.add("🔬 Think about scientific principles and natural laws");
        break;
      case 'history':
        hints.add("📚 Consider the time period and historical context");
        break;
      case 'technology':
        hints.add("💻 Think about how technology has evolved");
        break;
      case 'flutter development':
        hints.add("📱 Consider Flutter widgets and Dart language features");
        break;
    }
    
    return _getRandomMessage(hints);
  }

  // Analyze learning patterns
  static Map<String, dynamic> analyzeLearningPatterns(UserProgress userProgress) {
    final analysis = <String, dynamic>{};
    
    // Calculate overall performance
    final totalAttempts = userProgress.categoryAttempts.values.fold(0, (a, b) => a + b);
    final totalScore = userProgress.categoryScores.values.fold(0, (a, b) => a + b);
    
    analysis['overallAccuracy'] = totalAttempts > 0 ? (totalScore / totalAttempts) * 100 : 0;
    analysis['totalQuizzes'] = userProgress.completedQuizzes.length;
    analysis['perfectScores'] = userProgress.perfectScores;
    
    // Find strongest and weakest categories
    if (userProgress.categoryScores.isNotEmpty) {
      final categoryPerformance = <String, double>{};
      for (final entry in userProgress.categoryScores.entries) {
        final attempts = userProgress.categoryAttempts[entry.key] ?? 1;
        categoryPerformance[entry.key] = (entry.value / attempts) * 100;
      }
      
      final sortedCategories = categoryPerformance.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      analysis['strongestCategory'] = sortedCategories.first.key;
      analysis['weakestCategory'] = sortedCategories.last.key;
      analysis['categoryPerformance'] = categoryPerformance;
    }
    
    // Learning streak
    analysis['currentStreak'] = _calculateStreak(userProgress);
    
    return analysis;
  }

  // Generate study plan
  static List<String> generateStudyPlan(UserProgress userProgress) {
    final studyPlan = <String>[];
    final analysis = analyzeLearningPatterns(userProgress);
    
    studyPlan.add("📋 Your Personalized Study Plan:");
    
    // Focus on weak areas
    if (analysis['weakestCategory'] != null) {
      studyPlan.add("1. 🎯 Focus on ${analysis['weakestCategory']} - practice 5 questions daily");
    }
    
    // Maintain strong areas
    if (analysis['strongestCategory'] != null) {
      studyPlan.add("2. ⭐ Maintain your strength in ${analysis['strongestCategory']} - review weekly");
    }
    
    // Progressive difficulty
    final accuracy = analysis['overallAccuracy'] as double;
    if (accuracy > 80) {
      studyPlan.add("3. 🚀 Challenge yourself with hard difficulty questions");
    } else if (accuracy < 60) {
      studyPlan.add("3. 📚 Build foundation with easy to medium questions");
    } else {
      studyPlan.add("3. 📈 Mix medium and hard questions to improve gradually");
    }
    
    // Consistency
    studyPlan.add("4. ⏰ Practice 10 minutes daily for consistent improvement");
    studyPlan.add("5. 🔄 Review explanations for all incorrect answers");
    
    return studyPlan;
  }

  // Helper methods
  static String _getRandomMessage(List<String> messages) {
    return messages[Random().nextInt(messages.length)];
  }

  static int _calculateStreak(UserProgress userProgress) {
    // Simplified streak calculation
    // In a real app, you'd track daily quiz completion
    return userProgress.perfectScores;
  }

  // Generate motivational quote
  static String getMotivationalQuote() {
    final quotes = [
      "\"The only way to learn mathematics is to do mathematics.\" - Paul Halmos 📐",
      "\"Learning never exhausts the mind.\" - Leonardo da Vinci 🧠",
      "\"The more that you read, the more things you will know.\" - Dr. Seuss 📚",
      "\"Knowledge is power.\" - Francis Bacon ⚡",
      "\"The beautiful thing about learning is nobody can take it away from you.\" - B.B. King 🎵",
      "\"Education is the most powerful weapon which you can use to change the world.\" - Nelson Mandela 🌍",
      "\"The expert in anything was once a beginner.\" - Helen Hayes 🌱",
      "\"Success is the sum of small efforts repeated day in and day out.\" - Robert Collier 🔄",
    ];
    
    return _getRandomMessage(quotes);
  }
}
