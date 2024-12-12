import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../services/utils.dart';

class Contents {
  final List<Content> contents;

  const Contents({
    required this.contents,
  });

  factory Contents.fromJson(List<dynamic> json) {
    List<Content> contents = [];
    contents = json.map((i) => Content.fromJson(i)).toList();

    return Contents(contents: contents);
  }

  Map<String, dynamic> toJson() {
    return {
      'content': contents.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Content {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool status;
  final String playType;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool forcePlay;
  final bool isFullscreenContent;
  final int displayTime;
  final String transition;
  final ContentLayout layout;

  const Content({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.playType,
    required this.startTime,
    required this.endTime,
    required this.forcePlay,
    required this.isFullscreenContent,
    required this.displayTime,
    required this.transition,
    required this.layout,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['contentID'],
      name: json['contentName'],
      startDate: DateTime.parse(json['startDate'] ?? "${DateTime.now().year}-01-01T00:00:00.000Z"),
      endDate: DateTime.parse(json['endDate'] ?? "${DateTime.now().year + 1}-01-01T00:00:00.000Z"),
      status: json['isActive'] ?? true,
      playType: json['playType'],
      startTime: Utils.parseTimeOfDay(json['startTime'] ?? "00:00:00"),
      endTime: Utils.parseTimeOfDay(json['endTime'] ?? "23:59:59"),
      forcePlay: json['forcePlay'],
      isFullscreenContent: json['isFullscreenContent'],
      displayTime: json['displayTime'],
      transition: json['transition'],
      layout: ContentLayout.fromJson(json['layout']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentID': id,
      'contentName': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': status,
      'playType': playType,
      'startTime': startTime.formatTimeOfDay,
      'endTime': endTime.formatTimeOfDay,
      'forcePlay': forcePlay,
      'isFullscreenContent': isFullscreenContent,
      'displayTime': displayTime,
      'transition': transition,
      'layout': layout.toJson(),
    };
  }

  Content copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? status,
    String? playType,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? forcePlay,
    bool? isFullscreenContent,
    int? displayTime,
    String? transition,
    ContentLayout? layout,
  }) {
    return Content(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      playType: playType ?? this.playType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      forcePlay: forcePlay ?? this.forcePlay,
      isFullscreenContent: isFullscreenContent ?? this.isFullscreenContent,
      displayTime: displayTime ?? this.displayTime,
      transition: transition ?? this.transition,
      layout: layout ?? this.layout,
    );
  }
}

class ContentLayout {
  final String? id;
  final ContentData? data;
  final int flex;
  final String type;
  final bool? hasVideo;
  final List<String>? margin;
  final Overlay? overlay;
  final List<ContentLayout>? children;

  const ContentLayout({
    required this.id,
    required this.data,
    required this.flex,
    required this.type,
    required this.margin,
    required this.hasVideo,
    required this.children,
    this.overlay,
  });

  factory ContentLayout.fromJson(Map<String, dynamic> json) {
    return ContentLayout(
        id: json['id'],
        data: json['data'] != null
            ? (json['data'] as Map<String, dynamic>).isNotEmpty
                ? ContentData.fromJson(json['data']['content'])
                : null
            : null,
        flex: json['flex'],
        type: json['type'],
        // ignore: prefer_null_aware_operators
        margin: json['margin'] != null ? json['margin'].cast<String>() : ['none'],
        hasVideo: json['hasVideo'],
        children: json['children'].map<ContentLayout>((i) => ContentLayout.fromJson(i)).toList(),
        overlay: json['overlay'] == null ? null : Overlay.fromJson(json['overlay']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data != null ? {"content": data!.toJson()} : null,
      'flex': flex,
      'type': type,
      'margin': margin,
      'hasVideo': hasVideo,
      'children': children?.map((e) => e.toJson()).toList(),
      'overlay': overlay?.toJson(),
    };
  }
}

class ContentData {
  final String fileType;
  final String fileContent;

  const ContentData({
    required this.fileType,
    required this.fileContent,
  });

  factory ContentData.fromJson(Map<String, dynamic> json) {
    return ContentData(
      fileType: json['fileType'],
      fileContent: json['fileContent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileType': fileType,
      'fileContent': fileContent,
    };
  }
}

// ------ Content Urls ------
class ContentUrls {
  List<ContentLink> imageLinks;
  List<ContentLink> videoLinks;

  ContentUrls({
    required this.imageLinks,
    required this.videoLinks,
  });

  factory ContentUrls.fromJson(Map<String, dynamic> json) {
    return ContentUrls(
      imageLinks: json['imageLinks'].map<ContentLink>((i) => ContentLink.fromJson(i)).toList(),
      videoLinks: json['videoLinks'].map<ContentLink>((i) => ContentLink.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageLinks': imageLinks,
      'videoLinks': videoLinks,
    };
  }
}

class ContentLink {
  final String id;
  final String url;

  const ContentLink({
    required this.id,
    required this.url,
  });

  factory ContentLink.fromJson(Map<String, dynamic> json) {
    return ContentLink(
      id: json['id'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}

class Overlay {
  String url;
  Config config;

  Overlay({
    required this.url,
    required this.config,
  });

  factory Overlay.fromJson(Map<String, dynamic> json) {
    return Overlay(
      url: json['data']['content'],
      config: Config.fromJson(json['config']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {'content': url},
      'config': config.toJson(),
    };
  }
}

class Config {
  final String top;
  final String left;
  final String width;
  final String height;

  const Config({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      top: json['top'],
      left: json['left'],
      width: json['width'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top,
      'left': left,
      'width': width,
      'height': height,
    };
  }
}
