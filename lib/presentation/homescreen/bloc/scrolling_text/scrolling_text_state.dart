part of 'scrolling_text_bloc.dart';

sealed class ScrollingTextState extends Equatable {
  const ScrollingTextState();

  @override
  List<Object> get props => [];
}

final class EmptyScrollingText extends ScrollingTextState {}

final class LoadingScrollingText extends ScrollingTextState {}

final class LoadedScrollingText extends ScrollingTextState {
  final ScrollText scrollText;

  const LoadedScrollingText(this.scrollText);

  @override
  List<Object> get props => [scrollText];

  LoadedScrollingText copyWith({
    ScrollText? scrollText,
    int? index,
  }) {
    return LoadedScrollingText(
      scrollText ?? this.scrollText,
    );
  }
}

final class ErrorScrollingText extends ScrollingTextState {
  final String message;

  const ErrorScrollingText(this.message);

  @override
  List<Object> get props => [message];
}
