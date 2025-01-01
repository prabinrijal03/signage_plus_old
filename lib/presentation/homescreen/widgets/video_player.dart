import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../services/hive_services.dart';
import '../bloc/contents/contents_bloc.dart';

class VideoWidget extends StatefulWidget {
  final ContentsBloc contentsBloc;
  final String video;
  final int volume;

  const VideoWidget(this.contentsBloc, this.video,
      {super.key, required this.volume});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(
        File("${HiveService.dir.path}/video/${widget.video.split("/").last}"),
        videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true, allowBackgroundPlayback: true));

    _controller.initialize().then((_) => setState(() {
          _controller.setVolume(widget.volume.toDouble() / 100);
          _controller.play();
          isReady = true;
          
        }));

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        widget.contentsBloc.videoCompletion[widget.key.toString()] = true;
        if (widget.contentsBloc.videoCompletion.values
                .every((element) => element == true) &&
            !widget.contentsBloc.isContentChanging) {
          widget.contentsBloc.isContentChanging = true;

          widget.contentsBloc.add(const ChangeContent());
          widget.contentsBloc.cancelTimer();

          _controller.removeListener(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.contentsBloc.videoCompletion.clear();
    widget.contentsBloc.isContentChanging = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isReady
        ? LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.fill,
                child: Container(
                  alignment: Alignment.center,
                  constraints: constraints,
                  child: VideoPlayer(_controller),
                ),
              );
            },
          )
        : SizedBox(
            height: double.maxFinite,
            width: double.maxFinite,
            child: Image.file(
              File(
                  "${HiveService.dir.path}/video/${widget.video.split("/").last}.png"),
              fit: BoxFit.fill,
            ),
          );
  }
}
