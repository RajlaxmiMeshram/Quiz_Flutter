import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/components/answer_button.dart';

void main() {
  testWidgets('AnswerButton displays text and handles tap',
      (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnswerButton(
            text: 'Test Answer',
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    // Verify the button displays the correct text
    expect(find.text('Test Answer'), findsOneWidget);

    // Verify the button can be tapped
    expect(wasTapped, isFalse);
    await tester.tap(find.byType(AnswerButton));
    expect(wasTapped, isTrue);
  });

  testWidgets('AnswerButton is an ElevatedButton',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnswerButton(
            text: 'Test Answer',
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify the button is an ElevatedButton
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('AnswerButton centers text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnswerButton(
            text: 'Test Answer',
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify the text widget exists with center alignment
    final textWidget = tester.widget<Text>(find.text('Test Answer'));
    expect(textWidget.textAlign, TextAlign.center);
  });

  testWidgets('AnswerButton with empty text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnswerButton(
            text: '',
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify the button still renders
    expect(find.byType(AnswerButton), findsOneWidget);
  });

  testWidgets('AnswerButton with long text',
      (WidgetTester tester) async {
    const longText = 'This is a very long answer text that should still be displayed correctly in the button';
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnswerButton(
            text: longText,
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify the button displays the long text
    expect(find.text(longText), findsOneWidget);
  });
}
