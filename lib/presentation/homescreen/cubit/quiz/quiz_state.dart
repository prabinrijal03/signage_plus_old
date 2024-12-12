part of 'quiz_cubit.dart';

sealed class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

final class QuizLoading extends QuizState {
  const QuizLoading();
}

final class QuizInitial extends QuizState {
  final List<Quiz> quiz;
  const QuizInitial({
    required this.quiz,
  });
}

final class QuizPlaying extends QuizState {
  final UniqueKey uniqueKey;
  final String name;
  final List<Quiz> quiz;
  const QuizPlaying({required this.uniqueKey, required this.name, required this.quiz});

  copyWith({
    UniqueKey? uniqueKey,
    String? name,
    List<Quiz>? quiz,
  }) {
    return QuizPlaying(
      uniqueKey: uniqueKey ?? this.uniqueKey,
      name: name ?? this.name,
      quiz: quiz ?? this.quiz,
    );
  }
}

final class QuizFinished extends QuizState {
  final String name;
  final int score;
  const QuizFinished({
    required this.name,
    required this.score,
  });
}

class Quiz {
  final String question;
  final List<String> answers;
  final String correctAnswer;

  const Quiz({
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'],
      answers: json['options'].cast<String>(),
      correctAnswer: json['correct_answer'],
    );
  }
}
