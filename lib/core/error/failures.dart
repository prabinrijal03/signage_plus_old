import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure() : super(message: 'Server Failure');

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure() : super(message: 'Cache Failure');
  @override
  List<Object> get props => [message];
}

class InternetConnectionFailure extends Failure {
  const InternetConnectionFailure() : super(message: 'No Internet Connection');

  @override
  List<Object> get props => [message];
}

class SocketFailure extends Failure {
  const SocketFailure() : super(message: 'Socket Failure');

  @override
  List<Object> get props => [message];
}
