import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../model/feedback_questions.dart';
import '../repositories/repository.dart';

class FetchFeedbackQuestions implements UseCase<FeedbackQuestions, Params> {
  final Repository _repository;

  FetchFeedbackQuestions(this._repository);

  @override
  Future<Either<Failure, FeedbackQuestions>> call(Params params) async {
    return await _repository.getFeedbackQuestions();
  }
}

class Params extends Equatable {
  const Params();

  @override
  List<Object> get props => [];
}
