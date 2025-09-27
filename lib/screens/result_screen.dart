import 'package:flutter/material.dart';
import 'package:quiz_app/components/questions_summary.dart';
import 'package:quiz_app/data/questions.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.chosenAnswers, required this.onRestart,});
  final void Function() onRestart;
  final List<String> chosenAnswers;

  List<Map<String, Object>>getSummaryData()
  {
      final List<Map<String, Object>> summary = [];

      for(var i =0;i<chosenAnswers.length; i++){
        summary.add({
    'questions_index':i,
  'questions':questions[i].text,
  'correct_answer':questions[i].answers[0],
  'user_answer': chosenAnswers[i],
  });

  }
      return summary;
}

  @override
  Widget build(BuildContext context) {
    final numTotalQuestions = questions.length;
    final numCorrectQuestion = getSummaryData().where((data){
      return data['user_answer'] == data['correct_answer'];
    }).length;
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              'You answered $numCorrectQuestion out of $numTotalQuestions question correctly!',
            style: const TextStyle(
              fontSize: 14,
              fontWeight:FontWeight.bold,
              color: Colors.white,
            ) ,
            ),
            const SizedBox(height: 30),
            QuestionSummary(getSummaryData()),
            // const Text('List of answers and questions '),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.restart_alt),
              onPressed: onRestart,
              label: const Text('Restart quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
