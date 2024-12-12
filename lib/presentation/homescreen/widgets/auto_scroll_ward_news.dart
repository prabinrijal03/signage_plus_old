import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/model/ward_details.dart';
import 'page_indicator.dart';

import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';

class AutoScrollPage extends StatefulWidget {
  final int displaySeconds;
  final List<WardNews> wardNews;
  final int flex;
  final int scrollSpeed;

  const AutoScrollPage({super.key, required this.flex, required this.wardNews, required this.displaySeconds, required this.scrollSpeed});

  @override
  State<AutoScrollPage> createState() => _AutoScrollPageState();
}

class _AutoScrollPageState extends State<AutoScrollPage> {
  final PageController _pageController = PageController();
  bool timerFinished = false;
  int _currentPage = 0;
  Timer? _scrollTimer;
  Timer? _pageTimer;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    startAutoScroll();

    _textAutoScroll();
  }

  void startAutoScroll() {
    _pageTimer = Timer.periodic(Duration(seconds: widget.displaySeconds), (timer) {
      if (_scrollController.position.maxScrollExtent == _scrollController.position.pixels) {
        scrollToNextPage();
      } else {
        timerFinished = true;
      }
    });
  }

  void scrollToNextPage() {
    _scrollController.removeListener(() {});
    if (widget.wardNews.length == 1) return;

    _scrollTimer?.cancel();
    _scrollController.dispose();
    _scrollController = ScrollController();

    if (_currentPage < widget.wardNews.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }

    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _textAutoScroll();
  }

  void _textAutoScroll() {
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.position.pixels) {
        if (timerFinished) {
          scrollToNextPage();
        }
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      _scrollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.pixels + widget.scrollSpeed,
            duration: const Duration(seconds: 1),
            curve: Curves.linear,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                color: Colors.green,
                height: AppConstants.deviceHeight * 0.05,
                width: AppConstants.deviceWidth,
                child: const Text(
                  "कार्यक्रम तथा सुचना",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 1,
                right: 0,
                left: 0,
                child: PageIndicator(
                  itemCount: widget.wardNews.length,
                  currentPage: _currentPage,
                  selectedColor: Colors.white,
                  unselectedColor: Colors.grey,
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: ColorManager.grey)),
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.wardNews.length,
                onPageChanged: (value) {
                  setState(() => _currentPage = value);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        Stack(children: [
                          Container(
                            decoration: BoxDecoration(border: Border.all(color: ColorManager.darkBlue)),
                            child: CachedNetworkImage(
                              imageUrl: widget.wardNews[index].image,
                              fit: BoxFit.fitWidth,
                              height: AppConstants.deviceHeight * 0.12,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            child: Text(
                              widget.wardNews[index].title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.darkRed,
                              ),
                            ),
                          ),
                        ]),
                        SizedBox(height: AppConstants.deviceHeight * 0.005),
                        SizedBox(
                          height: AppConstants.deviceHeight * 0.1,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Text(
                              widget.wardNews[index].description,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageTimer?.cancel();
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }
}
