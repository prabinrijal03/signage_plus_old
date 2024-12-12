part of 'scrolling_text_bloc.dart';

sealed class ScrollingTextEvent extends Equatable {
  const ScrollingTextEvent();

  @override
  List<Object> get props => [];
}

class Initial extends ScrollingTextEvent {}

class ChangeScrollingText extends ScrollingTextEvent {
  const ChangeScrollingText();
}

class AppendScrollingText extends ScrollingTextEvent {
  final ScrollTexts scrollTexts;

  const AppendScrollingText({required this.scrollTexts});
}

class UpdateScrollingText extends ScrollingTextEvent {
  final ScrollTexts scrollTexts;

  const UpdateScrollingText({required this.scrollTexts});
}

class DeleteScrollingText extends ScrollingTextEvent {
  final String id;

  const DeleteScrollingText({required this.id});
}
