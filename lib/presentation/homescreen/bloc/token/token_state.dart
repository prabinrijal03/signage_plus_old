part of 'token_bloc.dart';

sealed class TokenState extends Equatable {
  const TokenState();

  @override
  List<Object> get props => [];
}

final class TokenInitial extends TokenState {}

final class TokenDisplayLoaded extends TokenState {
  final Counters counters;

  const TokenDisplayLoaded({required this.counters});

  @override
  List<Object> get props => [counters];
}

final class TokenButtonLoaded extends TokenState {
  final String deviceCode;
  const TokenButtonLoaded({required this.deviceCode});
}

final class TokenButtonEmptyDeviceCode extends TokenState {
  const TokenButtonEmptyDeviceCode();
}

final class TokenError extends TokenState {
  final String message;

  const TokenError(this.message);

  @override
  List<Object> get props => [message];
}

class AudioEvent extends TokenEvent {
  final List<int> tokenIntToPlay;
  final List<int> counterIntToPlay;
  final String nameToSpeak;

  const AudioEvent({required this.tokenIntToPlay, required this.counterIntToPlay, required this.nameToSpeak});

  @override
  List<Object> get props => [tokenIntToPlay, counterIntToPlay];
}
