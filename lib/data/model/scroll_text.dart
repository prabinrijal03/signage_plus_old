import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../../core/extensions.dart';
import '../../services/utils.dart';

class ScrollTexts {
  List<ScrollText> scrollTexts;

  ScrollTexts({required this.scrollTexts});

  factory ScrollTexts.fromJson(List<dynamic> json) {
    List<ScrollText> scrollTexts = [];
    scrollTexts = json.map((i) => ScrollText.fromJson(i)).toList();

    return ScrollTexts(scrollTexts: scrollTexts);
  }

  Map<String, dynamic> toJson() {
    return {
      'scrollTexts': scrollTexts.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ScrollTexts{scrollTexts: $scrollTexts}';
  }
}

class ScrollText {
  final String id;
  final String text;
  final bool status;
  final ScrollCategory scrollCategory;
  final ScrollTimer scrollTimer;

  ScrollText({required this.id, required this.text, required this.scrollCategory, required this.scrollTimer, required this.status});

  factory ScrollText.fromJson(Map<String, dynamic> json) {
    return ScrollText(
        id: json['scrollTextID'],
        text: json['scrollText'],
        status: json['isActive'] ?? true,
        scrollCategory: ScrollCategory.fromJson(
          json['ScrollText_Category'].first['scrollCategory'],
        ),
        scrollTimer: ScrollTimer.fromJson(
          json['ScrollTimer'].first,
        ));
  }

  Map<String, dynamic> toJson() {
    return {
      'scrollTextID': id,
      'scrollText': text,
      'isActive': status,
      'scrollCategory': scrollCategory.toJson(),
    };
  }
}

class ScrollCategory {
  final String id;
  final String category;
  final String backgroundColor;

  ScrollCategory({required this.id, required this.category, required this.backgroundColor});

  factory ScrollCategory.fromJson(Map<String, dynamic> json) {
    return ScrollCategory(
      id: json['scrollCategoryID'],
      category: json['scrollCategory'],
      backgroundColor: json['backgroundColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scrollCategoryID': id,
      'scrollCategory': category,
      'backgroundColor': backgroundColor,
    };
  }
}

class ScrollTimer {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String type;

  const ScrollTimer({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  factory ScrollTimer.fromJson(Map<String, dynamic> json) {
    return ScrollTimer(
      id: json['scrollTimerID'],
      startDate: DateTime.parse(json['startDate'] ?? "${DateTime.now().year}-01-01T00:00:00.000Z"),
      endDate: DateTime.parse(json['endDate'] ?? "${DateTime.now().year + 1}-01-01T00:00:00.000Z"),
      startTime: Utils.parseTimeOfDay(json['startTime'] ?? "00:00:00"),
      endTime: Utils.parseTimeOfDay(json['endTime'] ?? "23:59:59"),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scrollTimerID': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startTime': startTime.formatTimeOfDay,
      'endTime': endTime.formatTimeOfDay,
      'type': type,
    };
  }
}

class ScrollTextsAdapter extends TypeAdapter<ScrollTexts> {
  @override
  final int typeId = 1;

  @override
  ScrollTexts read(BinaryReader reader) {
    return ScrollTexts(
      scrollTexts: reader.readList().cast<ScrollText>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScrollTexts obj) {
    writer.writeList(obj.scrollTexts);
  }
}

class ScrollTextAdapter extends TypeAdapter<ScrollText> {
  @override
  final int typeId = 2;

  @override
  ScrollText read(BinaryReader reader) {
    return ScrollText(
      id: reader.readString(),
      text: reader.readString(),
      status: reader.read() as bool,
      scrollCategory: reader.read() as ScrollCategory,
      scrollTimer: reader.read() as ScrollTimer,
    );
  }

  @override
  void write(BinaryWriter writer, ScrollText obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.text);
    writer.write(obj.status);
    writer.write(obj.scrollCategory);
    writer.write(obj.scrollTimer);
  }
}

class ScrollCategoryAdapter extends TypeAdapter<ScrollCategory> {
  @override
  final int typeId = 3;

  @override
  ScrollCategory read(BinaryReader reader) {
    return ScrollCategory(
      id: reader.readString(),
      category: reader.readString(),
      backgroundColor: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ScrollCategory obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.category);
    writer.writeString(obj.backgroundColor);
  }
}

class ScrollTimerAdapter extends TypeAdapter<ScrollTimer> {
  @override
  final int typeId = 4;

  @override
  ScrollTimer read(BinaryReader reader) {
    return ScrollTimer(
      id: reader.readString(),
      startDate: reader.read() as DateTime,
      endDate: reader.read() as DateTime,
      startTime: reader.read() as TimeOfDay,
      endTime: reader.read() as TimeOfDay,
      type: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ScrollTimer obj) {
    writer.writeString(obj.id);
    writer.write(obj.startDate);
    writer.write(obj.endDate);
    writer.write(obj.startTime);
    writer.write(obj.endTime);
    writer.writeString(obj.type);
  }
}

class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 5;

  @override
  TimeOfDay read(BinaryReader reader) {
    return Utils.parseTimeOfDay(reader.readString());
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeString(obj.formatTimeOfDay);
  }
}
