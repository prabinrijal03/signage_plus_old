import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../repositories/repository.dart';

class Donwload implements UseCase<bool, Params> {
  final Repository _repository;

  Donwload(this._repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    return await _repository.download(params.url, params.path);
  }
}

class Params extends Equatable {
  final String url;
  final String path;
  const Params({required this.url, required this.path});

  @override
  List<Object> get props => [url, path];
}
