import 'package:qr_scanner/models/quiz_question.dart';

const questions = [
  QuizQuestion(
    'Which programming language is used to develop Flutter apps?',
    ['Dart', 'Java', 'Kotlin', 'Swift'],
  ),
  QuizQuestion(
    'What widget is used to create layouts in Flutter?',
    ['All of the above', 'Container', 'Column / Row', 'Scaffold'],
  ),
  QuizQuestion(
    'Which widget is used to add padding around another widget?',
    ['Padding', 'Container', 'Align', 'SizedBox'],
  ),
  QuizQuestion(
    'What is the root widget of a Flutter app that provides material design?',
    ['MaterialApp', 'Container', 'Scaffold', 'AppBar'],
  ),
  QuizQuestion(
    'Which method is called when a StatefulWidget is first created?',
    ['initState()', 'build()', 'dispose()', 'createState()'],
  ),
  QuizQuestion(
    'What is the purpose of pubspec.yaml file in Flutter?',
    ['To store assets, dependencies, and metadata', 'To define app routes', 'To write UI code', 'To manage state'],
  ),
  QuizQuestion(
    'Which widget allows scrolling when the content overflows the screen?',
    ['ListView', 'Column', 'Stack', 'Expanded'],
  ),
];
