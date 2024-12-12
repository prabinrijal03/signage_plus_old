import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import '../model/devices.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../repositories/repository.dart';

class LoginDevice implements UseCase<Device, Params> {
  final Repository _repository;

  LoginDevice(this._repository);

  @override
  Future<Either<Failure, Device>> call(Params params) async {
    return await _repository.login(params.loginCode);
  }
}

class Params extends Equatable {
  final String loginCode;

  const Params({required this.loginCode});

  @override
  List<Object> get props => [loginCode];
}
