import 'dart:collection';

import 'package:flutter/src/material/time.dart';
import 'package:slashplus/services/hive_services.dart';

import 'utils.dart';

import '../data/model/ward_details.dart';

import '../resources/constants.dart';

import 'log_services.dart';

import '../core/extensions.dart';

import '../data/model/contents.dart';
import '../data/model/scroll_text.dart';

class PlaylistService {
  static final Queue<ScrollText> _scrollTexts = Queue<ScrollText>();

  static Queue<ScrollText> addScrollText(List<ScrollText> scrollTexts) {
    scrollTexts.shuffle();
    _scrollTexts.addAll(scrollTexts);
    return _scrollTexts;
  }

  static Queue<ScrollText> updateScrollText(ScrollText scrollText) {
    _scrollTexts.removeWhere((element) => element.id == scrollText.id);
    _scrollTexts.add(scrollText);
    return _scrollTexts;
  }

  static Queue<ScrollText> removeScrollText(String id) {
    _scrollTexts.removeWhere((element) => element.id == id);
    return _scrollTexts;
  }

  static ScrollText? popScrollText() {
    // If queue is empty, return null
    if (_scrollTexts.isEmpty) return null;
    // If queue is not empty, remove first scrolling text if it is not time to scroll
    while (!Utils.isScrollTextActive(_scrollTexts.first)) {
      _scrollTexts.removeFirst();
      // If queue has no scrolling text to be played at the current time, return null
      if (_scrollTexts.isEmpty) return null;
    }

    final scrollText = _scrollTexts.removeFirst();
    // If queue is not empty, return first scrolling text
    LogService.sendScrollTextLogSync(scrollText);
    return scrollText;
  }

  static Queue<ScrollText> get scrollTexts => _scrollTexts;

  // ---------- CONTENTS ----------

  static final Queue<Content> _contents = Queue<Content>();

  static Queue<Content> addContent(List<Content> contents) {
    contents.shuffle();
    _contents.addAll(contents);
    return _contents;
  }

  static Queue<Content> updateContent(Content content) {
    _contents.removeWhere((element) => element.id == content.id);
    _contents.add(content);
    return _contents;
  }

  static Queue<Content> removeContent(String id) {
    _contents.removeWhere((element) => element.id == id);
    return _contents;
  }

  static Content? popContent() {
    // If queue is empty, return null
    if (_contents.isEmpty) return null;
    // If queue is not empty, remove first scrolling text if it is not time to scroll
    while (!Utils.isContentActive(_contents.first)) {
      _contents.removeFirst();
      // If queue has no scrolling text to be played at the current time, return null
      if (_contents.isEmpty) return null;
    }

    // Check if there is any force play content
    if (hasAnyForcePlayContent) {
      // If there is any force play content, remove all non-force play content
      while (_contents.first.forcePlay == false) {
        _contents.removeFirst();
        if (_contents.isEmpty) return null;
      }
    }
    // If queue is not empty, return first scrolling text
    final content = _contents.removeFirst();
    LogService.sendPlayLogSync(content);
    return content;
  }

  static Content? addToTop(Content content) {
    _contents.addFirst(content);
    return content;
  }

  static Queue<Content> get contents => _contents;
  static bool get hasAnyForcePlayContent =>
      HiveService()
          .getActiveContents()
          ?.contents
          .any((element) => element.forcePlay == true) ??
      false;

  // ---------- WARD CONTENTS ----------

  static final Queue<WardContent> _wardContents = Queue<WardContent>();

  static Queue<WardContent> addWardContent(List<WardContent> contents) {
    contents.shuffle();
    _wardContents.addAll(contents);
    return _wardContents;
  }

  static Queue<WardContent> updateWardContent(WardContent content) {
    _wardContents.removeWhere((element) => element.id == content.id);
    _wardContents.add(content);
    return _wardContents;
  }

  static Queue<WardContent> removeWardContent(String id) {
    _wardContents.removeWhere((element) => element.id == id);
    return _wardContents;
  }

  static WardContent? popWardContent() {
    // If queue is empty, return null
    if (_wardContents.isEmpty) return null;
    // If queue is not empty, remove first scrolling text if it is not time to scroll
    while (_wardContents.first.playType == AppConstants.specificTimeRange &&
        !(_wardContents.first.startTime.isBefore(AppConstants.now as TimeOfDay) &&
            _wardContents.first.endTime.isAfter(AppConstants.now as TimeOfDay))) {
      _wardContents.removeFirst();
      // If queue has no scrolling text to be played at the current time, return null
      if (_wardContents.isEmpty) return null;
    }

    // If queue is not empty, return first scrolling text
    final content = _wardContents.removeFirst();
    return content;
  }

  static WardContent? addWardContentToTop(WardContent content) {
    _wardContents.addFirst(content);
    return content;
  }

  static Queue<WardContent> get wardContents => _wardContents;
}
