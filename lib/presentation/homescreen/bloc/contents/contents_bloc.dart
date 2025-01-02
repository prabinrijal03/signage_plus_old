import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slashplus/data/datasource/remote_datasource.dart';

import '../../../../data/model/contents.dart';
import '../../../../data/usecases/download_video.dart' as d;
import '../../../../data/usecases/fetch_contents.dart';
import '../../../../services/hive_services.dart';
import '../../../../services/playlist_services.dart';
import '../../../../services/socket_services.dart';
import '../../../../services/utils.dart';
import '../token/token_bloc.dart';

part 'contents_event.dart';
part 'contents_state.dart';

class ContentsBloc extends Bloc<ContentsEvent, ContentsState> {
  final d.Donwload download;
  final FetchContents fetchContents;
  final TokenBloc tokenBloc;
  Timer? contentTimer;
  bool isCancelled = false;
  final RemoteDatasource remoteDatasource;

  ContentsBloc(
      {required this.fetchContents,
      required this.download,
      required this.tokenBloc,
      required this.remoteDatasource})
      : super(ContentsInitial()) {
    void startDelayedAction(int displayTime) {
      contentTimer = Timer(Duration(seconds: displayTime), () {
        add(const ChangeContent());
      });
    }

    Future<void> fetchContentBeforeEnd(String orgId, String contentId) async {
      try {
        await remoteDatasource.contentsForcePlay(orgId, contentId);
        print(
            'fetchContentBeforeEnd called with orgId: $orgId, contentId: $contentId');
      } catch (e) {
        print('Error occurred while fetching content before end: $e');
      }
    }

    on<Initial>((event, emit) async {
      Timer.periodic(const Duration(seconds: 1), (timer) {});
      // Fetch contents from server
      final result = await fetchContents(const Params());
      await result.fold((l) async => emit(ErrorContents(l.message)), (r) async {
        // If no content received from server, emit empty content
        if (r.contents.isEmpty) return emit(EmptyContents());
        // Download all contents
        await Utils.downloadContents(download, fetchContents);
        // Add active contents to queue
        // Active contents are contents that are either date range only or are currently active
        final activeContents = r.contents
            .where((element) => Utils.isContentActive(element))
            .toList();
        PlaylistService.addContent(activeContents);
        // Emit first content
        final content = PlaylistService.popContent();
        if (content == null) {
          // If queue is empty, emit empty content
          emit(EmptyContents());
        } else {
          // If the queue is not empty
          // If the content has no video, start a timer to change content after display time
          if (!content.layout.hasVideo!) {
            startDelayedAction(content.displayTime);
          }
          final displayTime = content.displayTime;
          add(
            ForcePlayNotify(
              playTime: Duration(seconds: displayTime),
              contentId: content.id,
            ),
          );

          // emit first content
          return emit(LoadedContents(content));
        }
      });
    });
    on<ForcePlayNotify>((event, emit) async {
      final forcePlayNotifyDuration =
          Duration(seconds: event.playTime.inSeconds - 2);
      final forcePlayEnabled = HiveService().getForcePlayStatus();
      if (forcePlayEnabled) {
        Timer(forcePlayNotifyDuration, () {
          final orgId = HiveService().getOrganizationId();
          if (orgId == null) return;
          final contentId = event.contentId;
          fetchContentBeforeEnd(orgId, contentId);
          print(
              'fetchContentBeforeEnd called with orgId: $orgId, contentId: $contentId');
        });
      }
    });
    on<ChangeContent>((event, emit) async {
      videoCompletion.updateAll((key, value) => value = false);
      contentTimer?.cancel();
      if (state is LoadedContents || state is EmptyContents) {
        // get next content from queue
        final nextContent = PlaylistService.popContent();
        // If playable content is found, emit content
        if (nextContent != null) {
          // If the content has no video, start a timer to change content after display time
          if (!nextContent.layout.hasVideo!) {
            startDelayedAction(nextContent.displayTime);
            add(ForcePlayNotify(
                playTime: Duration(seconds: nextContent.displayTime),
                contentId: nextContent.id));
          }
          return emit(LoadedContents(nextContent));
        }

        // If content queue is empty, fetch new contents from database
        final contents = HiveService().getActiveContents();
        // If no content in database, emit empty content
        if (contents == null) return emit(EmptyContents());
        // Active contents are contents that are either date range only or currently active
        final activeContents = contents.contents
            .where((element) => Utils.isContentActive(element))
            .toList();
        // If no active content in database, emit empty content
        if (activeContents.isEmpty) return emit(EmptyContents());
        // Add contents to queue
        PlaylistService.addContent(activeContents);
        // Get first content from queue
        final content = PlaylistService.popContent()!;
        // If the content has no video, start a timer to change content after display time
        if (!content.layout.hasVideo!) {
          startDelayedAction(content.displayTime);
          add(ForcePlayNotify(
              playTime: Duration(seconds: content.displayTime),
              contentId: content.id));
        }
        // Emit content
        return emit(LoadedContents(content));
      }
    });

    on<AppendContent>((event, emit) async {
      // Download the contents
      await Utils.downloadContents(download, fetchContents);
      // Add contents to box
      HiveService().appendContentsToBox(event.content);
      if (state is EmptyContents) {
        // If content queue is empty, emit first content
        add(const ChangeContent());
      }
    });

    on<UpdateContent>((event, emit) {
      // Update content in database
      HiveService().updateContentInBox(event.content);
      // if content currently displayed is the updated content, update it
      if (state is LoadedContents &&
          (state as LoadedContents).content.id == event.content.id) {
        return;
      }
      // If current content is not the updated content, update it in queue
      PlaylistService.updateContent(event.content);
      if (state is EmptyContents) {
        // If content queue is empty, emit first content
        add(const ChangeContent());
      }
    });

    on<DeleteContent>((event, emit) {
      // If current content is not the deleted content, remove it from queue
      if (state is LoadedContents &&
          (state as LoadedContents).content.id != event.id) {
        PlaylistService.removeContent(event.id);
      } else {
        // If current content is the deleted content, emit next scrolling text
        add(const ChangeContent());
      }
      // Delete content from database
      HiveService().deleteContentFromBox(event.id);
    });

    on<ForcePlay>((event, emit) async {
       print('ForcePlay event triggered with contentId: ${event.contentId}');
      if (state is LoadedContents || state is EmptyContents) {
        final content = HiveService()
            .getAllContents()!
            .contents
            .firstWhereOrNull((element) => element.id == event.contentId);
        if (content == null) return;
        if (!content.layout.hasVideo!) {
          startDelayedAction(content.displayTime);
          add(ForcePlayNotify(
              playTime: Duration(seconds: content.displayTime),
              contentId: content.id));
        }
        // Emit content
        return emit(LoadedContents(content));
      }
    });
  }

  String progressInfo = '';
  Map<String, bool> videoCompletion = {};
  bool isContentChanging = false;

  void cancelTimer() {
    contentTimer?.cancel();
  }

  void init() {
    // Listen to socket events for any content changes
    SocketService().contentStream.listen((event) {
      event.fold(
        (content) => add(AppendContent(content: content)),
        (contentId) => add(DeleteContent(id: contentId)),
      );
    });
    SocketService().updateContentStream.listen((event) {
      add(UpdateContent(content: event));
    });

    SocketService().forcePlay.listen((event) {
      contentTimer?.cancel();
      add(ForcePlay(contentId: event));
    });
    // Initial event
    add(Initial());
  }
}
