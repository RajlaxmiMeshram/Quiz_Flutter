// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_quiz_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnhancedQuizQuestion _$EnhancedQuizQuestionFromJson(Map<String, dynamic> json) =>
    EnhancedQuizQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      answers: (json['answers'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      explanation: json['explanation'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$EnhancedQuizQuestionToJson(EnhancedQuizQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'answers': instance.answers,
      'correctAnswer': instance.correctAnswer,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'explanation': instance.explanation,
      'tags': instance.tags,
    };

QuizCategory _$QuizCategoryFromJson(Map<String, dynamic> json) => QuizCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      questionCount: json['questionCount'] as int,
    );

Map<String, dynamic> _$QuizCategoryToJson(QuizCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'questionCount': instance.questionCount,
    };

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) => UserProgress(
      userId: json['userId'] as String,
      categoryScores: Map<String, int>.from(json['categoryScores'] as Map),
      categoryAttempts: Map<String, int>.from(json['categoryAttempts'] as Map),
      completedQuizzes: (json['completedQuizzes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalScore: json['totalScore'] as int,
      perfectScores: json['perfectScores'] as int,
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
    );

Map<String, dynamic> _$UserProgressToJson(UserProgress instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'categoryScores': instance.categoryScores,
      'categoryAttempts': instance.categoryAttempts,
      'completedQuizzes': instance.completedQuizzes,
      'totalScore': instance.totalScore,
      'perfectScores': instance.perfectScores,
      'lastPlayed': instance.lastPlayed.toIso8601String(),
    };
