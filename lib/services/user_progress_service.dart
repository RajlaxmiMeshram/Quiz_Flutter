import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_quiz_question.dart';

class UserProgressService {
  static const String _userProgressKey = 'user_progress';
  static const String _userIdKey = 'user_id';
  
  // Save user progress
  static Future<void> saveUserProgress(UserProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(progress.toJson());
      await prefs.setString(_userProgressKey, progressJson);
    } catch (e) {
      print('Error saving user progress: $e');
    }
  }

  // Load user progress
  static Future<UserProgress> loadUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_userProgressKey);
      
      if (progressJson != null) {
        final progressData = json.decode(progressJson);
        return UserProgress.fromJson(progressData);
      }
    } catch (e) {
      print('Error loading user progress: $e');
    }
    
    // Return initial progress if none exists
    final userId = await _getOrCreateUserId();
    return UserProgress.initial(userId);
  }

  // Update progress after quiz completion
  static Future<UserProgress> updateProgressAfterQuiz({
    required List<EnhancedQuizQuestion> questions,
    required List<String> userAnswers,
    required String quizId,
  }) async {
    final currentProgress = await loadUserProgress();
    
    // Calculate score
    int correctAnswers = 0;
    final Map<String, int> categoryScores = Map.from(currentProgress.categoryScores);
    final Map<String, int> categoryAttempts = Map.from(currentProgress.categoryAttempts);
    
    for (int i = 0; i < questions.length && i < userAnswers.length; i++) {
      final question = questions[i];
      final isCorrect = question.isCorrect(userAnswers[i]);
      
      if (isCorrect) {
        correctAnswers++;
      }
      
      // Update category stats
      final category = question.category;
      categoryScores[category] = (categoryScores[category] ?? 0) + (isCorrect ? 1 : 0);
      categoryAttempts[category] = (categoryAttempts[category] ?? 0) + 1;
    }
    
    // Check for perfect score
    final isPerfectScore = correctAnswers == questions.length;
    final newPerfectScores = currentProgress.perfectScores + (isPerfectScore ? 1 : 0);
    
    // Create updated progress
    final updatedProgress = UserProgress(
      userId: currentProgress.userId,
      categoryScores: categoryScores,
      categoryAttempts: categoryAttempts,
      completedQuizzes: [...currentProgress.completedQuizzes, quizId],
      totalScore: currentProgress.totalScore + correctAnswers,
      perfectScores: newPerfectScores,
      lastPlayed: DateTime.now(),
    );
    
    // Save updated progress
    await saveUserProgress(updatedProgress);
    
    return updatedProgress;
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStatistics() async {
    final progress = await loadUserProgress();
    
    final totalAttempts = progress.categoryAttempts.values.fold(0, (a, b) => a + b);
    final totalCorrect = progress.categoryScores.values.fold(0, (a, b) => a + b);
    
    final overallAccuracy = totalAttempts > 0 ? (totalCorrect / totalAttempts) * 100 : 0;
    
    // Calculate category accuracies
    final Map<String, double> categoryAccuracies = {};
    for (final category in progress.categoryScores.keys) {
      final correct = progress.categoryScores[category] ?? 0;
      final attempts = progress.categoryAttempts[category] ?? 1;
      categoryAccuracies[category] = (correct / attempts) * 100;
    }
    
    // Find best and worst categories
    String? bestCategory;
    String? worstCategory;
    double bestAccuracy = 0;
    double worstAccuracy = 100;
    
    for (final entry in categoryAccuracies.entries) {
      if (entry.value > bestAccuracy) {
        bestAccuracy = entry.value;
        bestCategory = entry.key;
      }
      if (entry.value < worstAccuracy) {
        worstAccuracy = entry.value;
        worstCategory = entry.key;
      }
    }
    
    return {
      'totalQuizzes': progress.completedQuizzes.length,
      'totalQuestions': totalAttempts,
      'totalCorrect': totalCorrect,
      'overallAccuracy': overallAccuracy,
      'perfectScores': progress.perfectScores,
      'categoryAccuracies': categoryAccuracies,
      'bestCategory': bestCategory,
      'worstCategory': worstCategory,
      'bestAccuracy': bestAccuracy,
      'worstAccuracy': worstAccuracy,
      'lastPlayed': progress.lastPlayed,
      'daysActive': _calculateDaysActive(progress),
    };
  }

  // Reset user progress
  static Future<void> resetUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userProgressKey);
    } catch (e) {
      print('Error resetting user progress: $e');
    }
  }

  // Get or create user ID
  static Future<String> _getOrCreateUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(_userIdKey, userId);
      }
      
      return userId;
    } catch (e) {
      print('Error getting/creating user ID: $e');
      return 'user_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Calculate days active (simplified)
  static int _calculateDaysActive(UserProgress progress) {
    final now = DateTime.now();
    final firstPlay = progress.lastPlayed;
    return now.difference(firstPlay).inDays + 1;
  }

  // Get achievement progress
  static Future<Map<String, dynamic>> getAchievementProgress() async {
    final progress = await loadUserProgress();
    final stats = await getUserStatistics();
    
    final achievements = <String, Map<String, dynamic>>{};
    
    // Perfect Score achievements
    achievements['perfect_scores'] = {
      'title': 'Perfect Scores',
      'description': 'Get perfect scores on quizzes',
      'current': progress.perfectScores,
      'milestones': [1, 3, 5, 10, 20, 50],
      'icon': '🏆',
    };
    
    // Quiz Completion achievements
    achievements['quiz_completion'] = {
      'title': 'Quiz Master',
      'description': 'Complete quizzes',
      'current': progress.completedQuizzes.length,
      'milestones': [5, 10, 25, 50, 100, 200],
      'icon': '📚',
    };
    
    // Accuracy achievements
    final overallAccuracy = stats['overallAccuracy'] as double;
    achievements['accuracy'] = {
      'title': 'Accuracy Expert',
      'description': 'Maintain high accuracy',
      'current': overallAccuracy.round(),
      'milestones': [70, 80, 85, 90, 95, 99],
      'icon': '🎯',
    };
    
    // Category Master achievements
    final categoryCount = progress.categoryScores.keys.length;
    achievements['category_master'] = {
      'title': 'Category Explorer',
      'description': 'Play different categories',
      'current': categoryCount,
      'milestones': [2, 3, 5, 7, 10, 15],
      'icon': '🌍',
    };
    
    return achievements;
  }

  // Check if user has unlocked new achievements
  static Future<List<Map<String, dynamic>>> checkNewAchievements(
    UserProgress oldProgress,
    UserProgress newProgress,
  ) async {
    final List<Map<String, dynamic>> newAchievements = [];
    
    // Check perfect score milestones
    final perfectScoreMilestones = [1, 3, 5, 10, 20, 50];
    for (final milestone in perfectScoreMilestones) {
      if (oldProgress.perfectScores < milestone && newProgress.perfectScores >= milestone) {
        newAchievements.add({
          'title': 'Perfect Score Master',
          'description': 'Achieved $milestone perfect scores!',
          'icon': '🏆',
          'type': 'perfect_scores',
          'milestone': milestone,
        });
      }
    }
    
    // Check quiz completion milestones
    final quizMilestones = [5, 10, 25, 50, 100];
    for (final milestone in quizMilestones) {
      if (oldProgress.completedQuizzes.length < milestone && 
          newProgress.completedQuizzes.length >= milestone) {
        newAchievements.add({
          'title': 'Quiz Champion',
          'description': 'Completed $milestone quizzes!',
          'icon': '📚',
          'type': 'quiz_completion',
          'milestone': milestone,
        });
      }
    }
    
    // Check category exploration
    final oldCategoryCount = oldProgress.categoryScores.keys.length;
    final newCategoryCount = newProgress.categoryScores.keys.length;
    
    if (newCategoryCount > oldCategoryCount) {
      newAchievements.add({
        'title': 'Explorer',
        'description': 'Discovered a new category!',
        'icon': '🌟',
        'type': 'category_explorer',
        'milestone': newCategoryCount,
      });
    }
    
    return newAchievements;
  }

  // Export user data (for backup/sharing)
  static Future<String> exportUserData() async {
    try {
      final progress = await loadUserProgress();
      final stats = await getUserStatistics();
      final achievements = await getAchievementProgress();
      
      final exportData = {
        'progress': progress.toJson(),
        'statistics': stats,
        'achievements': achievements,
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      return json.encode(exportData);
    } catch (e) {
      print('Error exporting user data: $e');
      return '{}';
    }
  }

  // Import user data (from backup)
  static Future<bool> importUserData(String jsonData) async {
    try {
      final data = json.decode(jsonData);
      
      if (data['progress'] != null) {
        final progress = UserProgress.fromJson(data['progress']);
        await saveUserProgress(progress);
        return true;
      }
    } catch (e) {
      print('Error importing user data: $e');
    }
    
    return false;
  }
}
