import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';
import 'package:quiz_app/services/quiz_data_service.dart';

void main() {
  group('QuizDataService', () {
    test('should fetch trivia questions', () async {
      final questions = await QuizDataService.fetchTriviaQuestions(amount: 5);
      expect(questions, isA<List<EnhancedQuizQuestion>>());
      expect(questions.isNotEmpty, isTrue);
    });

    test('should fetch questions by category', () async {
      final questions = await QuizDataService.fetchQuestionsByCategory(
        category: 'Science',
        count: 5,
      );
      expect(questions, isA<List<EnhancedQuizQuestion>>());
      expect(questions.isNotEmpty, isTrue);
    });

    test('should fetch mixed questions', () async {
      final questions = await QuizDataService.fetchMixedQuestions(totalCount: 10);
      expect(questions, isA<List<EnhancedQuizQuestion>>());
      expect(questions.length, lessThanOrEqualTo(10));
    });

    test('should get available categories', () async {
      final categories = await QuizDataService.getAvailableCategories();
      expect(categories, isA<List<QuizCategory>>());
      expect(categories.isNotEmpty, isTrue);
      
      // Verify category structure
      final firstCategory = categories.first;
      expect(firstCategory.id, isNotEmpty);
      expect(firstCategory.name, isNotEmpty);
      expect(firstCategory.description, isNotEmpty);
      expect(firstCategory.iconUrl, isNotEmpty);
      expect(firstCategory.questionCount, greaterThan(0));
    });

    test('should handle API errors gracefully with fallback questions', () async {
      // Even if API fails, should return fallback questions
      final questions = await QuizDataService.fetchTriviaQuestions(amount: 5);
      expect(questions, isNotEmpty);
    });

    test('fallback questions should have valid structure', () async {
      final questions = await QuizDataService.fetchQuestionsByCategory(
        category: 'Flutter Development',
        count: 5,
      );
      
      for (final question in questions) {
        expect(question.id, isNotEmpty);
        expect(question.text, isNotEmpty);
        expect(question.answers, isNotEmpty);
        expect(question.correctAnswer, isNotEmpty);
        expect(question.category, isNotEmpty);
        expect(question.difficulty, isNotEmpty);
      }
    });

    test('should validate question correctness', () async {
      final questions = await QuizDataService.fetchQuestionsByCategory(
        category: 'Science',
        count: 3,
      );
      
      for (final question in questions) {
        // Correct answer should be in the answers list
        expect(question.answers, contains(question.correctAnswer));
        
        // isCorrect should work properly
        expect(question.isCorrect(question.correctAnswer), isTrue);
        
        // Wrong answers should return false
        final wrongAnswer = question.answers.firstWhere(
          (answer) => answer != question.correctAnswer,
          orElse: () => 'wrong',
        );
        if (wrongAnswer != question.correctAnswer) {
          expect(question.isCorrect(wrongAnswer), isFalse);
        }
      }
    });

    test('should shuffle answers without losing correct answer', () async {
      final questions = await QuizDataService.fetchQuestionsByCategory(
        category: 'History',
        count: 2,
      );
      
      for (final question in questions) {
        final shuffled = question.getShuffledAnswers();
        expect(shuffled, hasLength(question.answers.length));
        expect(shuffled, contains(question.correctAnswer));
      }
    });
  });
}
