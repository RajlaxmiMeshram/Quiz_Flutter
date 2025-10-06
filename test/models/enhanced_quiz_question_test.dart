import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';

void main() {
  group('EnhancedQuizQuestion', () {
    test('should create a valid EnhancedQuizQuestion', () {
      final question = EnhancedQuizQuestion(
        id: '1',
        text: 'What is 2+2?',
        answers: ['3', '4', '5', '6'],
        correctAnswer: '4',
        category: 'Math',
        difficulty: 'easy',
        explanation: '2+2 equals 4',
      );

      expect(question.id, '1');
      expect(question.text, 'What is 2+2?');
      expect(question.answers, hasLength(4));
      expect(question.correctAnswer, '4');
      expect(question.category, 'Math');
      expect(question.difficulty, 'easy');
      expect(question.explanation, '2+2 equals 4');
    });

    test('should correctly identify correct answer', () {
      final question = EnhancedQuizQuestion(
        id: '1',
        text: 'Test',
        answers: ['A', 'B', 'C'],
        correctAnswer: 'B',
        category: 'Test',
        difficulty: 'easy',
      );

      expect(question.isCorrect('B'), isTrue);
      expect(question.isCorrect('A'), isFalse);
      expect(question.isCorrect('C'), isFalse);
    });

    test('should shuffle answers without losing any', () {
      final question = EnhancedQuizQuestion(
        id: '1',
        text: 'Test',
        answers: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        category: 'Test',
        difficulty: 'easy',
      );

      final shuffled = question.getShuffledAnswers();
      expect(shuffled, hasLength(4));
      expect(shuffled, containsAll(['A', 'B', 'C', 'D']));
    });

    test('should convert to and from JSON', () {
      final question = EnhancedQuizQuestion(
        id: '1',
        text: 'Test question',
        answers: ['A', 'B', 'C'],
        correctAnswer: 'A',
        category: 'Test',
        difficulty: 'medium',
        explanation: 'Test explanation',
        tags: ['test', 'sample'],
      );

      final json = question.toJson();
      final fromJson = EnhancedQuizQuestion.fromJson(json);

      expect(fromJson.id, question.id);
      expect(fromJson.text, question.text);
      expect(fromJson.answers, question.answers);
      expect(fromJson.correctAnswer, question.correctAnswer);
      expect(fromJson.category, question.category);
      expect(fromJson.difficulty, question.difficulty);
      expect(fromJson.explanation, question.explanation);
      expect(fromJson.tags, question.tags);
    });

    test('should create from legacy format', () {
      final question = EnhancedQuizQuestion.fromLegacy(
        text: 'Legacy question',
        answers: ['Answer1', 'Answer2'],
        category: 'Flutter',
        difficulty: 'medium',
      );

      expect(question.text, 'Legacy question');
      expect(question.answers, ['Answer1', 'Answer2']);
      expect(question.correctAnswer, 'Answer1');
      expect(question.category, 'Flutter');
      expect(question.difficulty, 'medium');
    });
  });

  group('QuizCategory', () {
    test('should create a valid QuizCategory', () {
      final category = QuizCategory(
        id: '1',
        name: 'Science',
        description: 'Science questions',
        iconUrl: '🔬',
        questionCount: 25,
      );

      expect(category.id, '1');
      expect(category.name, 'Science');
      expect(category.description, 'Science questions');
      expect(category.iconUrl, '🔬');
      expect(category.questionCount, 25);
    });

    test('should convert to and from JSON', () {
      final category = QuizCategory(
        id: '1',
        name: 'Science',
        description: 'Science questions',
        iconUrl: '🔬',
        questionCount: 25,
      );

      final json = category.toJson();
      final fromJson = QuizCategory.fromJson(json);

      expect(fromJson.id, category.id);
      expect(fromJson.name, category.name);
      expect(fromJson.description, category.description);
      expect(fromJson.iconUrl, category.iconUrl);
      expect(fromJson.questionCount, category.questionCount);
    });
  });

  group('UserProgress', () {
    test('should create initial UserProgress', () {
      final progress = UserProgress.initial('user123');

      expect(progress.userId, 'user123');
      expect(progress.categoryScores, isEmpty);
      expect(progress.categoryAttempts, isEmpty);
      expect(progress.completedQuizzes, isEmpty);
      expect(progress.totalScore, 0);
      expect(progress.perfectScores, 0);
    });

    test('should convert to and from JSON', () {
      final progress = UserProgress(
        userId: 'user123',
        categoryScores: {'Science': 80},
        categoryAttempts: {'Science': 5},
        completedQuizzes: ['quiz1', 'quiz2'],
        totalScore: 150,
        perfectScores: 2,
        lastPlayed: DateTime(2025, 1, 1),
      );

      final json = progress.toJson();
      final fromJson = UserProgress.fromJson(json);

      expect(fromJson.userId, progress.userId);
      expect(fromJson.categoryScores, progress.categoryScores);
      expect(fromJson.categoryAttempts, progress.categoryAttempts);
      expect(fromJson.completedQuizzes, progress.completedQuizzes);
      expect(fromJson.totalScore, progress.totalScore);
      expect(fromJson.perfectScores, progress.perfectScores);
    });
  });
}
