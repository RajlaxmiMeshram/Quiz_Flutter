import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';
import 'package:quiz_app/screens/enhanced_result_screen.dart';

void main() {
  final testQuestions = [
    EnhancedQuizQuestion(
      id: '1',
      text: 'What is 2+2?',
      answers: ['3', '4', '5', '6'],
      correctAnswer: '4',
      category: 'Math',
      difficulty: 'easy',
      explanation: '2+2 equals 4',
    ),
    EnhancedQuizQuestion(
      id: '2',
      text: 'What is the capital of France?',
      answers: ['London', 'Berlin', 'Paris', 'Madrid'],
      correctAnswer: 'Paris',
      category: 'Geography',
      difficulty: 'easy',
      explanation: 'Paris is the capital of France',
    ),
  ];

  final testAnswers = ['4', 'Paris'];
  final testUserProgress = UserProgress.initial('test_user');

  testWidgets('EnhancedResultScreen shows correct score', (WidgetTester tester) async {
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
              userAnswers: testAnswers,
              userProgress: testUserProgress,
              onRestart: () {},
              onHome: () {},
              onNewQuiz: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the score is displayed correctly (100% in this case)
    expect(find.text('2 out of 2 correct'), findsOneWidget);
  });

  testWidgets('EnhancedResultScreen shows action buttons', (WidgetTester tester) async {
    bool restartPressed = false;
    bool homePressed = false;
    bool newQuizPressed = false;

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
              userAnswers: testAnswers,
              userProgress: testUserProgress,
              onRestart: () {
                restartPressed = true;
              },
              onHome: () {
                homePressed = true;
              },
              onNewQuiz: () {
                newQuizPressed = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify buttons exist
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('New Quiz'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);

    // Scroll to make buttons visible and tap them
    await tester.dragUntilVisible(
      find.text('Try Again'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );
    await tester.tap(find.text('Try Again'), warnIfMissed: false);
    await tester.pump();
    expect(restartPressed, isTrue);

    await tester.dragUntilVisible(
      find.text('New Quiz'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );
    await tester.tap(find.text('New Quiz'), warnIfMissed: false);
    await tester.pump();
    expect(newQuizPressed, isTrue);

    await tester.dragUntilVisible(
      find.text('Back to Home'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );
    await tester.tap(find.text('Back to Home'), warnIfMissed: false);
    await tester.pump();
    expect(homePressed, isTrue);
  });

  testWidgets('EnhancedResultScreen shows AI feedback section', (WidgetTester tester) async {
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
              userAnswers: testAnswers,
              userProgress: testUserProgress,
              onRestart: () {},
              onHome: () {},
              onNewQuiz: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AI feedback section is displayed
    expect(find.text('AI Feedback'), findsOneWidget);
  });

  testWidgets('EnhancedResultScreen shows percentage', (WidgetTester tester) async {
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
              userAnswers: testAnswers,
              userProgress: testUserProgress,
              onRestart: () {},
              onHome: () {},
              onNewQuiz: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify percentage is displayed (100% for all correct answers)
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('EnhancedResultScreen shows perfect score badge', (WidgetTester tester) async {
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
              userAnswers: testAnswers,
              userProgress: testUserProgress,
              onRestart: () {},
              onHome: () {},
              onNewQuiz: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify perfect score badge is displayed
    expect(find.text('PERFECT SCORE!'), findsOneWidget);
  });
}
