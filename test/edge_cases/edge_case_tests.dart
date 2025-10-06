import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';
import 'package:quiz_app/services/quiz_data_service.dart';

void main() {
  group('Edge Case Tests', () {
    group('Question Edge Cases', () {
      test('should handle question with very long text', () {
        final longText = 'A' * 1000; // 1000 characters
        final question = EnhancedQuizQuestion(
          id: '1',
          text: longText,
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        );

        expect(question.text, hasLength(1000));
        expect(question.text, equals(longText));
      });

      test('should handle question with special characters', () {
        final specialText = 'What is 2+2? <>&"\'';
        final question = EnhancedQuizQuestion(
          id: '1',
          text: specialText,
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        );

        expect(question.text, contains('<'));
        expect(question.text, contains('>'));
        expect(question.text, contains('&'));
      });

      test('should handle question with unicode characters', () {
        final unicodeText = 'What is π? 🎯 测试';
        final question = EnhancedQuizQuestion(
          id: '1',
          text: unicodeText,
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        );

        expect(question.text, contains('π'));
        expect(question.text, contains('🎯'));
        expect(question.text, contains('测试'));
      });

      test('should handle question with many answers', () {
        final manyAnswers = List.generate(20, (i) => 'Answer $i');
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: manyAnswers,
          correctAnswer: 'Answer 0',
          category: 'Test',
          difficulty: 'easy',
        );

        expect(question.answers, hasLength(20));
        expect(question.isCorrect('Answer 0'), isTrue);
      });

      test('should handle question with duplicate answers', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', 'A', 'B', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        );

        expect(question.answers, hasLength(4));
        expect(question.isCorrect('A'), isTrue);
      });

      test('should handle empty explanation', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
          explanation: '',
        );

        expect(question.explanation, isEmpty);
      });

      test('should handle null tags', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
          tags: null,
        );

        expect(question.tags, isNull);
      });

      test('should handle empty tags list', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
          tags: [],
        );

        expect(question.tags, isEmpty);
      });
    });

    group('Answer Validation Edge Cases', () {
      test('should handle case-sensitive answer comparison', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['Apple', 'apple', 'APPLE'],
          correctAnswer: 'Apple',
          category: 'Test',
          difficulty: 'easy',
        );

        expect(question.isCorrect('Apple'), isTrue);
        expect(question.isCorrect('apple'), isFalse);
        expect(question.isCorrect('APPLE'), isFalse);
      });

      test('should handle whitespace in answers', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', ' A', 'A ', ' A '],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        );

        expect(question.isCorrect('A'), isTrue);
        expect(question.isCorrect(' A'), isFalse);
      });

      test('should handle empty string as answer', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['', 'A', 'B'],
          correctAnswer: '',
          category: 'Test',
          difficulty: 'easy',
        );

        expect(question.isCorrect(''), isTrue);
        expect(question.isCorrect('A'), isFalse);
      });

      test('should handle numeric strings as answers', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'What is 2+2?',
          answers: ['3', '4', '5', '6'],
          correctAnswer: '4',
          category: 'Math',
          difficulty: 'easy',
        );

        expect(question.isCorrect('4'), isTrue);
        expect(question.isCorrect('04'), isFalse);
        expect(question.isCorrect('4.0'), isFalse);
      });
    });

    group('UserProgress Edge Cases', () {
      test('should handle negative scores (should not happen but test anyway)', () {
        final progress = UserProgress(
          userId: 'test',
          categoryScores: {'Test': -10},
          categoryAttempts: {'Test': 1},
          completedQuizzes: [],
          totalScore: -10,
          perfectScores: 0,
          lastPlayed: DateTime.now(),
        );

        expect(progress.totalScore, -10);
        expect(progress.categoryScores['Test'], -10);
      });

      test('should handle very large scores', () {
        final progress = UserProgress(
          userId: 'test',
          categoryScores: {'Test': 999999},
          categoryAttempts: {'Test': 10000},
          completedQuizzes: List.generate(10000, (i) => 'quiz_$i'),
          totalScore: 999999,
          perfectScores: 5000,
          lastPlayed: DateTime.now(),
        );

        expect(progress.totalScore, 999999);
        expect(progress.perfectScores, 5000);
        expect(progress.completedQuizzes, hasLength(10000));
      });

      test('should handle empty category scores', () {
        final progress = UserProgress(
          userId: 'test',
          categoryScores: {},
          categoryAttempts: {},
          completedQuizzes: [],
          totalScore: 0,
          perfectScores: 0,
          lastPlayed: DateTime.now(),
        );

        expect(progress.categoryScores, isEmpty);
        expect(progress.categoryAttempts, isEmpty);
      });

      test('should handle future date for lastPlayed', () {
        final futureDate = DateTime.now().add(const Duration(days: 365));
        final progress = UserProgress(
          userId: 'test',
          categoryScores: {},
          categoryAttempts: {},
          completedQuizzes: [],
          totalScore: 0,
          perfectScores: 0,
          lastPlayed: futureDate,
        );

        expect(progress.lastPlayed.isAfter(DateTime.now()), isTrue);
      });

      test('should handle very old date for lastPlayed', () {
        final oldDate = DateTime(1900, 1, 1);
        final progress = UserProgress(
          userId: 'test',
          categoryScores: {},
          categoryAttempts: {},
          completedQuizzes: [],
          totalScore: 0,
          perfectScores: 0,
          lastPlayed: oldDate,
        );

        expect(progress.lastPlayed.year, 1900);
      });
    });

    group('QuizCategory Edge Cases', () {
      test('should handle category with very long name', () {
        final longName = 'A' * 500;
        final category = QuizCategory(
          id: '1',
          name: longName,
          description: 'Test',
          iconUrl: '🎯',
          questionCount: 10,
        );

        expect(category.name, hasLength(500));
      });

      test('should handle category with zero questions', () {
        final category = QuizCategory(
          id: '1',
          name: 'Empty Category',
          description: 'No questions',
          iconUrl: '❌',
          questionCount: 0,
        );

        expect(category.questionCount, 0);
      });

      test('should handle category with negative question count', () {
        final category = QuizCategory(
          id: '1',
          name: 'Invalid Category',
          description: 'Negative count',
          iconUrl: '❌',
          questionCount: -5,
        );

        expect(category.questionCount, -5);
      });

      test('should handle category with special characters in name', () {
        final category = QuizCategory(
          id: '1',
          name: 'Science & Math <Advanced>',
          description: 'Test & Learn',
          iconUrl: '🔬',
          questionCount: 10,
        );

        expect(category.name, contains('&'));
        expect(category.name, contains('<'));
        expect(category.name, contains('>'));
      });
    });

    group('API and Data Fetching Edge Cases', () {
      test('should handle fetching with zero count', () async {
        final questions = await QuizDataService.fetchTriviaQuestions(amount: 0);
        expect(questions, isA<List<EnhancedQuizQuestion>>());
      });

      test('should handle fetching with very large count', () async {
        final questions = await QuizDataService.fetchTriviaQuestions(amount: 1000);
        expect(questions, isA<List<EnhancedQuizQuestion>>());
        // API might limit the actual count returned
      });

      test('should handle invalid category name', () async {
        final questions = await QuizDataService.fetchQuestionsByCategory(
          category: 'NonExistentCategory12345',
          count: 5,
        );
        // Should return fallback questions
        expect(questions, isNotEmpty);
      });

      test('should handle empty category string', () async {
        final questions = await QuizDataService.fetchQuestionsByCategory(
          category: '',
          count: 5,
        );
        expect(questions, isNotEmpty);
      });

      test('should handle category with special characters', () async {
        final questions = await QuizDataService.fetchQuestionsByCategory(
          category: 'Science & Math <Advanced>',
          count: 5,
        );
        expect(questions, isNotEmpty);
      });
    });

    group('JSON Serialization Edge Cases', () {
      test('should handle JSON with missing optional fields', () {
        final json = {
          'id': '1',
          'text': 'Test',
          'answers': ['A', 'B'],
          'correctAnswer': 'A',
          'category': 'Test',
          'difficulty': 'easy',
          // Missing explanation and tags
        };

        final question = EnhancedQuizQuestion.fromJson(json);
        expect(question.explanation, isNull);
        expect(question.tags, isNull);
      });

      test('should handle JSON with null values', () {
        final json = {
          'id': '1',
          'text': 'Test',
          'answers': ['A', 'B'],
          'correctAnswer': 'A',
          'category': 'Test',
          'difficulty': 'easy',
          'explanation': null,
          'tags': null,
        };

        final question = EnhancedQuizQuestion.fromJson(json);
        expect(question.explanation, isNull);
        expect(question.tags, isNull);
      });

      test('should handle JSON with empty arrays', () {
        final json = {
          'id': '1',
          'text': 'Test',
          'answers': [],
          'correctAnswer': 'A',
          'category': 'Test',
          'difficulty': 'easy',
        };

        // This might throw an error or handle gracefully
        expect(() => EnhancedQuizQuestion.fromJson(json), returnsNormally);
      });
    });

    group('Shuffle Edge Cases', () {
      test('should handle shuffling single answer', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        );

        final shuffled = question.getShuffledAnswers();
        expect(shuffled, hasLength(1));
        expect(shuffled[0], 'A');
      });

      test('should handle shuffling two answers', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', 'B'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        );

        final shuffled = question.getShuffledAnswers();
        expect(shuffled, hasLength(2));
        expect(shuffled, containsAll(['A', 'B']));
      });

      test('should shuffle multiple times with different results', () {
        final question = EnhancedQuizQuestion(
          id: '1',
          text: 'Test',
          answers: ['A', 'B', 'C', 'D', 'E', 'F'],
          correctAnswer: 'A',
          category: 'Test',
          difficulty: 'easy',
        );

        final shuffled1 = question.getShuffledAnswers();
        final shuffled2 = question.getShuffledAnswers();
        
        // With 6 items, it's very unlikely they'll be in the same order
        // But we can't guarantee they're different, so we just check they're valid
        expect(shuffled1, hasLength(6));
        expect(shuffled2, hasLength(6));
        expect(shuffled1, containsAll(['A', 'B', 'C', 'D', 'E', 'F']));
        expect(shuffled2, containsAll(['A', 'B', 'C', 'D', 'E', 'F']));
      });
    });
  });
}
