part of 'wards_news_bloc.dart';

sealed class WardsNewsState extends Equatable {
  const WardsNewsState();

  @override
  List<Object> get props => [];
}

final class WardsNewsLoading extends WardsNewsState {}

final class WardsNewsLoaded extends WardsNewsState {
  final List<WardNews> wardNews;

  const WardsNewsLoaded(this.wardNews);

  @override
  List<Object> get props => [wardNews];
}

final class WardsNewsError extends WardsNewsState {
  final String message;

  const WardsNewsError(this.message);

  @override
  List<Object> get props => [message];
}
