import 'package:flutter/material.dart';
import 'package:qr_scanner/data/questions.dart';
import 'package:qr_scanner/screens/question_screen.dart';
import 'package:qr_scanner/screens/result_screen.dart';
import 'package:qr_scanner/screens/start_screen.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List<String> selectedAnswer = [];
  var activeScreen = 'start-screen';

  // Widget? activeScreen;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   activeScreen = StartScreen(switchScreen);
  // }

  void switchScreen() {
    setState(() {
      // activeScreen = const QuestionScreen();
      activeScreen = 'questions-screen';
    });
  }

void chooseAnswer(String answer){
  selectedAnswer.add(answer);
  if(selectedAnswer.length == questions.length){
    setState(() {
      selectedAnswer = [];
      activeScreen = 'result-screen';
    });
  }

}

  @override
  Widget build(BuildContext context) {

    Widget screenWidget = StartScreen(switchScreen);
    // final screenWidget = activeScreen == 'start-screen'
    //     ? StartScreen(switchScreen)
    //     : const QuestionScreen();
  if(activeScreen == 'questions-screen'){
    screenWidget = QuestionScreen(onSelectAnswer: chooseAnswer);
  }

  if(activeScreen == 'result-screen'){
    screenWidget = const ResultScreen();
  }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 103, 57, 181),
                Color.fromARGB(255, 43, 26, 73)
              ],
            ),
          ),
          // child: activeScreen,
          child: screenWidget,
        ),
      ),
    );
  }
}
