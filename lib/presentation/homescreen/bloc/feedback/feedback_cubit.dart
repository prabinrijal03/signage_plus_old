import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slashplus/data/usecases/fetch_feedback_questions.dart';
import 'package:slashplus/data/usecases/submit_feedback_answer.dart';

import '../../../../core/error/failures.dart';
import '../../../../data/model/devices.dart';
import '../../../../data/model/feedback_questions.dart';
import '../../../../data/model/feedback_request.dart';

part 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final FetchFeedbackQuestions fetchFeedbackQuestions;
  final SubmitFeedbackAnswer submitFeedbackAnswer;
  final Device device;
  FeedbackCubit({required this.fetchFeedbackQuestions, required this.submitFeedbackAnswer, required this.device}) : super(FeedbackLoading());

  final List<Answer> answers = [];

  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final phoneTextController = TextEditingController();
  final noteTextController = TextEditingController();

  void selectFeedbackIndex(int index) {
    final currentState = state;
    if (currentState is FeedbackLoaded) {
      addAnswer(currentState.feedbackQuestions.feedbackQuestions.first.id, index + 1);
      emit(
          FeedbackLoaded(feedbackQuestions: currentState.feedbackQuestions, selectedFeedbackIndex: index, showFrontSide: currentState.showFrontSide));
    }
  }

  int get selectedFeedbackIndex => state is FeedbackLoaded ? (state as FeedbackLoaded).selectedFeedbackIndex ?? -1 : -1;
  String get deviceName => device.name;

  Future<void> init() async {
    final result = await fetchFeedbackQuestions(const Params());
    final feedbackQuestions = result.fold((left) => FeedbackQuestions.empty(), (right) => right);

    emit(FeedbackLoaded(feedbackQuestions: feedbackQuestions, showFrontSide: true, selectedFeedbackIndex: null));
  }

  Future<Either<Failure, String>> submitFeedback(FeedbackRequest feedbackRequest) async {
    return await submitFeedbackAnswer(feedbackRequest);
  }

  void clear() {
    nameTextController.clear();
    emailTextController.clear();
    phoneTextController.clear();
    noteTextController.clear();
  }

  void reset(BuildContext context) {
    clear();
    answers.clear();
    final currentState = state;
    if (currentState is FeedbackLoaded) {
      // emit(FeedbackLoaded(feedbackQuestions: currentState.feedbackQuestions, showFrontSide: true));
      emit(FeedbackLoaded(feedbackQuestions: currentState.feedbackQuestions, selectedFeedbackIndex: null, showFrontSide: true));
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  void flipCard() {
    final currentState = state;
    if (currentState is FeedbackLoaded) {
      // emit(FeedbackLoaded(feedbackQuestions: currentState.feedbackQuestions, showFrontSide: !currentState.showFrontSide));
      emit(FeedbackLoaded(
          feedbackQuestions: currentState.feedbackQuestions,
          selectedFeedbackIndex: currentState.selectedFeedbackIndex,
          showFrontSide: !currentState.showFrontSide));
    }
  }

  void addAnswer(String questionId, int answer) {
    final index = answers.indexWhere((element) => element.questionId == questionId);
    if (index != -1) {
      answers[index] = answers[index].copyWith(answer: answer);
    } else {
      answers.add(Answer(questionId: questionId, answer: answer));
    }
  }

  // FeedbackQuestions get feedbackQuestions {
  //   if (state is! FeedbackLoaded) return FeedbackQuestions.empty();
  //   return (state as FeedbackLoaded).feedbackQuestions;
  // }

  bool get showFrontSide {
    if (state is! FeedbackLoaded) return true;
    return (state as FeedbackLoaded).showFrontSide;
  }
}
