part of 'wards_info_bloc.dart';

sealed class WardsInfoState extends Equatable {
  const WardsInfoState();

  @override
  List<Object> get props => [];
}

final class WardsInfoLoading extends WardsInfoState {}

final class WardsInfoLoaded extends WardsInfoState {
  final List<WardInfo> wardInfo;
  final List<WardContent> wardContent;

  const WardsInfoLoaded(this.wardInfo, this.wardContent);

  @override
  List<Object> get props => [wardInfo];
}

final class WardsInfoError extends WardsInfoState {
  final String message;

  const WardsInfoError(this.message);

  @override
  List<Object> get props => [message];
}
