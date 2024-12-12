part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {
  final String? error;

  const LoginInitial({this.error});

  LoginInitial copyWith({String? error}) {
    return LoginInitial(error: error ?? this.error);
  }
}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final Device device;

  const LoginSuccess(this.device);

  @override
  List<Object> get props => [device];
}
