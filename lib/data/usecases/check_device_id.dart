import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../repositories/repository.dart';

class CheckDeviceId implements UseCase<bool, Params> {
  final Repository _repository;

  CheckDeviceId(this._repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    return await _repository.checkDeviceId(params.deviceId);
  }
}

class Params extends Equatable {
  final String deviceId;

  const Params({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}
