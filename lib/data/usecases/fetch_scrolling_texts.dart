import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../model/scroll_text.dart';
import '../repositories/repository.dart';

class FetchScrollingTexts implements UseCase<ScrollTexts, Params> {
  final Repository _repository;

  FetchScrollingTexts(this._repository);

  @override
  Future<Either<Failure, ScrollTexts>> call(Params params) async {
    return await _repository.getScrollTexts();
  }
}

class Params extends Equatable {
  const Params();

  @override
  List<Object> get props => [];
}
