part of 'feedback_cubit.dart';

sealed class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object> get props => [];
}

final class FeedbackLoading extends FeedbackState {}

final class FeedbackLoaded extends FeedbackState {
  final FeedbackQuestions feedbackQuestions;
  final bool showFrontSide;
  final int? selectedFeedbackIndex;

  const FeedbackLoaded({required this.selectedFeedbackIndex, required this.showFrontSide, required this.feedbackQuestions});

  @override
  List<Object> get props => [showFrontSide, selectedFeedbackIndex ?? -1, feedbackQuestions];
}

final class FeedbackSubmitting extends FeedbackState {
  final FeedbackQuestions feedbackQuestions;
  final bool showFrontSide;

  const FeedbackSubmitting({required this.feedbackQuestions, required this.showFrontSide});

  @override
  List<Object> get props => [feedbackQuestions, showFrontSide];
}

final class FeedbackSubmitted extends FeedbackState {
  final String tokenNumber;
  final FeedbackQuestions feedbackQuestions;
  final bool showFrontSide;

  const FeedbackSubmitted({required this.tokenNumber, required this.feedbackQuestions, required this.showFrontSide});

  @override
  List<Object> get props => [tokenNumber, feedbackQuestions, showFrontSide];
}
