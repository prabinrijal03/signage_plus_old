part of 'contents_bloc.dart';

sealed class ContentsEvent extends Equatable {
  const ContentsEvent();

  @override
  List<Object> get props => [];
}

class Initial extends ContentsEvent {}

class ChangeContent extends ContentsEvent {
  const ChangeContent();
}

class AppendContent extends ContentsEvent {
  final Content content;

  const AppendContent({required this.content});
}

class UpdateContent extends ContentsEvent {
  final Content content;

  const UpdateContent({required this.content});
}

class DeleteContent extends ContentsEvent {
  final String id;

  const DeleteContent({required this.id});
}

class ForcePlay extends ContentsEvent {
  final String contentId;

  const ForcePlay({required this.contentId});
}

class ForcePlayNotify extends ContentsEvent {
  final Duration playTime;
  final String contentId;

  const ForcePlayNotify({required this.playTime, required this.contentId});
}
