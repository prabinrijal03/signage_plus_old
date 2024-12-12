part of 'wards_info_bloc.dart';

sealed class WardsInfoEvent extends Equatable {
  const WardsInfoEvent();

  @override
  List<Object> get props => [];
}

class InitializeWardInfo extends WardsInfoEvent {
  final List<WardInfo> wardInfo;
  final List<WardContent> wardContent;

  const InitializeWardInfo(this.wardInfo, this.wardContent);

  @override
  List<Object> get props => [wardInfo];
}

class AddWardInfo extends WardsInfoEvent {
  final WardInfo wardInfo;

  const AddWardInfo(this.wardInfo);

  @override
  List<Object> get props => [wardInfo];
}

class RemoveWardInfo extends WardsInfoEvent {
  final String id;
  const RemoveWardInfo(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateWardInfo extends WardsInfoEvent {
  final WardInfo wardInfo;

  const UpdateWardInfo(this.wardInfo);

  @override
  List<Object> get props => [wardInfo];
}

class WardOrderChanged extends WardsInfoEvent {
  final Map<String, dynamic> wardOrder;

  const WardOrderChanged(this.wardOrder);

  @override
  List<Object> get props => [wardOrder];
}

class AddWardContent extends WardsInfoEvent {
  final WardContent wardContent;

  const AddWardContent(this.wardContent);

  @override
  List<Object> get props => [wardContent];
}

class UpdateWardContent extends WardsInfoEvent {
  final WardContent wardContent;

  const UpdateWardContent(this.wardContent);

  @override
  List<Object> get props => [wardContent];
}

class RemoveWardContent extends WardsInfoEvent {
  final String id;

  const RemoveWardContent(this.id);

  @override
  List<Object> get props => [id];
}

class ChangeWardContent extends WardsInfoEvent {
  const ChangeWardContent();

  @override
  List<Object> get props => [];
}
