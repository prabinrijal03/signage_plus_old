part of 'token_bloc.dart';

sealed class TokenEvent extends Equatable {
  const TokenEvent();

  @override
  List<Object> get props => [];
}

class LoadToken extends TokenEvent {
  final String type;
  const LoadToken({required this.type});
}

class DisconnectToken extends TokenEvent {
  const DisconnectToken();
}

class IncrementToken extends TokenEvent {
  const IncrementToken();
}

class ChangeToken extends TokenEvent {
  final Counter counter;
  const ChangeToken({required this.counter});
}

class DeleteCounter extends TokenEvent {
  final int id;
  const DeleteCounter({required this.id});
}

class PlayAudio extends TokenEvent {
  const PlayAudio();
}
