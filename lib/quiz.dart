import 'package:flutter/material.dart';
import 'package:quiz_app/models/enhanced_quiz_question.dart';
import 'package:quiz_app/screens/category_selection_screen.dart';
import 'package:quiz_app/screens/enhanced_question_screen.dart';
import 'package:quiz_app/screens/enhanced_result_screen.dart';
import 'package:quiz_app/screens/start_screen.dart';
import 'package:quiz_app/screens/user_profile_screen.dart';
import 'package:quiz_app/services/quiz_data_service.dart';
import 'package:quiz_app/services/user_progress_service.dart';


class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List<String> selectedAnswers = [];
  List<EnhancedQuizQuestion> currentQuestions = [];
  String activeScreen = 'start-screen';
  String? selectedCategory;
  String selectedDifficulty = 'medium';
  bool isLoading = false;
  UserProgress? userProgress;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  void _loadUserProgress() async {
    final progress = await UserProgressService.loadUserProgress();
    setState(() {
      userProgress = progress;
    });
  }

  void switchToCategories() {
    setState(() {
      activeScreen = 'category-selection';
    });
  }

  void switchToProfile() {
    setState(() {
      activeScreen = 'user-profile';
    });
  }

  void startQuiz({String? category, String difficulty = 'medium'}) async {
    setState(() {
      isLoading = true;
      selectedCategory = category;
      selectedDifficulty = difficulty;
    });

    try {
      List<EnhancedQuizQuestion> questions;
      
      if (category != null) {
        // Fetch questions for specific category
        questions = await QuizDataService.fetchQuestionsByCategory(
          category: category,
          count: 10,
        );
      } else {
        // Fetch mixed questions from multiple sources
        questions = await QuizDataService.fetchMixedQuestions(totalCount: 10);
      }

      setState(() {
        currentQuestions = questions;
        selectedAnswers = [];
        activeScreen = 'questions-screen';
        isLoading = false;
      });
    } catch (e) {
      print('Error starting quiz: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void chooseAnswer(String answer) {
    selectedAnswers.add(answer);
    if (selectedAnswers.length == currentQuestions.length) {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Update user progress
      final quizId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';
      final updatedProgress = await UserProgressService.updateProgressAfterQuiz(
        questions: currentQuestions,
        userAnswers: selectedAnswers,
        quizId: quizId,
      );

      setState(() {
        userProgress = updatedProgress;
        activeScreen = 'result-screen';
        isLoading = false;
      });
    } catch (e) {
      print('Error finishing quiz: $e');
      setState(() {
        isLoading = false;
        activeScreen = 'result-screen';
      });
    }
  }

  void restartQuiz() {
    setState(() {
      selectedAnswers = [];
      activeScreen = 'questions-screen';
    });
  }

  void goToHome() {
    setState(() {
      selectedAnswers = [];
      currentQuestions = [];
      activeScreen = 'start-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget;

    if (isLoading) {
      screenWidget = const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      switch (activeScreen) {
        case 'start-screen':
          screenWidget = StartScreen(
            onStartQuiz: () => startQuiz(),
            onSelectCategory: switchToCategories,
            onViewProfile: switchToProfile,
            userProgress: userProgress,
          );
          break;
        case 'category-selection':
          screenWidget = CategorySelectionScreen(
            onCategorySelected: (category) => startQuiz(category: category),
            onBack: goToHome,
          );
          break;
        case 'questions-screen':
          screenWidget = EnhancedQuestionScreen(
            questions: currentQuestions,
            onSelectAnswer: chooseAnswer,
            selectedAnswers: selectedAnswers,
          );
          break;
        case 'result-screen':
          screenWidget = EnhancedResultScreen(
            questions: currentQuestions,
            userAnswers: selectedAnswers,
            userProgress: userProgress!,
            onRestart: restartQuiz,
            onHome: goToHome,
            onNewQuiz: () => startQuiz(),
          );
          break;
        case 'user-profile':
          screenWidget = UserProfileScreen(
            userProgress: userProgress!,
            onBack: goToHome,
          );
          break;
        default:
          screenWidget = StartScreen(
            onStartQuiz: () => startQuiz(),
            onSelectCategory: switchToCategories,
            onViewProfile: switchToProfile,
            userProgress: userProgress,
          );
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'GoogleFonts.poppins',
      ),
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
          child: screenWidget,
        ),
      ),
    );
  }
}
