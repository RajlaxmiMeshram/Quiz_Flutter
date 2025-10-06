import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';
import 'package:quiz_app/screens/enhanced_question_screen.dart';
import 'package:quiz_app/screens/enhanced_result_screen.dart';

void main() {
  group('Quiz Flow Integration Tests', () {
    final testQuestions = [
      EnhancedQuizQuestion(
        id: '1',
        text: 'What is 2+2?',
        answers: ['3', '4', '5', '6'],
        correctAnswer: '4',
        category: 'Math',
        difficulty: 'easy',
      ),
      EnhancedQuizQuestion(
        id: '2',
        text: 'What is 3+3?',
        answers: ['5', '6', '7', '8'],
        correctAnswer: '6',
        category: 'Math',
        difficulty: 'easy',
      ),
    ];

    testWidgets('Question screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: EnhancedQuestionScreen(
                questions: testQuestions,
                onSelectAnswer: (answer) {},
                selectedAnswers: [],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify first question is displayed
      expect(find.text('What is 2+2?'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('Answer options are interactive', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: EnhancedQuestionScreen(
                questions: testQuestions,
                onSelectAnswer: (answer) {},
                selectedAnswers: [],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify answer options exist and are interactive
      expect(find.text('4'), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('Result screen displays after quiz completion', (WidgetTester tester) async {
      final userAnswers = ['4', '6'];
      final userProgress = UserProgress.initial('test_user');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: EnhancedResultScreen(
                questions: testQuestions,
                userAnswers: userAnswers,
                userProgress: userProgress,
                onRestart: () {},
                onHome: () {},
                onNewQuiz: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify result screen elements
      expect(find.text('Quiz Complete!'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('PERFECT SCORE!'), findsOneWidget);
    });

    testWidgets('Hint button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: EnhancedQuestionScreen(
                questions: testQuestions,
                onSelectAnswer: (answer) {},
                selectedAnswers: [],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify hint button exists (either outline or filled)
      expect(find.byIcon(Icons.lightbulb_outline), findsWidgets);
    });

    testWidgets('Progress indicator shows correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: EnhancedQuestionScreen(
                questions: testQuestions,
                onSelectAnswer: (answer) {},
                selectedAnswers: [],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial progress
      expect(find.text('1/${testQuestions.length}'), findsOneWidget);
    });
  });
}
