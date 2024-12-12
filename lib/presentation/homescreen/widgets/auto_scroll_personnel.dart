import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import '../../../data/model/ward_details.dart';

import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';
import 'page_indicator.dart';

class AutoScrollPersonnel extends StatefulWidget {
  final int displaySeconds;
  final List<WardPersonnel> wardPersonnel;
  final int flex;
  const AutoScrollPersonnel({super.key, required this.flex, required this.wardPersonnel, required this.displaySeconds});

  @override
  State<AutoScrollPersonnel> createState() => _AutoScrollPersonnelState();
}

class _AutoScrollPersonnelState extends State<AutoScrollPersonnel> {
  final PreloadPageController _pageController = PreloadPageController();
  late Timer timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    startAutoScroll();
  }

  void startAutoScroll() {
    timer = Timer.periodic(Duration(seconds: widget.displaySeconds), (timer) {
      if (_currentPage < widget.wardPersonnel.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Stack(
        children: [
          PreloadPageView.builder(
            controller: _pageController,
            itemCount: widget.wardPersonnel.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      height: AppConstants.deviceHeight * 0.05,
                      color: ColorManager.darkBlue,
                      width: AppConstants.deviceWidth,
                      child: Text(widget.wardPersonnel[index].position, style: const TextStyle(fontSize: 16, color: Colors.white))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    width: AppConstants.deviceWidth,
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: ColorManager.darkBlue)),
                      child: CachedNetworkImage(
                          imageUrl: widget.wardPersonnel[index].image,
                          fit: BoxFit.cover,
                          height: AppConstants.deviceHeight * 0.12,
                          width: MediaQuery.of(context).size.width),
                    ),
                  ),
                  SizedBox(height: AppConstants.deviceHeight * 0.005),
                  Text(widget.wardPersonnel[index].name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0044A9))),
                  SizedBox(height: AppConstants.deviceHeight * 0.01),
                  Text(widget.wardPersonnel[index].phone, style: const TextStyle(fontSize: 16, color: Color(0xFF0044A9))),
                  SizedBox(height: AppConstants.deviceHeight * 0.01),
                ],
              );
            },
          ),
          Positioned(left: 0, right: 0, bottom: 10, child: PageIndicator(currentPage: _currentPage, itemCount: widget.wardPersonnel.length)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    timer.cancel();
    super.dispose();
  }
}
