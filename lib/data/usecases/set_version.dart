import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../repositories/repository.dart';

class SetVersion implements UseCase<String, Params> {
  final Repository _repository;

  SetVersion(this._repository);

  @override
  Future<Either<Failure, String>> call(Params params) async {
    return await _repository.setVersion(params.deviceId, params.versionId);
  }
}

class Params extends Equatable {
  final String deviceId;
  final String versionId;

  const Params({required this.deviceId, required this.versionId});

  @override
  List<Object> get props => [deviceId, versionId];
}
