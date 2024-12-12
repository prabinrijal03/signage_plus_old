import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/model/scroll_text.dart';
import '../../../../data/usecases/fetch_scrolling_texts.dart';
import '../../../../services/hive_services.dart';
import '../../../../services/playlist_services.dart';
import '../../../../services/socket_services.dart';
import '../../../../services/utils.dart';

part 'scrolling_text_event.dart';
part 'scrolling_text_state.dart';

class ScrollingTextBloc extends Bloc<ScrollingTextEvent, ScrollingTextState> {
  final FetchScrollingTexts fetchScrollingTexts;

  ScrollingTextBloc({required this.fetchScrollingTexts}) : super(LoadingScrollingText()) {
    // Initial: Fetching scrolling texts from server
    on<Initial>((event, emit) async {
      // Fetch scrolling texts from server
      final result = await fetchScrollingTexts(const Params());
      result.fold((l) => emit(ErrorScrollingText(l.message)), (r) {
        // If no scrolling text received from server, emit empty scrolling text
        if (r.scrollTexts.isEmpty) return emit(EmptyScrollingText());
        // Add active scrolling texts to queue
        // Active scroll texts are scroll texts that are either date range only or are currently active
        final activeScrollTexts = r.scrollTexts.where((element) => Utils.isScrollTextActive(element)).toList();
        PlaylistService.addScrollText(activeScrollTexts);
        // Emit first scrolling text
        final scrollText = PlaylistService.popScrollText();
        if (scrollText == null) {
          // If queue is empty, emit empty scrolling text
          emit(EmptyScrollingText());
        } else {
          // If queue is not empty, emit first scrolling text
          emit(LoadedScrollingText(scrollText));
        }
      });
    });

    // ChangeScrollingText: Change scrolling text
    on<ChangeScrollingText>((event, emit) async {
      if (state is LoadedScrollingText || state is EmptyScrollingText) {
        // get next scrolling text from queue
        final nextScrollText = PlaylistService.popScrollText();
        // If playable scrolling text is found, emit it
        if (nextScrollText != null) return emit(LoadedScrollingText(nextScrollText));
        // If scrolling text queue is empty, fetch new scrolling texts from database
        final scrollTexts = HiveService().getActiveScrollingText();
        // If no scrolling text in database, emit empty scrolling text
        if (scrollTexts == null) return emit(EmptyScrollingText());
        // Filter active scrolling texts
        // Active scroll texts are scroll texts that are either date range only or are currently active
        final activeScrollTexts = scrollTexts.scrollTexts.where((element) => Utils.isScrollTextActive(element));
        // If no active scrolling text in database, emit empty scrolling text
        if (activeScrollTexts.isEmpty) return emit(EmptyScrollingText());
        // Add scrolling texts to queue
        PlaylistService.addScrollText(scrollTexts.scrollTexts);
        // Emit scrolling text
        emit(LoadedScrollingText(PlaylistService.popScrollText()!));
      }
    });

    // AppendScrollingText: On new scrolling text received from socket
    on<AppendScrollingText>((event, emit) {
      HiveService().appendScrollingTextToBox(event.scrollTexts.scrollTexts);
      if (state is EmptyScrollingText) {
        // If scrolling text queue is empty, emit first scrolling text
        add(const ChangeScrollingText());
      }
    });

    // AppendScrollingText: On new scrolling text received from socket
    on<DeleteScrollingText>((event, emit) {
      // If current scrolling text is not the deleted scrolling text, remove it from queue
      if (state is LoadedScrollingText && (state as LoadedScrollingText).scrollText.id != event.id) {
        PlaylistService.removeScrollText(event.id);
      } else {
        // If current scrolling text is the deleted scrolling text, emit next scrolling text
        add(const ChangeScrollingText());
      }
      // Delete scrolling text from database
      HiveService().deleteScrollingTextFromBox(event.id);
    });

    on<UpdateScrollingText>((event, emit) {
      event.scrollTexts.scrollTexts.forEach(updateScrollText);
      if (state is EmptyScrollingText) {
        // If content queue is empty, emit first content
        add(const ChangeScrollingText());
      }
    });
  }

  void updateScrollText(ScrollText scrollText) {
    // Update content in database
    HiveService().updateScrollingTextFromBox(scrollText);
    // if content currently displayed is the updated content, return
    if (state is LoadedScrollingText && (state as LoadedScrollingText).scrollText.id == scrollText.id) {
      return;
    }
    // If current content is not the updated content, update it in queue
    PlaylistService.updateScrollText(scrollText);
  }

  // Init: Listen to socket stream and emit initial event
  void init() {
    /// Listen to socket stream and emit AppendScrollingText event
    /// when new scrolling text received from socket
    SocketService().scrollTextStream.listen((event) {
      event.fold(
        (scrollTexts) => add(AppendScrollingText(scrollTexts: scrollTexts)),
        (scrollTextsId) => add(DeleteScrollingText(id: scrollTextsId)),
      );
    });

    SocketService().updateScrollTextStream.listen((scrollTexts) => add(UpdateScrollingText(scrollTexts: scrollTexts)));

    add(Initial());
  }
}
