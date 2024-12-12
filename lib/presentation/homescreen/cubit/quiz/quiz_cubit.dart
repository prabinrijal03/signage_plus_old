import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(const QuizLoading()) {
    init();
  }

  List<Quiz> quiz = [];
  int score = 0;
  final PageController pageController = PageController();

  Future<void> init() async {
    final String jsonString = await rootBundle.loadString('assets/quiz.json');
    final List<dynamic> json = jsonDecode(jsonString);
    quiz = json.map((dynamic e) => Quiz.fromJson(e as Map<String, dynamic>)).toList();
    emit(QuizInitial(quiz: quiz));
  }

  final TextEditingController nameController = TextEditingController();

  void startQuiz() {
    final tQuiz = quiz;
    tQuiz.shuffle();
    emit(QuizPlaying(uniqueKey: UniqueKey(), name: nameController.text, quiz: tQuiz.sublist(0, 10)));
  }

  void finishQuiz(BuildContext context) {
    // Utils.printCongratulations(context, nameController.text, score);
    emit(QuizFinished(name: nameController.text, score: score));
  }

  void resetQuiz() {
    score = 0;
    nameController.clear();
    emit(QuizInitial(quiz: quiz));
  }

  void submitAnswer(Quiz quiz, String userChoice) {
    if (quiz.correctAnswer == userChoice) {
      score++;
    }
  }

  void changeQuestion(BuildContext context) {
    if (pageController.page!.toInt() < 9) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      finishQuiz(context);
    }
  }
}
