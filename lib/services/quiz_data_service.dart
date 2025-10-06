import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/enhanced_quiz_question.dart';

class QuizDataService {
  static const String _triviaApiBase = 'https://opentdb.com/api.php';
  static const String _jServiceBase = 'https://jservice.io/api';
  
  // Fallback questions in case APIs are unavailable
  static final List<EnhancedQuizQuestion> _fallbackQuestions = [
    EnhancedQuizQuestion(
      id: 'flutter_1',
      text: 'Which programming language is used to develop Flutter apps?',
      answers: ['Dart', 'Java', 'Kotlin', 'Swift'],
      correctAnswer: 'Dart',
      category: 'Flutter Development',
      difficulty: 'easy',
      explanation: 'Flutter uses Dart as its primary programming language, developed by Google.',
      tags: ['flutter', 'dart', 'programming'],
    ),
    EnhancedQuizQuestion(
      id: 'flutter_2',
      text: 'What widget is used to create layouts in Flutter?',
      answers: ['All of the above', 'Container', 'Column / Row', 'Scaffold'],
      correctAnswer: 'All of the above',
      category: 'Flutter Development',
      difficulty: 'medium',
      explanation: 'Flutter provides multiple widgets for layouts including Container, Column/Row, and Scaffold.',
      tags: ['flutter', 'widgets', 'layout'],
    ),
    EnhancedQuizQuestion(
      id: 'science_1',
      text: 'What is the chemical symbol for gold?',
      answers: ['Au', 'Ag', 'Go', 'Gd'],
      correctAnswer: 'Au',
      category: 'Science',
      difficulty: 'easy',
      explanation: 'Gold\'s chemical symbol Au comes from the Latin word "aurum".',
      tags: ['chemistry', 'elements', 'science'],
    ),
    EnhancedQuizQuestion(
      id: 'history_1',
      text: 'In which year did World War II end?',
      answers: ['1945', '1944', '1946', '1943'],
      correctAnswer: '1945',
      category: 'History',
      difficulty: 'easy',
      explanation: 'World War II ended in 1945 with the surrender of Japan in September.',
      tags: ['history', 'world war', 'dates'],
    ),
    EnhancedQuizQuestion(
      id: 'tech_1',
      text: 'Who founded Microsoft?',
      answers: ['Bill Gates and Paul Allen', 'Steve Jobs', 'Mark Zuckerberg', 'Larry Page'],
      correctAnswer: 'Bill Gates and Paul Allen',
      category: 'Technology',
      difficulty: 'medium',
      explanation: 'Microsoft was founded by Bill Gates and Paul Allen in 1975.',
      tags: ['technology', 'microsoft', 'founders'],
    ),
    EnhancedQuizQuestion(
      id: 'science_2',
      text: 'What is the chemical formula for water?',
      answers: ['H2O', 'CO2', 'NaCl', 'CH4'],
      correctAnswer: 'H2O',
      category: 'Science',
      difficulty: 'easy',
      explanation: 'Water consists of two hydrogen atoms and one oxygen atom.',
      tags: ['chemistry', 'water', 'science'],
    ),
    EnhancedQuizQuestion(
      id: 'tech_2',
      text: 'What does CPU stand for?',
      answers: ['Central Processing Unit', 'Computer Processing Unit', 'Central Program Unit', 'Computer Program Unit'],
      correctAnswer: 'Central Processing Unit',
      category: 'Technology',
      difficulty: 'easy',
      explanation: 'CPU stands for Central Processing Unit, the main processor of a computer.',
      tags: ['computer', 'hardware', 'technology'],
    ),
    EnhancedQuizQuestion(
      id: 'history_2',
      text: 'Who was the first person to walk on the moon?',
      answers: ['Neil Armstrong', 'Buzz Aldrin', 'John Glenn', 'Alan Shepard'],
      correctAnswer: 'Neil Armstrong',
      category: 'History',
      difficulty: 'easy',
      explanation: 'Neil Armstrong was the first human to step onto the Moon on July 20, 1969.',
      tags: ['space', 'moon', 'history'],
    ),
  ];

