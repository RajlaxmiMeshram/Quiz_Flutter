import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';
import 'package:quiz_app/screens/enhanced_question_screen.dart';

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

  testWidgets('EnhancedQuestionScreen displays question and options',
      (WidgetTester tester) async {
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
              onSelectAnswer: (String answer) {},
              selectedAnswers: [],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify question text is displayed
    expect(find.text('What is 2+2?'), findsOneWidget);

    // Verify all options are displayed
    for (final option in testQuestions[0].answers) {
      expect(find.text(option), findsOneWidget);
    }
  });

  testWidgets('EnhancedQuestionScreen has tappable answer options',
      (WidgetTester tester) async {
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
              onSelectAnswer: (String answer) {},
              selectedAnswers: [],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify answer options are tappable (InkWell widgets)
    final answerOptions = find.byType(InkWell);
    expect(answerOptions, findsWidgets);
    
    // Verify all answer texts are present
    for (final answer in testQuestions[0].answers) {
      expect(find.text(answer), findsOneWidget);
    }
  });

  testWidgets('EnhancedQuestionScreen shows progress indicator',
      (WidgetTester tester) async {
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
              onSelectAnswer: (String answer) {},
              selectedAnswers: [],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify progress text is displayed
    expect(find.text('1/${testQuestions.length}'), findsOneWidget);
  });

  testWidgets('EnhancedQuestionScreen shows category and difficulty badges',
      (WidgetTester tester) async {
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
              onSelectAnswer: (String answer) {},
              selectedAnswers: [],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify category badge is displayed
    expect(find.text('Math'), findsOneWidget);
    
    // Verify difficulty badge is displayed
    expect(find.text('EASY'), findsOneWidget);
  });

  testWidgets('EnhancedQuestionScreen shows hint button',
      (WidgetTester tester) async {
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
              onSelectAnswer: (String answer) {},
              selectedAnswers: [],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify hint button exists
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
  });
}
