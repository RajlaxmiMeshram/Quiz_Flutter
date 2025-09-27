import 'package:flutter/material.dart';

class QuestionSummary extends StatelessWidget {
  const QuestionSummary(this.summaryData, {super.key});

  final List<Map<String, dynamic>> summaryData; // Changed Object to dynamic for flexibility

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          children: summaryData.map((data) {
            return Row(
              children: [
                Text(((data['questions_index'] as int) + 1).toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),

                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(data['questions'] as String,
                    style: const TextStyle(fontSize: 12,
                    color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    const SizedBox(height: 5),
                    Text(data['user_answer']as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(data['correct_answer']as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.lightBlue,
                    )
                    ),
                  ],
                ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}