part of 'wards_personnel_bloc.dart';

sealed class WardsPersonnelEvent extends Equatable {
  const WardsPersonnelEvent();

  @override
  List<Object> get props => [];
}

class InitializeWardPersonnel extends WardsPersonnelEvent {
  final List<WardPersonnel> wardPersonnel;

  const InitializeWardPersonnel(this.wardPersonnel);

  @override
  List<Object> get props => [wardPersonnel];
}

class AddWardPersonnel extends WardsPersonnelEvent {
  final WardPersonnel wardPersonnel;

  const AddWardPersonnel(this.wardPersonnel);

  @override
  List<Object> get props => [wardPersonnel];
}

class RemoveWardPersonnel extends WardsPersonnelEvent {
  final String id;

  const RemoveWardPersonnel(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateWardPersonnel extends WardsPersonnelEvent {
  final WardPersonnel wardPersonnel;

  const UpdateWardPersonnel(this.wardPersonnel);

  @override
  List<Object> get props => [wardPersonnel];
}
