part of 'network_cubit.dart';

sealed class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object> get props => [];
}

final class NetworkUnknown extends NetworkState {}

final class NetworkConnected extends NetworkState {}

final class NetworkDisconnected extends NetworkState {}