  // Fetch questions from Open Trivia Database
  static Future<List<EnhancedQuizQuestion>> fetchTriviaQuestions({
    int amount = 10,
    String? category,
    String difficulty = 'medium',
  }) async {
    try {
      String url = '$_triviaApiBase?amount=$amount&type=multiple';
      
      // Add category if specified (convert category name to ID)
      if (category != null) {
        final categoryId = _getCategoryId(category);
        if (categoryId != null) {
          url += '&category=$categoryId';
        }
      }
      
      // Add difficulty
      url += '&difficulty=$difficulty';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        return results.map((questionData) {
          final List<String> incorrectAnswers = List<String>.from(questionData['incorrect_answers']);
          final String correctAnswer = questionData['correct_answer'];
          
          // Combine and shuffle answers
          final List<String> allAnswers = [correctAnswer, ...incorrectAnswers];
          allAnswers.shuffle();
          
          return EnhancedQuizQuestion(
            id: 'trivia_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
            text: _decodeHtmlEntities(questionData['question']),
            answers: allAnswers.map((answer) => _decodeHtmlEntities(answer)).toList(),
            correctAnswer: _decodeHtmlEntities(correctAnswer),
            category: questionData['category'],
            difficulty: questionData['difficulty'],
            explanation: 'Great job! Keep learning and exploring new topics.',
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching trivia questions: $e');
    }
    
    return _getFallbackQuestions(category: category);
  }

  // Map category names to Open Trivia Database category IDs
  static int? _getCategoryId(String categoryName) {
    final categoryMap = {
      'General Knowledge': 9,
      'Entertainment: Books': 10,
      'Entertainment: Film': 11,
      'Entertainment: Music': 12,
      'Entertainment: Musicals & Theatres': 13,
      'Entertainment: Television': 14,
      'Entertainment: Video Games': 15,
      'Entertainment: Board Games': 16,
      'Science & Nature': 17,
      'Science: Computers': 18,
      'Science: Mathematics': 19,
      'Mythology': 20,
      'Sports': 21,
      'Geography': 22,
      'History': 23,
      'Politics': 24,
      'Art': 25,
      'Celebrities': 26,
      'Animals': 27,
      'Vehicles': 28,
      'Entertainment: Comics': 29,
      'Science: Gadgets': 30,
      'Entertainment: Japanese Anime & Manga': 31,
      'Entertainment: Cartoon & Animations': 32,
      // Common simplified names
      'Science': 17,
      'Technology': 18,
      'Flutter Development': null, // Use fallback questions
    };
    
    return categoryMap[categoryName];
  }

  // Fetch questions from jService (Jeopardy questions)
  static Future<List<EnhancedQuizQuestion>> fetchJeopardyQuestions({
    int count = 10,
  }) async {
    try {
      final response = await http.get(Uri.parse('$_jServiceBase/random?count=$count'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        return data.where((item) => item['question'] != null && item['answer'] != null)
            .take(count)
            .map((questionData) {
          // Generate plausible wrong answers (this is a simplified approach)
          final String correctAnswer = _cleanJeopardyAnswer(questionData['answer']);
          final List<String> wrongAnswers = _generateWrongAnswers(correctAnswer, questionData['category']['title']);
          
          final List<String> allAnswers = [correctAnswer, ...wrongAnswers];
          allAnswers.shuffle();
          
          return EnhancedQuizQuestion(
            id: 'jeopardy_${questionData['id']}',
            text: _cleanJeopardyQuestion(questionData['question']),
            answers: allAnswers,
            correctAnswer: correctAnswer,
            category: questionData['category']['title'] ?? 'General Knowledge',
            difficulty: _mapJeopardyDifficulty(questionData['value']),
            explanation: 'This question is from the popular game show Jeopardy!',
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching Jeopardy questions: $e');
    }
    
    return _getFallbackQuestions();
  }

  // Get questions by category
  static Future<List<EnhancedQuizQuestion>> fetchQuestionsByCategory({
    required String category,
    int count = 10,
  }) async {
    print('Fetching questions for category: $category');
    
    // Try to get questions from API first
    final triviaQuestions = await fetchTriviaQuestions(
      amount: count,
      category: category,
      difficulty: 'medium',
    );
    
    if (triviaQuestions.isNotEmpty) {
      return triviaQuestions.take(count).toList();
    }
    
    // Fallback to category-specific fallback questions
    return _getFallbackQuestions(category: category).take(count).toList();
  }

  // Get mixed questions from multiple sources
  static Future<List<EnhancedQuizQuestion>> fetchMixedQuestions({
    int totalCount = 10,
  }) async {
    final List<EnhancedQuizQuestion> allQuestions = [];
    
    try {
      // Get questions from different sources
      final triviaQuestions = await fetchTriviaQuestions(amount: totalCount ~/ 2);
      final jeopardyQuestions = await fetchJeopardyQuestions(count: totalCount ~/ 2);
      
      allQuestions.addAll(triviaQuestions);
      allQuestions.addAll(jeopardyQuestions);
      
      // If we don't have enough questions, add fallback questions
      if (allQuestions.length < totalCount) {
        final remainingCount = totalCount - allQuestions.length;
        final fallbackQuestions = _getFallbackQuestions().take(remainingCount);
        allQuestions.addAll(fallbackQuestions);
      }
      
      // Shuffle and return the requested count
      allQuestions.shuffle();
      return allQuestions.take(totalCount).toList();
    } catch (e) {
      print('Error fetching mixed questions: $e');
      return _getFallbackQuestions().take(totalCount).toList();
    }
  }

  // Get available categories
  static Future<List<QuizCategory>> getAvailableCategories() async {
    try {
      final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categories = data['trivia_categories'];
        
        return categories.map((cat) => QuizCategory(
          id: cat['id'].toString(),
          name: cat['name'],
          description: 'Explore questions about ${cat['name']}',
          iconUrl: _getCategoryIcon(cat['name']),
          questionCount: Random().nextInt(50) + 10, // Simulated count
        )).toList();
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
    
    // Return default categories
    return [
      const QuizCategory(
        id: 'flutter',
        name: 'Flutter Development',
        description: 'Test your Flutter and Dart knowledge',
        iconUrl: '📱',
        questionCount: 25,
      ),
      const QuizCategory(
        id: 'science',
        name: 'Science',
        description: 'Explore the wonders of science',
        iconUrl: '🔬',
        questionCount: 30,
      ),
      const QuizCategory(
        id: 'history',
        name: 'History',
        description: 'Journey through historical events',
        iconUrl: '📚',
        questionCount: 40,
      ),
      const QuizCategory(
        id: 'technology',
        name: 'Technology',
        description: 'Stay updated with tech trends',
        iconUrl: '💻',
        questionCount: 35,
      ),
    ];
  }

  // Helper methods
  static List<EnhancedQuizQuestion> _getFallbackQuestions({String? category}) {
    if (category == null) {
      return List.from(_fallbackQuestions)..shuffle();
    }
    
    // Filter questions by category
    final filteredQuestions = _fallbackQuestions
        .where((q) => q.category.toLowerCase().contains(category.toLowerCase()) ||
                     category.toLowerCase().contains(q.category.toLowerCase()))
        .toList();
    
    if (filteredQuestions.isEmpty) {
      // If no matching questions, return all fallback questions
      return List.from(_fallbackQuestions)..shuffle();
    }
    
    return List.from(filteredQuestions)..shuffle();
  }

  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
  }

  static String _cleanJeopardyQuestion(String question) {
    return question.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  static String _cleanJeopardyAnswer(String answer) {
    return answer
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .trim();
  }

  static String _mapJeopardyDifficulty(dynamic value) {
    if (value == null) return 'medium';
    final intValue = value is int ? value : int.tryParse(value.toString()) ?? 400;
    
    if (intValue <= 400) return 'easy';
    if (intValue <= 800) return 'medium';
    return 'hard';
  }

  static List<String> _generateWrongAnswers(String correctAnswer, String category) {
    // This is a simplified approach - in a real app, you might use AI or a more sophisticated method
    final List<String> wrongAnswers = [];
    
    // Add some generic wrong answers based on the correct answer type
    if (RegExp(r'^\d{4}$').hasMatch(correctAnswer)) {
      // Year
      final year = int.parse(correctAnswer);
      wrongAnswers.addAll([
        (year - 1).toString(),
        (year + 1).toString(),
        (year - 2).toString(),
      ]);
    } else if (correctAnswer.length <= 3) {
      // Short answers (possibly abbreviations)
      wrongAnswers.addAll(['ABC', 'XYZ', 'DEF']);
    } else {
      // Longer answers
      wrongAnswers.addAll([
        'Alternative Answer A',
        'Alternative Answer B',
        'Alternative Answer C',
      ]);
    }
    
    return wrongAnswers.take(3).toList();
  }

  static String _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('science')) return '🔬';
    if (name.contains('history')) return '📚';
    if (name.contains('sports')) return '⚽';
    if (name.contains('entertainment')) return '🎬';
    if (name.contains('geography')) return '🌍';
    if (name.contains('art')) return '🎨';
    if (name.contains('music')) return '🎵';
    if (name.contains('literature')) return '📖';
    if (name.contains('math')) return '🔢';
    if (name.contains('computer')) return '💻';
    return '🧠'; // Default brain icon
  }
}
