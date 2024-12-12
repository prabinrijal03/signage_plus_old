part of 'wards_news_bloc.dart';

sealed class WardsNewsEvent extends Equatable {
  const WardsNewsEvent();

  @override
  List<Object> get props => [];
}

class InitializeWardNews extends WardsNewsEvent {
  final List<WardNews> wardNews;

  const InitializeWardNews(this.wardNews);

  @override
  List<Object> get props => [wardNews];
}

class AddWardNews extends WardsNewsEvent {
  final WardNews wardNews;

  const AddWardNews(this.wardNews);

  @override
  List<Object> get props => [wardNews];
}

class RemoveWardNews extends WardsNewsEvent {
  final String id;

  const RemoveWardNews(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateWardNews extends WardsNewsEvent {
  final WardNews wardNews;

  const UpdateWardNews(this.wardNews);

  @override
  List<Object> get props => [wardNews];
}
