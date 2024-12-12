import 'package:either_dart/either.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../repositories/repository.dart';

class GetServerDateTime implements UseCase<DateTime, void> {
  final Repository _repository;

  GetServerDateTime(this._repository);

  @override
  Future<Either<Failure, DateTime>> call(void param) async {
    return await _repository.getServerDateTime();
  }
}

void param;
