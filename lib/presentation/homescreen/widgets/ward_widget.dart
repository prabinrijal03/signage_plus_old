import 'dart:async';
import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/extensions.dart';
import 'ward_individual_card.dart';
import '../../../services/socket_services.dart';

import '../../../data/model/ward_details.dart';
import '../../../resources/constants.dart';
import '../../../services/hive_services.dart';
import '../cubit/layouts/layouts_cubit.dart';

class WardWidget extends StatefulWidget {
  final int flex;
  final List<WardInfo> wardInfo;
  final List<WardContent> wardContent;
  final int seconds;
  final int scrollSpeed;
  const WardWidget({
    super.key,
    required this.wardInfo,
    required this.wardContent,
    required this.seconds,
    required this.flex,
    required this.scrollSpeed,
  });

  @override
  State<WardWidget> createState() => _WardWidgetState();
}

class _WardWidgetState extends State<WardWidget> {
  int currentPage = 0;
  final itemsPerPage = 4;

  late Timer _timer;
  late int totalPages;
  late PageController _pageController;
  bool showMedia = false;
  bool isForcePlay = false;
  WardContent? forcePlayContent;

  @override
  void initState() {
    super.initState();
    totalPages = (widget.wardInfo.length / itemsPerPage).ceil();
    _pageController = PageController();
    _startTimer();

    SocketService().forcePlayWard.listen((event) {
      setState(() {
        isForcePlay = true;
        _timer.cancel();
      });

      int index =
          widget.wardContent.indexWhere((element) => element.id == event);
      forcePlayContent = widget.wardContent.elementAt(index);
    });
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    if (showMedia) return;
    _timer = Timer.periodic(Duration(seconds: widget.seconds), (timer) {
      if (currentPage == totalPages - 1 && widget.wardContent.isNotEmpty) {
        setState(() {
          showMedia = true;
          _timer.cancel();
        });
      } else {
        setState(() {
          currentPage = (currentPage + 1) % totalPages;
        });
      }
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  void goToMain() {
    setState(() {
      isForcePlay = false;
      showMedia = false;
      currentPage = (currentPage + 1) % totalPages;
      _startTimer();
    });
  }

  SizedBox _sizedBox() {
    return SizedBox(
        height: AppConstants.deviceHeight * 0.3,
        width: AppConstants.deviceWidth / 2);
  }

  void goToNextContent() {
    if (_pageController.page == widget.wardContent.length - 1) {
      setState(() {
        showMedia = false;
        currentPage = (currentPage + 1) % totalPages;
        _startTimer();
      });
    } else {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (currentPage + 1) * itemsPerPage;

    final currentWardInfos = widget.wardInfo.sublist(
      startIndex,
      endIndex.clamp(0, widget.wardInfo.length),
    );

    widget.wardContent.removeWhere((element) =>
        (widget.wardContent.first.playType == AppConstants.specificTimeRange &&
            (widget.wardContent.first.startTime.isBefore(AppConstants.now) ||
                widget.wardContent.first.endTime.isAfter(AppConstants.now))));
    widget.wardContent.shuffle();

    if (isForcePlay && forcePlayContent != null) {
      if (forcePlayContent!.type == "video") {
        return SizedBox(
          height: AppConstants.deviceHeight -
              context.read<LayoutsCubit>().padding.vertical,
          width: AppConstants.deviceWidth -
              context.read<LayoutsCubit>().padding.horizontal,
          child: SingleVideoPlayer(
            forcePlayContent!.source,
            onVideoEnd: () => goToMain(),
          ),
        );
      } else {
        Future.delayed(Duration(seconds: forcePlayContent!.displayTime ?? 10),
            () => goToMain());
        return SizedBox(
          height: AppConstants.deviceHeight -
              context.read<LayoutsCubit>().padding.vertical,
          width: AppConstants.deviceWidth -
              context.read<LayoutsCubit>().padding.horizontal,
          child: Image.file(
            File(
                "${HiveService.dir.path}/image/${forcePlayContent!.source.split("/").last}"),
            cacheHeight: 1080,
            cacheWidth: 1920,
            fit: BoxFit.fill,
          ),
        );
      }
    }

    if (showMedia && widget.wardContent.isNotEmpty) {
      return SizedBox(
          height: AppConstants.deviceHeight -
              context.read<LayoutsCubit>().padding.vertical,
          width: AppConstants.deviceWidth -
              context.read<LayoutsCubit>().padding.horizontal,
          child: PageView.builder(
              controller: _pageController,
              itemCount: widget.wardContent.length,
              itemBuilder: (context, index) {
                if (widget.wardContent.elementAt(index).type == "video") {
                  return WardVideoWidget(
                    widget.wardContent.elementAt(index).source,
                    onVideoEnd: () => goToNextContent(),
                  );
                } else {
                  Future.delayed(
                      Duration(
                          seconds:
                              widget.wardContent.elementAt(index).displayTime ??
                                  10),
                      () => goToNextContent());
                  return Image.file(
                    File(
                        "${HiveService.dir.path}/image/${widget.wardContent.elementAt(index).source.split("/").last}"),
                    cacheHeight: 1080,
                    cacheWidth: 1920,
                    fit: BoxFit.fill,
                  );
                }
              }));
    }
    return Column(
      children: [
        Row(
          children: [
            if (currentWardInfos.isNotEmpty)
              WardIndividualCard(
                  wardInfo: currentWardInfos[0],
                  flex: widget.flex,
                  scrollSpeed: widget.scrollSpeed)
            else
              _sizedBox(),
            if (currentWardInfos.length > 1)
              WardIndividualCard(
                  wardInfo: currentWardInfos[1],
                  flex: widget.flex,
                  scrollSpeed: widget.scrollSpeed)
            else
              _sizedBox(),
          ],
        ),
        Row(
          children: [
            if (currentWardInfos.length > 2)
              WardIndividualCard(
                  wardInfo: currentWardInfos[2],
                  flex: widget.flex,
                  scrollSpeed: widget.scrollSpeed)
            else
              _sizedBox(),
            if (currentWardInfos.length > 3)
              WardIndividualCard(
                  wardInfo: currentWardInfos[3],
                  flex: widget.flex,
                  scrollSpeed: widget.scrollSpeed)
            else
              _sizedBox(),
          ],
        ),
        if (widget.wardInfo.isNotEmpty) ...[
          Text(
            "Page ${currentPage + 1} of $totalPages",
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2)
        ]
      ],
    );
  }
}

class WardVideoWidget extends StatefulWidget {
  final String video;
  final void Function() onVideoEnd;

  const WardVideoWidget(this.video, {super.key, required this.onVideoEnd});

  @override
  State<WardVideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<WardVideoWidget> {
  late CachedVideoPlayerPlusController _controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    _controller = CachedVideoPlayerPlusController.file(
        File("${HiveService.dir.path}/video/${widget.video.split("/").last}"));

    _controller.initialize().then((_) => setState(() {
          _controller.play();
          isReady = true;
        }));

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        widget.onVideoEnd();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    child: CachedVideoPlayerPlus(_controller)),
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

class SingleVideoPlayer extends StatefulWidget {
  final String video;
  final void Function() onVideoEnd;

  const SingleVideoPlayer(this.video, {super.key, required this.onVideoEnd});

  @override
  State<SingleVideoPlayer> createState() => _SingleVideoPlayerState();
}

class _SingleVideoPlayerState extends State<SingleVideoPlayer> {
  late CachedVideoPlayerPlusController _controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    _controller = CachedVideoPlayerPlusController.file(
        File("${HiveService.dir.path}/video/${widget.video.split("/").last}"));

    _controller.initialize().then((_) => setState(() {
          _controller.play();
          isReady = true;
        }));

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        widget.onVideoEnd();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    child: CachedVideoPlayerPlus(_controller)),
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
