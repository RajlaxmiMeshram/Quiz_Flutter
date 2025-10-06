import 'package:json_annotation/json_annotation.dart';

part 'enhanced_quiz_question.g.dart';

@JsonSerializable()
class EnhancedQuizQuestion {
  final String id;
  final String text;
  final List<String> answers;
  final String correctAnswer;
  final String category;
  final String difficulty;
  final String? explanation;
  final List<String>? tags;

  const EnhancedQuizQuestion({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctAnswer,
    required this.category,
    required this.difficulty,
    this.explanation,
    this.tags,
  });

  factory EnhancedQuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$EnhancedQuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$EnhancedQuizQuestionToJson(this);

  List<String> getShuffledAnswers() {
    final shuffledList = List<String>.from(answers);
    shuffledList.shuffle();
    return shuffledList;
  }

  bool isCorrect(String selectedAnswer) {
    return selectedAnswer == correctAnswer;
  }

  // Convert from legacy QuizQuestion format
  factory EnhancedQuizQuestion.fromLegacy({
    required String text,
    required List<String> answers,
    String category = 'Flutter',
    String difficulty = 'medium',
  }) {
    return EnhancedQuizQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      answers: answers,
      correctAnswer: answers.first, // Assuming first answer is correct in legacy format
      category: category,
      difficulty: difficulty,
    );
  }
}

@JsonSerializable()
class QuizCategory {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int questionCount;

  const QuizCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.questionCount,
  });

  factory QuizCategory.fromJson(Map<String, dynamic> json) =>
      _$QuizCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$QuizCategoryToJson(this);
}

@JsonSerializable()
class UserProgress {
  final String userId;
  final Map<String, int> categoryScores;
  final Map<String, int> categoryAttempts;
  final List<String> completedQuizzes;
  final int totalScore;
  final int perfectScores;
  final DateTime lastPlayed;

  const UserProgress({
    required this.userId,
    required this.categoryScores,
    required this.categoryAttempts,
    required this.completedQuizzes,
    required this.totalScore,
    required this.perfectScores,
    required this.lastPlayed,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressToJson(this);

  factory UserProgress.initial(String userId) {
    return UserProgress(
      userId: userId,
      categoryScores: {},
      categoryAttempts: {},
      completedQuizzes: [],
      totalScore: 0,
      perfectScores: 0,
      lastPlayed: DateTime.now(),
    );
  }
}
