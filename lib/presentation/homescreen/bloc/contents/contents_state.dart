part of 'contents_bloc.dart';

sealed class ContentsState extends Equatable {
  const ContentsState();

  @override
  List<Object> get props => [];
}

final class ContentsInitial extends ContentsState {}

final class EmptyContents extends ContentsState {}

final class LoadingContents extends ContentsState {}

final class LoadedContents extends ContentsState {
  final Content content;

  const LoadedContents(this.content);

  @override
  List<Object> get props => [content];

  LoadedContents copyWith({Content? content}) {
    return LoadedContents(content ?? this.content);
  }
}

final class ErrorContents extends ContentsState {
  final String message;

  const ErrorContents(this.message);

  @override
  List<Object> get props => [message];
}
