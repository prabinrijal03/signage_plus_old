import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../resources/constants.dart';

class AutoScrollHtmlWidget extends StatefulWidget {
  final String html;
  final int scrollSpeed;
  const AutoScrollHtmlWidget({
    super.key,
    required this.html,
    required this.scrollSpeed,
  });

  @override
  State<AutoScrollHtmlWidget> createState() => _AutoScrollHtmlWidgetState();
}

class _AutoScrollHtmlWidgetState extends State<AutoScrollHtmlWidget> {
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;
  late Timer _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollTimer = Timer.periodic(Duration(seconds: 60 * (1 / widget.scrollSpeed).round()), _scrollContent);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer.cancel();
    super.dispose();
  }

  void _scrollContent(Timer timer) {
    if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
      // Scroll to the start
      _scrollController.jumpTo(0.0);
      setState(() {
        _scrollPosition = 0.0;
      });
    } else {
      // Scroll to the end
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 60 * (1 / widget.scrollSpeed).round()),
        curve: Curves.easeInOut,
      );
      setState(() {
        _scrollPosition = _scrollController.position.maxScrollExtent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: AppConstants.deviceWidth,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: HtmlWidget(
              widget.html,
              enableCaching: true,
            ),
          ),
        ));
  }
}
