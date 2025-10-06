import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';
import 'package:quiz_app/services/user_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('UserProgressService', () {
    setUp(() async {
      // Initialize SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
    });

    test('should load initial user progress', () async {
      final progress = await UserProgressService.loadUserProgress();
      expect(progress, isA<UserProgress>());
      expect(progress.userId, isNotEmpty);
      expect(progress.totalScore, 0);
      expect(progress.perfectScores, 0);
    });

    test('should update progress after quiz completion', () async {
      final questions = [
        EnhancedQuizQuestion(
          id: '1',
          text: 'Test Q1',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        ),
        EnhancedQuizQuestion(
          id: '2',
          text: 'Test Q2',
          answers: ['C', 'D'],
          correctAnswer: 'C',
          category: 'Test',
          difficulty: 'easy',
        ),
      ];

      final userAnswers = ['A', 'C']; // All correct
      
      final progress = await UserProgressService.updateProgressAfterQuiz(
        questions: questions,
        userAnswers: userAnswers,
        quizId: 'test_quiz_1',
      );

      expect(progress.totalScore, 2);
      expect(progress.perfectScores, 1);
      expect(progress.completedQuizzes, contains('test_quiz_1'));
    });

    test('should track category-specific scores', () async {
      final questions = [
        EnhancedQuizQuestion(
          id: '1',
          text: 'Science Q1',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Science',
          difficulty: 'easy',
        ),
      ];

      final progress = await UserProgressService.updateProgressAfterQuiz(
        questions: questions,
        userAnswers: ['A'],
        quizId: 'science_quiz_1',
      );

      expect(progress.categoryScores.containsKey('Science'), isTrue);
      expect(progress.categoryAttempts.containsKey('Science'), isTrue);
      expect(progress.categoryScores['Science'], 1);
      expect(progress.categoryAttempts['Science'], 1);
    });

    test('should handle partial correct answers', () async {
      final questions = [
        EnhancedQuizQuestion(
          id: '1',
          text: 'Test Q1',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        ),
        EnhancedQuizQuestion(
          id: '2',
          text: 'Test Q2',
          answers: ['C', 'D'],
          correctAnswer: 'C',
          category: 'Test',
          difficulty: 'easy',
        ),
      ];

      final userAnswers = ['A', 'D']; // One correct, one wrong
      
      final progress = await UserProgressService.updateProgressAfterQuiz(
        questions: questions,
        userAnswers: userAnswers,
        quizId: 'test_quiz_2',
      );

      expect(progress.totalScore, 1); // Only 1 correct
      expect(progress.perfectScores, 0); // Not a perfect score
    });

    test('should persist progress across sessions', () async {
      final questions = [
        EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        ),
      ];

      await UserProgressService.updateProgressAfterQuiz(
        questions: questions,
        userAnswers: ['A'],
        quizId: 'test_quiz_3',
      );

      // Load progress again to simulate app restart
      final progress = await UserProgressService.loadUserProgress();
      
      expect(progress.totalScore, greaterThan(0));
      expect(progress.completedQuizzes, contains('test_quiz_3'));
    });

    test('should reset progress', () async {
      // First add some progress
      final questions = [
        EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        ),
      ];

      await UserProgressService.updateProgressAfterQuiz(
        questions: questions,
        userAnswers: ['A'],
        quizId: 'test_quiz_4',
      );

      // Reset progress
      await UserProgressService.resetUserProgress();

      final progress = await UserProgressService.loadUserProgress();
      expect(progress.totalScore, 0);
      expect(progress.perfectScores, 0);
      expect(progress.completedQuizzes, isEmpty);
    });

    test('should get user statistics', () async {
      final questions = List.generate(
        10,
        (index) => EnhancedQuizQuestion(
          id: '$index',
          text: 'Test Q$index',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        ),
      );

      // Answer 7 out of 10 correctly
      final userAnswers = ['A', 'A', 'A', 'A', 'A', 'A', 'A', 'B', 'B', 'B'];
      
      await UserProgressService.updateProgressAfterQuiz(
        questions: questions,
        userAnswers: userAnswers,
        quizId: 'test_quiz_5',
      );

      final stats = await UserProgressService.getUserStatistics();
      expect(stats['totalQuizzes'], 1);
      expect(stats['totalCorrect'], 7);
      expect(stats['overallAccuracy'], greaterThan(0));
    });
  });
}
