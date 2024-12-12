import 'package:either_dart/either.dart';
import 'package:slashplus/data/model/feedback_request.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../repositories/repository.dart';

class SubmitFeedbackAnswer implements UseCase<String, FeedbackRequest> {
  final Repository _repository;

  SubmitFeedbackAnswer(this._repository);

  @override
  Future<Either<Failure, String>> call(FeedbackRequest params) async {
    return await _repository.postFeedback(params.toJson());
  }
}
