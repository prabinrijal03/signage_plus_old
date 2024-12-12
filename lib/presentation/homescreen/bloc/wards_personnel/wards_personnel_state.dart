part of 'wards_personnel_bloc.dart';

sealed class WardsPersonnelState extends Equatable {
  const WardsPersonnelState();

  @override
  List<Object> get props => [];
}

final class WardsPersonnelLoading extends WardsPersonnelState {}

final class WardsPersonnelLoaded extends WardsPersonnelState {
  final List<WardPersonnel> wardPersonnel;

  const WardsPersonnelLoaded(this.wardPersonnel);

  @override
  List<Object> get props => [wardPersonnel];
}

final class WardsPersonnelError extends WardsPersonnelState {
  final String message;

  const WardsPersonnelError(this.message);

  @override
  List<Object> get props => [message];
}
