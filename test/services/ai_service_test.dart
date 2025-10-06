import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';
import 'package:quiz_app/services/ai_service.dart';

void main() {
  group('AIService', () {
    final testQuestion = EnhancedQuizQuestion(
      id: '1',
      text: 'What is 2+2?',
      answers: ['3', '4', '5', '6'],
      correctAnswer: '4',
      category: 'Math',
      difficulty: 'easy',
      explanation: '2+2 equals 4',
    );

    test('should generate hint for question', () {
      final hint = AIService.generateHint(testQuestion);
      expect(hint, isNotEmpty);
      expect(hint, isA<String>());
    });

    test('should generate feedback based on score', () {
      final feedback = AIService.generateFeedback(
        correctAnswers: 8,
        totalQuestions: 10,
        questions: [testQuestion],
        userAnswers: ['4'],
      );
      expect(feedback, isNotEmpty);
      expect(feedback, isA<String>());
    });

    test('should generate different feedback for different scores', () {
      final perfectFeedback = AIService.generateFeedback(
        correctAnswers: 10,
        totalQuestions: 10,
        questions: [testQuestion],
        userAnswers: ['4'],
      );
      
      final poorFeedback = AIService.generateFeedback(
        correctAnswers: 3,
        totalQuestions: 10,
        questions: [testQuestion],
        userAnswers: ['3'],
      );
      
      expect(perfectFeedback, isNot(equals(poorFeedback)));
    });

    test('should generate recommendations', () {
      final userProgress = UserProgress.initial('test_user');
      final recommendations = AIService.generateRecommendations(
        userProgress: userProgress,
        recentQuestions: [testQuestion],
        userAnswers: ['4'],
      );
      
      expect(recommendations, isA<List<String>>());
    });

    test('should handle edge case - zero correct answers', () {
      final feedback = AIService.generateFeedback(
        correctAnswers: 0,
        totalQuestions: 10,
        questions: [testQuestion],
        userAnswers: ['3'],
      );
      expect(feedback, isNotEmpty);
    });

    test('should handle edge case - all correct answers', () {
      final feedback = AIService.generateFeedback(
        correctAnswers: 10,
        totalQuestions: 10,
        questions: [testQuestion],
        userAnswers: ['4'],
      );
      expect(feedback, isNotEmpty);
    });
  });
}
