import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import '../model/ward_settings.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../model/ward_details.dart';
import '../repositories/repository.dart';

class FetchWardDetails implements UseCase<WardDetails, Params> {
  final Repository _repository;

  FetchWardDetails(this._repository);

  @override
  Future<Either<Failure, WardDetails>> call(Params param) async {
    return await _repository.getWardDetails();
  }

  Future<Either<Failure, WardSettings>> getSettings(Params param) async {
    return await _repository.getWardSettings();
  }
}

class Params extends Equatable {
  const Params();

  @override
  List<Object> get props => [];
}
