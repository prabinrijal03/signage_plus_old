import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../model/custom_user.dart';
import '../repositories/repository.dart';

class FetchCustomUser implements UseCase<List<CustomUser>, Params> {
  final Repository _repository;

  FetchCustomUser(this._repository);

  @override
  Future<Either<Failure, List<CustomUser>>> call(Params params) async {
    return await _repository.getCustomUser(params.deviceId);
  }
}

class Params extends Equatable {
  final String deviceId;

  const Params({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}
