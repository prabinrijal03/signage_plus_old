import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import '../model/device_layout.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../repositories/repository.dart';

class FetchDeviceLayout implements UseCase<DeviceLayoutInfo?, Params> {
  final Repository _repository;

  FetchDeviceLayout(this._repository);

  @override
  Future<Either<Failure, DeviceLayoutInfo?>> call(Params params) async {
    return await _repository.getDeviceLayout(params.deviceId);
  }
}

class Params extends Equatable {
  final String deviceId;
  const Params({
    required this.deviceId,
  });

  @override
  List<Object> get props => [deviceId];
}
