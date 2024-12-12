import 'package:either_dart/either.dart';
import 'package:slashplus/data/model/token.dart';
import 'package:slashplus/data/model/user_information.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../repositories/repository.dart';

class GenerateToken implements UseCase<Token, ApplicantInfoRequest> {
  final Repository _repository;

  GenerateToken(this._repository);

  @override
  Future<Either<Failure, Token>> call(ApplicantInfoRequest params) async {
    return await _repository.generateToken(params);
  }
}
